-include .env
export

DB_USER ?= postgres
DB_PASSWORD ?= postgres
DB_NAME ?= idpdb
DB_URL ?= postgres://${DB_USER}:${DB_PASSWORD}@127.0.0.1:5432/idpdb?sslmode=disable

dev:
	@echo "Starting postgres container..."
	docker compose up -d
	@until docker exec idp_db pg_isready > /dev/null 2>&1; do sleep 1; done

	@echo "Running database migrations..."
	$(MAKE) migrate-up

	@echo "Generating templ and sqlc code..."
	$(MAKE) generate

	@echo "Starting air.."
	air
 
migrate-up:
	goose -dir db/migrations postgres "$(DB_URL)" up

migrate-down:
	goose -dir db/migrations postgres "$(DB_URL)" downj

generate:
	templ generate
	sqlc generate