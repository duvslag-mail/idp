-include .env
export

DB_USER ?= postgres
DB_PASSWORD ?= postgres
# DB_URL ?= postgres://${DB_USER}:${DB_PASSWORD}@127.0.0.1:5432

dev:
	@echo "Starting postgres container..."
	docker compose up -d
	@until docker exec idp_db pg_isready > /dev/null 2>&1; do sleep 1; done

	@echo "Generating templ and sqlc code..."
	$(MAKE) generate

	@echo "Starting air.."
	air

generate:
	templ generate
	sqlc generate