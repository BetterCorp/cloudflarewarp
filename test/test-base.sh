echo "";
echo "";
echo "*** STARTING TEST FOR : ${1}-${2}-${3}";
echo "";
echo "";

rm -rf ./logs;
rm -rf ./tempconfig;

mkdir ./logs;
mkdir ./tempconfig;

touch ./logs/access.log;
touch ./logs/debug.log;
touch ./logs/traefik.log;
touch ./logs/output.log;

cp "./config/${1}.${2}" "./tempconfig/config.${2}"

chmod -R 7777 ./logs;
chmod -R 7777 ./tempconfig;

if [ "${3}" = "stack" ]; then
  docker stack deploy -c docker-stack.yml test-instance;
  sleep 5s;
else
  docker-compose up -d;
  sleep 5s;
fi

curl -H "CF-Connecting-IP:187.2.2.2" -H "CF-Visitor:{\"scheme\":\"https\"}" http://localhost:4008/ >> ./logs/output.log;
cat ./logs/output.log;

if [ "${3}" = "stack" ] ; then
  docker stack rm test-instance;
  sleep 5s;
else
  sleep 5s;
  docker-compose down;
fi

