#!/bin/sh

TEST_IP="187.2.2.3"

rm -rf ./logs-success
rm -rf ./logs-fail

if [ "${1}" = "stack" ]; then
  docker swarm init
  sleep 5s
fi

docker pull traefik/whoami:v1.8.1
docker pull traefik:2.8

sleep 1s

# Get latest tag
LATEST_PLUGIN_VERSION=$(git describe --match "v*" --abbrev=0 --tags HEAD)

sed -i "s/  version = \".*/  version = \"${LATEST_PLUGIN_VERSION}\"/g" ./traefik-prod.toml

echo "Updated version of plugin to latest tag: ${LATEST_PLUGIN_VERSION}"

if [ ! "${1}" = "stack" ]; then
  mv docker-compose.yml docker-compose.yml.bak
  cp docker-compose-prod.yml docker-compose.yml
fi

rm -rf ./logs-prod-success-toml

bash test-base.sh success toml "${1}" $TEST_IP

sleep 1s

mv ./logs ./logs-prod-success-toml
mv ./tempconfig ./logs-prod-success-toml/config

sleep 1s

rm -rf ./logs-prod-fail-toml

bash test-base.sh fail toml "${1}" $TEST_IP

sleep 1s

mv ./logs ./logs-prod-fail-toml
mv ./tempconfig ./logs-prod-fail-toml/config

sleep 1s

rm -rf ./logs-success-yml

bash ./test-verify.sh toml $TEST_IP

sleep 1s

bash test-base.sh success yml "${1}" $TEST_IP

sleep 1s

mv ./logs ./logs-success-yml
mv ./tempconfig ./logs-success-yml/config

sleep 1s

rm -rf ./logs-fail-yml

bash test-base.sh fail yml "${1}" $TEST_IP

sleep 1s

mv ./logs ./logs-fail-yml
mv ./tempconfig ./logs-fail-yml/config

sleep 1s

bash ./test-verify.sh yml $TEST_IP

if [ ! "${1}" = "stack" ]; then
  rm docker-compose.yml
  mv docker-compose.yml.bak docker-compose.yml
fi