rm -rf ./logs;
rm -rf ./tempconfig;

mkdir ./logs;
mkdir ./tempconfig;

touch ./logs/access.log;
touch ./logs/debug.log;
touch ./logs/traefik.log;
touch ./logs/output.log;

cp "./config/${1}.toml" ./tempconfig/config.toml

chmod -R 7777 ./logs;
chmod -R 7777 ./tempconfig;

if [ "${2}" = "stack" ]; then
  docker stack deploy -c docker-stack.yml test-instance;
  sleep 5s;
else
  docker-compose up -d;
fi

curl -H "CF-Connecting-IP:187.2.2.2" -H "CF-Visitor:{\"scheme\":\"https\"}" http://localhost:4008/ >> ./logs/output.log;

if [ "${2}" = "stack" ] ; then
  docker stack rm test-instance;
  sleep 5s;
else
  docker-compose down;
fi

