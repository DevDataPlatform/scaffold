
# Build all the images

all: 
	# Build frontend
	make -C image-frontend

	# Build backend
	make -C image-backend

start-airbyte:
	abctl local install --username foo --password bar

image-backend:
	docker build -f Docker/Dockerfile.backend.deploy --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') -t dalgo_backend:0.1 .

image-frontend:
	docker build -f Docker/Dockerfile.frontend.deploy --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg NEXT_PUBLIC_BACKEND_URL="http://backend:8002" -t dalgo_frontend:0.1 .

compose-up:
	chmod +x Docker/scripts/init-db.sh
	docker-compose -f docker-compose.yaml up

compose-down:
	docker-compose -f docker-compose.yaml down --volumes