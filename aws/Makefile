.PHONY: localstack deploy localstack-down install u d lint

deploy:
	cdklocal bootstrap
	cdklocal deploy --all --require-approval=never

localstack:
	docker-compose -f docker-compose-local.yml up -d

localstack-down:
	docker-compose -f docker-compose-local.yml down

install:
	npm install -g aws-cdk-local aws-cdk
	pip3 install --no-cache-dir -r aws/requirements.txt

lint:
	black .
	find . -type f -name "*.py" -not -path "./cdk.out/*" | xargs pylint

healthcheck:
	@echo "Checking health of LocalStack services..."
	@while [ -z "$$(curl -s http://localhost:4566/_localstack/health | jq 'all(.services | to_entries[] | .value; . as $$a | ["running", "available"] | index($$a))')" ]; do \
		echo "Services are still starting, waiting..."; \
		sleep 5; \
	done
	@echo "All services are up and running."

clean-pycache:
	find . -type f -name "*.pyc" -exec rm -f {} +
	find . -type d -name "__pycache__" -exec rm -rf {} +

clean-docker:
	docker compose down --timeout 0 --remove-orphans --rmi all --volumes
	docker volume rm $(docker volume ls -qf dangling=true) > /dev/null 2>&1 || true
	docker rmi $(docker images -qf dangling=true) > /dev/null 2>&1 || true

clean-localstack:
	docker compose down --timeout 0 --remove-orphans --rmi all --volumes
	rm -rf cdk.out
	sudo rm -rf volume

clean-all: clean-pycache clean-docker clean-localstack

prune-docker:
	docker system prune -f
	docker volume prune -f
	docker network prune -f

prune-all: clean-all prune-docker

u: localstack healthcheck deploy

d: localstack-down