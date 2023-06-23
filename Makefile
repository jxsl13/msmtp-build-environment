

# build & start development environment
default: debug

debug:
	docker-compose -f docker-compose.yaml up -d --build --force-recreate
	-docker exec -it debian-msmtp /bin/bash
	docker-compose -f docker-compose.yaml down

rebuild:
	docker-compose up -d --force-recreate --build

start:
	docker-compose up -d

stop:
	docker-compose down

build-compose:
	docker-compose build --force-rm --no-cache

clean:
	docker system prune


build:
	docker build -t msmtp-build-environment-debian:latest .

connect:
	docker exec -it debian-msmtp /bin/bash

kill:
	sudo systemctl restart docker.socket docker.service
	docker rm -f debian-msmtp
