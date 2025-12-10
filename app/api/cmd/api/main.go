package main

import (
	"log"
	"net/http"
	"os"

	"github.com/gorilla/mux"
)

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/healthz", healthz).Methods("GET")
	r.HandleFunc("/videos/presign", presignVideo).Methods("POST")
	r.HandleFunc("/videos/confirm", confirmVideo).Methods("POST")
	r.HandleFunc("/feed", getFeed).Methods("GET")

	port := os.Getenv("PORT")
	if port == "" { port = "8080" }

	log.Printf("API listening on :%s", port)
	log.Fatal(http.ListenAndServe(":"+port, r))
}
