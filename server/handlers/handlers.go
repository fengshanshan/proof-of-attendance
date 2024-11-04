package handlers

import (
	"database/sql"
	"encoding/json"
	"example.com/m/v2/verifier"
	_ "github.com/lib/pq"
	"log"
	"net/http"
	"time"
)

type AttendanceProof struct {
	UserID string `json:"user_id"`
	Proof  string `json:"proof"`
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
	var proof AttendanceProof
	if err := json.NewDecoder(r.Body).Decode(&proof); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// 验证proof (这里需要调用智能合约的verify方法)
	isValid := verifier.VerifyProofWithContract(proof.Proof)

	// 获取当前日期（使用UTC时间）
	today := time.Now().UTC().Format("2006-01-02")

	// 存储记录
	_, err := s.db.Exec(`
		INSERT INTO attendance_records (user_id, proof, is_valid, date)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (user_id, date) DO UPDATE 
		SET proof = $2, is_verified = $3
	`, proof.UserID, proof.Proof, isValid, today)

	if err != nil {
		log.Printf("Error saving attendance record: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":  true,
		"verified": isValid,
	})
}
