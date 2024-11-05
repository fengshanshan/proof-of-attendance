package handlers

import (
	"bytes"
	"database/sql"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"time"

	"example.com/m/v2/verifier"
	_ "github.com/lib/pq"
)

type AttendanceProof struct {
	UserName  string             `json:"user_name"`
	ProofData verifier.ProofData `json:"proof_data"`
}

type Server struct {
	db *sql.DB
}

func NewServer(dbConnStr string) (*Server, error) {
	db, err := sql.Open("postgres", dbConnStr)
	if err != nil {
		return nil, err
	}

	return &Server{db: db}, nil
}

func (s *Server) HandleSubmitProof(w http.ResponseWriter, r *http.Request) {
	// 读取请求体
	body, err := io.ReadAll(r.Body)
	if err != nil {
		log.Printf("Error reading body: %v", err)
		http.Error(w, "Error reading request body", http.StatusBadRequest)
		return
	}

	// 清理 BOM 和其他不可见字符
	body = bytes.TrimPrefix(body, []byte("\xef\xbb\xbf"))

	var proof AttendanceProof
	// 使用 json.Unmarshal 而不是 json.NewDecoder
	if err := json.Unmarshal(body, &proof); err != nil {
		log.Printf("Error decoding proof: %v", err)
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// 验证proof (这里需要调用智能合约的verify方法)
	isValid := verifier.VerifyProofWithContract(proof.ProofData)

	proofStr, err := json.Marshal(proof.ProofData)
	if err != nil {
		log.Printf("Error marshalling proof: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	// 获取当前日期（使用UTC时间）
	today := time.Now().UTC().Format("2006-01-02")

	// 在插入之前先检查记录是否存在
	var exists bool
	err = s.db.QueryRow(`
		SELECT EXISTS(
			SELECT 1 FROM attendance_records 
			WHERE user_name = $1 AND date = $2
		)`, proof.UserName, today).Scan(&exists)

	if err != nil {
		log.Printf("Error checking existing record: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	if exists {
		log.Printf("User %s already has an attendance record for %s", proof.UserName, today)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": false,
			"message": "Already submitted attendance for today",
		})
		return
	}

	// 存储记录
	result, err := s.db.Exec(`
		INSERT INTO attendance_records (user_name, is_valid, proof, date)
		VALUES ($1, $2, $3, $4)`, proof.UserName, isValid, string(proofStr), today)

	if err != nil {
		log.Printf("Error saving attendance record: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		log.Printf("Error getting rows affected: %v", err)
	} else {
		log.Printf("Rows affected: %d", rowsAffected)
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":  true,
		"verified": isValid,
	})
}
