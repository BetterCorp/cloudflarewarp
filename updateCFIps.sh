rm CFIPs.txt;
curl https://www.cloudflare.com/ips-v4 >> CFIPs.txt;
echo "" >> CFIPs.txt;
curl https://www.cloudflare.com/ips-v6 >> CFIPs.txt;
echo "" >> CFIPs.txt;

OUTPUT_GO_CONFIG="ips/ips.go"

rm $OUTPUT_GO_CONFIG;

echo "package ips" >> $OUTPUT_GO_CONFIG;
echo "" >> $OUTPUT_GO_CONFIG;
echo "func CFIPs() []string {" >> $OUTPUT_GO_CONFIG;
echo "	return []string {" >> $OUTPUT_GO_CONFIG;

cat CFIPs.txt | while read line || [[ -n $line ]];
do
  printf '%s\n' "CF IP: $line"
  echo "		\"${line}\"," >> $OUTPUT_GO_CONFIG;
done

echo "	}" >> $OUTPUT_GO_CONFIG;
echo "}" >> $OUTPUT_GO_CONFIG;

rm CFIPs.txt;