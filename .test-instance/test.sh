rm -rf ./logs-success;
rm -rf ./logs-fail;

if [ "${1}" = "stack" ] ; then
  docker swarm init;
  sleep 5s;
fi

docker pull traefik/whoami:v1.8.1;
docker pull traefik:2.8;

sleep 1s;

rm -rf ./logs-success-toml

bash test-base.sh success toml "${1}";

sleep 1s;

mv ./logs ./logs-success-toml;
mv ./tempconfig ./logs-success-toml/config;

sleep 1s;

rm -rf ./logs-fail-toml

bash test-base.sh fail toml "${1}";

sleep 1s;

mv ./logs ./logs-fail-toml;
mv ./tempconfig ./logs-fail-toml/config;

sleep 1s;

rm -rf ./logs-success-yml

bash ./test-verify.sh toml;

sleep 1s;

bash test-base.sh success yml "${1}";

sleep 1s;

mv ./logs ./logs-success-yml;
mv ./tempconfig ./logs-success-yml/config;

sleep 1s;

rm -rf ./logs-fail-yml

bash test-base.sh fail yml "${1}";

sleep 1s;

mv ./logs ./logs-fail-yml;
mv ./tempconfig ./logs-fail-yml/config;

sleep 1s;

bash ./test-verify.sh yml;
