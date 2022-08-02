#!/bin/sh

echo ""
echo ""
echo "*** STARTING TEST FOR : ${1}-${2}-${3}"
echo ""
echo ""

rm -rf ./logs
rm -rf ./tempconfig

mkdir ./logs
mkdir ./tempconfig

touch ./logs/access.log
touch ./logs/debug.log
touch ./logs/traefik.log
touch ./logs/output.log

cp "./config/${1}.${2}" "./tempconfig/config.${2}"

chmod -R 7777 ./logs
chmod -R 7777 ./tempconfig

if [ "${3}" = "stack" ]; then
  docker stack deploy -c docker-stack-prod.yml test-instance
  sleep 1s
else
  mv docker-compose.yml docker-compose.yml.bak
  cp docker-compose-prod.yml docker-compose.yml
  docker-compose up -d
  sleep 1s
  rm docker-compose.yml
  mv docker-compose.yml.bak docker-compose.yml
fi

iterations=0
while ! grep -q "Starting TCP Server" "./logs/debug.log" && [ $iterations -lt 30 ]; do
  sleep 1s
  echo "Waiting for Traefik to be ready [${iterations}s/30]"
  let iterations++
done

iterations=0
while ! grep -q "Provider connection established with docker" "./logs/debug.log" && [ $iterations -lt 30 ]; do
  sleep 1s
  echo "Waiting for Traefik to connect to docker [${iterations}s/30]"
  let iterations++
done

iterations=0
while ! grep -q "Propagating new UP status" "./logs/debug.log" && [ $iterations -lt 30 ]; do
  sleep 1s
  echo "Waiting for Traefik to UP the service [${iterations}s/30]"
  let iterations++
done

curl -H "CF-Connecting-IP:187.2.2.2" -H "CF-Visitor:{\"scheme\":\"https\"}" http://localhost:4008/ >>./logs/output.log
cat ./logs/output.log

if [ "${3}" = "stack" ]; then
  sleep 1s
  docker stack rm test-instance
else
  sleep 1s
  docker-compose down
fi
sleep 1s