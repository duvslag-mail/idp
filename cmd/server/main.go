package main

import (
	"context"
	"net/http"
	"os"

	"github.com/a-h/templ"
	"github.com/duvslag-email/idp/db/sqlc"
	"github.com/duvslag-email/idp/templates/pages"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/jackc/pgx/v5"
)

func main() {
	r := chi.NewRouter()

	ctx := context.Background()
	dbUrl := os.Getenv("DB_URL")

	conn, err := pgx.Connect(ctx, dbUrl)
	if err != nil {
		panic(err.Error())
	}
	defer conn.Close(ctx)

	queries := sqlc.New(conn)
	_ = queries

	r.Use(middleware.Logger)

	r.Get("/", templ.Handler(pages.Home()).ServeHTTP)

	println("Serving on http://localhost:8080")
	http.ListenAndServe(":8080", r)
}
