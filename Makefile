.PHONY: run
run:
	docker run -itd --hostname nso --name cisco-nso-dev \
                   -p 2024:2024 \
                   -p 8080:8080 \
                   cisco-nso-dev:0.1

.PHONY: purge
purge:
	docker stop cisco-nso-dev
	docker rm cisco-nso-dev
