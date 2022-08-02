#!/bin/sh

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

sed -i "s/  version = \".*/  version = \"${LATEST_PLUGIN_VERSION}\"/g" ./traefik-prod.toml;

echo "Updated prod version of plugin to latest tag: ${LATEST_PLUGIN_VERSION}"

rm -rf ./logs-prod-success-toml

bash test-base-prod.sh success toml "${1}"

sleep 1s

mv ./logs ./logs-prod-success-toml
mv ./tempconfig ./logs-prod-success-toml/config

sleep 1s

rm -rf ./logs-prod-fail-toml

bash test-base-prod.sh fail toml "${1}"

sleep 1s

mv ./logs ./logs-prod-fail-toml
mv ./tempconfig ./logs-prod-fail-toml/config

sleep 1s

rm -rf ./logs-prod-success-yml

bash ./test-verify-prod.sh toml

sleep 1s

bash test-base-prod.sh success yml "${1}"

sleep 1s

mv ./logs ./logs-prod-success-yml
mv ./tempconfig ./logs-prod-success-yml/config

sleep 1s

rm -rf ./logs-prod-fail-yml

bash test-base-prod.sh fail yml "${1}"

sleep 1s

mv ./logs ./logs-prod-fail-yml
mv ./tempconfig ./logs-prod-fail-yml/config

sleep 1s

bash ./test-verify-prod.sh yml
