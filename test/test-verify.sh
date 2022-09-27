SUCCESS_CONFIG_FILE="./logs-success-${1}/output.log"
FAIL_CONFIG_FILE="./logs-fail-${1}/output.log"
INVALID_CONFIG_FILE="./logs-invalid-${1}/output.log"

echo "RUNNING TESTS FOR ${1}"
echo " - Succ $SUCCESS_CONFIG_FILE"
echo " - Fail $FAIL_CONFIG_FILE"
echo " - Inva $INVALID_CONFIG_FILE"

sleep 1s

if ! grep -q "X-Is-Trusted: yes" $SUCCESS_CONFIG_FILE; then
  echo "'X-Is-Trusted: yes' header was not added and parsed ($SUCCESS_CONFIG_FILE)"
  exit 5
fi
if ! grep -q "X-Forwarded-For: ${2}" $SUCCESS_CONFIG_FILE; then
  echo "'X-Forwarded-For: ${2}' header not defined ($SUCCESS_CONFIG_FILE)"
  exit 5
fi
#if ! grep -q "X-Real-Ip: 10.0.0.2" $SUCCESS_CONFIG_FILE; then
#  echo "IP real not defined"
#  exit 5
#fi
if ! grep -q "Cf-Visitor: {\"scheme\":\"https\"}" $SUCCESS_CONFIG_FILE; then
  echo "'Cf-Visitor: {\"scheme\":\"https\"}' header not defined ($SUCCESS_CONFIG_FILE)"
  exit 5
fi

if ! grep -q "X-Is-Trusted: no" $FAIL_CONFIG_FILE; then
  echo "'X-Is-Trusted: no' header was not added to the invalid request ($FAIL_CONFIG_FILE)"
  exit 5
fi
if ! grep -q "X-Is-Trusted: no" $INVALID_CONFIG_FILE; then
  echo "'X-Is-Trusted: no' header was not added to the invalid request ($INVALID_CONFIG_FILE)"
  exit 5
fi
#if ! grep -q "X-Forwarded-For: 10.0.0.2" $FAIL_CONFIG_FILE; then
#  echo "Forwarded header was not defined as the original IP"
#  exit 5
#fi

echo "TESTS OK"
