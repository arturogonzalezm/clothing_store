.PHONY: all build up down clean logs db-shell rebuild test run

# Default target
all: build up

rebuild: down clean build up

# Build the Docker images without using cache
build:
	@echo "Building Docker images..."
	docker compose build --no-cache

# Start the Docker containers in detached mode
up:
	@echo "Starting Docker containers..."
	docker compose up -d

# Stop the Docker containers
down:
	@echo "Stopping Docker containers..."
	docker compose down

# Remove Docker volumes
clean:
	@echo "Stopping and removing Docker containers and volumes..."
	docker compose down -v

# Show logs for all containers
logs:
	@echo "Showing logs for all containers..."
	docker compose logs -f

# Access the PostgreSQL database shell
db-shell:
	@echo "Connecting to the PostgreSQL database shell..."
	docker exec -it glamify psql -U glamify_user -d glamify

## Run tests for the Go application
#test:
#	@echo "Running Go tests..."
#	go test ./...
#
## Run the Go application
#run:
#	@echo "Running Go application..."
#	go run backend/cmd/app/main.go


# Run the Go application
#run:
#	@echo "Running the Go application..."
#	DB_HOST=localhost DB_USER=postgres DB_PASSWORD=postgres DB_NAME=postgres go run cmd/monitor/main.go