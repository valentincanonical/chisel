package main

import (
        "log"
        "net/http"
)

func main() {
        _, err := http.Get("https://golang.org")
        if err != nil {
                log.Fatal(err) 
        } else {
		log.Println("ok")
	}
}
