SUCCESS_CONFIG_FILE="./logs-success/output.log"
FAIL_CONFIG_FILE="./logs-fail/output.log"

echo "RUNNING TESTS";

if ! grep -q "X-Is-Trusted: yes" $SUCCESS_CONFIG_FILE; then
  echo "X-Is-Trusted header was not added and parsed"
  exit 5
fi
if ! grep -q "X-Forwarded-For: 187.2.2.2" $SUCCESS_CONFIG_FILE; then
  echo "IP header not defined"
  exit 5
fi
if ! grep -q "X-Real-Ip: 10.0.0.2" $SUCCESS_CONFIG_FILE; then
  echo "IP real not defined"
  exit 5
fi
if ! grep -q "Cf-Visitor: {\"scheme\":\"https\"}" $SUCCESS_CONFIG_FILE; then
  echo "Schema header not defined"
  exit 5
fi

if ! grep -q "X-Is-Trusted: no" $FAIL_CONFIG_FILE; then
  echo "X-Is-Trusted header was not added to the invalid request"
  exit 5
fi
if ! grep -q "X-Forwarded-For: 10.0.0.2" $FAIL_CONFIG_FILE; then
  echo "Forwarded header was not defined as the original IP"
  exit 5
fi

echo "TESTS OK"
