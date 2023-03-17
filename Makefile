dbn:
	docker-compose build --no-cache

db:
	docker-compose build

duf:
	docker-compose up --force-recreate

t:
	docker-compose run --rm rails7-prac-app rails tailwindcss:build

dsp:
	docker system prune

ga:
	git add .

gc:
	git commit

gpom:
	git pull origin main