rm -rf ./logs-success;
rm -rf ./logs-fail;

if [ "${1}" = "stack" ] ; then
  docker swarm init;
  sleep 5s;
fi

docker pull traefik/whoami:v1.8.1;
docker pull traefik:2.8;

sleep 1s;

bash test-base.sh success "${1}";

sleep 1s;

mv ./logs ./logs-success;
mv ./tempconfig ./logs-success/config;

sleep 1s;

bash test-base.sh fail "${1}";

sleep 1s;

mv ./logs ./logs-fail;
mv ./tempconfig ./logs-fail/config;

sleep 1s;

bash ./test-verify.sh;
