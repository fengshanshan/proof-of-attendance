package verifier

import (
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/joho/godotenv"
	"log"
	"math/big"
	"os"
	"strings"
)

type Proof struct {
	Pi_a []string   `json:"pi_a"`
	Pi_b [][]string `json:"pi_b"`
	Pi_c []string   `json:"pi_c"`
}

type ProofData struct {
	Proof         Proof    `json:"proof"`
	PublicSignals []string `json:"public_signals"`
}

func VerifyProofWithContract(proofData ProofData) bool {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Printf("Error loading .env file: %v", err)
		return false
	}

	// Get RPC URL from environment
	rpcURL := os.Getenv("ETHEREUM_RPC_URL")
	client, err := ethclient.Dial(rpcURL)
	if err != nil {
		log.Printf("Failed to connect to the Ethereum client: %v", err)
		return false
	}

	// 转换证明数据为合约需要的格式
	pA := [2]*big.Int{
		hexToBigInt(proofData.Proof.Pi_a[0]),
		hexToBigInt(proofData.Proof.Pi_a[1]),
	}
	pB := [2][2]*big.Int{
		{hexToBigInt(proofData.Proof.Pi_b[0][0]), hexToBigInt(proofData.Proof.Pi_b[0][1])},
		{hexToBigInt(proofData.Proof.Pi_b[1][0]), hexToBigInt(proofData.Proof.Pi_b[1][1])},
	}

	pC := [2]*big.Int{
		hexToBigInt(proofData.Proof.Pi_c[0]),
		hexToBigInt(proofData.Proof.Pi_c[1]),
	}

	pubSignals := make([]*big.Int, len(proofData.PublicSignals))
	for i, s := range proofData.PublicSignals {
		pubSignals[i] = hexToBigInt(s)
	}

	// Get contract address from environment
	contractAddress := common.HexToAddress(os.Getenv("VERIFIER_CONTRACT_ADDRESS"))
	verifier, err := NewVerifier(contractAddress, client)
	if err != nil {
		log.Printf("Failed to instantiate contract: %v", err)
		return false
	}

	// 调用合约验证方法
	opts := &bind.CallOpts{Pending: false}

	// Convert pubSignals slice to fixed-size array
	var pubSignalsArray [2]*big.Int
	copy(pubSignalsArray[:], pubSignals)

	isValid, err := verifier.VerifyProof(opts, pA, pB, pC, pubSignalsArray)
	if err != nil {
		log.Printf("Failed to verify proof: %v", err)
		return false
	}

	log.Printf("Verification result: %v", isValid)
	return isValid
}

// 辅助函数：将十六进制字符串转换为 big.Int
func hexToBigInt(hex string) *big.Int {
	// 移除 "0x" 前缀（如果存在）
	hex = strings.TrimPrefix(hex, "0x")

	n := new(big.Int)
	n.SetString(hex, 16)
	return n
}
