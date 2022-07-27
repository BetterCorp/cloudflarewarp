rm -rf ./logs-success;
rm -rf ./logs-fail;

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
