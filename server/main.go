package main

import (
	"example.com/m/v2/handlers"
	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
	"log"
	"net/http"
)

func main() {
	dbConnStr := "postgres://proof_of_attendance:Th3iN2p5xK9mV4qL8wE7@localhost:5433/attendance_record_db?sslmode=disable"
	server, err := handlers.NewServer(dbConnStr)
	if err != nil {
		log.Fatal(err)
	}

	r := mux.NewRouter()
	r.HandleFunc("/submit-proof", server.HandleSubmitProof).Methods("POST")

	log.Printf("Server starting on :8080")
	if err := http.ListenAndServe(":8080", r); err != nil {
		log.Fatal(err)
	}
}
