docker build -t bca/app:1.0 .
docker run --name app -p 80:80 bca/app:1.0

docker net host mode
