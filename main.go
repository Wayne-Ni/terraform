package main

import (
    "fmt"
    "log"
    "net/http"
    "os"
    "strings"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Hello, World!")
}

func main() {
    dbPassword := os.Getenv("DB_PASSWORD")
    if len(dbPassword) == 0 {
        log.Fatal("missing required environment variable DB_PASSWORD; exiting")
    }

    // Masked log to confirm the value is loaded without leaking the secret
    masked := strings.Repeat("*", len(dbPassword))
    log.Printf("DB_PASSWORD loaded: %s\n", masked)

	http.HandleFunc("/", handler)
	fmt.Println("Server started at :8080")
	http.ListenAndServe(":8080", nil)
}
