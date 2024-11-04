package main

import (
	"example.com/m/v2/handlers"
	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
	"log"
	"net/http"
)

func main() {
	dbConnStr := "postgres://username:password@localhost:5432/dbname?sslmode=disable"
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
