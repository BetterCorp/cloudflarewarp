#!/bin/sh

TEST_IP="187.2.2.1"

rm -rf ./logs-success
rm -rf ./logs-success-toml
rm -rf ./logs-success-yml
rm -rf ./logs-fail
rm -rf ./logs-fail-toml
rm -rf ./logs-fail-yml
rm -rf ./logs-invalid
rm -rf ./logs-invalid-toml
rm -rf ./logs-invalid-yml

if [ "${1}" = "stack" ]; then
  docker swarm init
  sleep 5s
fi

docker pull traefik/whoami:v1.8.1
docker pull traefik:2.8

sleep 1s

bash test-base.sh success toml "${1}" $TEST_IP

sleep 1s

mv ./logs ./logs-success-toml
mv ./tempconfig ./logs-success-toml/config

sleep 1s

bash test-base.sh fail toml "${1}" $TEST_IP

sleep 1s

mv ./logs ./logs-fail-toml
mv ./tempconfig ./logs-fail-toml/config

sleep 1s

bash test-base.sh invalid toml "${1}" "1522.20.2"

sleep 1s

mv ./logs ./logs-invalid-toml
mv ./tempconfig ./logs-invalid-toml/config

sleep 1s

bash ./test-verify.sh toml $TEST_IP

sleep 1s

bash test-base.sh success yml "${1}" $TEST_IP

sleep 1s

mv ./logs ./logs-success-yml
mv ./tempconfig ./logs-success-yml/config

sleep 1s

bash test-base.sh fail yml "${1}" $TEST_IP

sleep 1s

mv ./logs ./logs-fail-yml
mv ./tempconfig ./logs-fail-yml/config

sleep 1s

bash test-base.sh invalid yml "${1}" "1522.20.2"

sleep 1s

mv ./logs ./logs-invalid-yml
mv ./tempconfig ./logs-invalid-yml/config

sleep 1s

bash ./test-verify.sh yml $TEST_IP
