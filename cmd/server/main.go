package main

import (
	"net/http"

	"github.com/a-h/templ"
	"github.com/duvslag-email/idp/internal/pages"
)

func main() {
	http.Handle("/", templ.Handler(pages.Home("World")))
	println("Serving on http://localhost:8080")
	http.ListenAndServe(":8080", nil)
}
