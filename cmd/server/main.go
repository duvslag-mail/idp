package main

import (
	"context"
	"log"
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
	// dbUser := os.Getenv("DB_USER")
	// dbName := os.Getenv("DB_NAME")
	// dbPassword := os.Getenv("DB_PASSWORD")

	conn, err := pgx.Connect(ctx, dbUrl)
	if err != nil {
		panic(err.Error())
	}
	defer conn.Close(ctx)

	queries := sqlc.New(conn)

	r.Use(middleware.Logger)

	r.Get("/", templ.Handler(pages.Home()).ServeHTTP)

	r.Post("/create", func(w http.ResponseWriter, r *http.Request) {
		err := r.ParseForm()
		if err != nil {
			http.Error(w, "Couldn't parse form", 400)
			return
		}
		if !r.PostForm.Has("email") {
			http.Error(w, "No email specified", 400)
			return
		}
		email := r.PostForm["email"][0]

		user, err := queries.CreateUser(ctx, email)
		if err != nil {
			log.Println(err.Error())
			http.Error(w, "User already exists", 400)
			return
		}

		templ.Handler(pages.User(user.Email)).ServeHTTP(w, r)
	})

	println("Serving on http://localhost:8080")
	http.ListenAndServe(":8080", r)
}
