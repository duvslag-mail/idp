package main

import (
	"net/http"

	"github.com/a-h/templ"
	"github.com/duvslag-email/idp/templates/pages"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func main() {
	r := chi.NewRouter()
	r.Use(middleware.Logger)

	r.Get("/", templ.Handler(pages.Home("World")).ServeHTTP)

	println("Serving on http://localhost:8080")
	http.ListenAndServe(":8080", r)
}
