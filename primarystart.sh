docker-compose up -d
sleep 15
docker cp usersetup.sh Mongo:/
docker cp replsetup.sh Mongo:/
docker exec -it Mongo /usersetup.sh
