#!/usr/bin/env bash
# This code is included in /hive/bin/custom function

[ -t 1 ] && . colors
. h-manifest.conf

[[ -z $CUSTOM_TEMPLATE ]] && echo -e "${YELLOW}CUSTOM_TEMPLATE is empty${NOCOLOR}"
[[ -z $CUSTOM_URL ]] && echo -e "${YELLOW}CUSTOM_URL is empty${NOCOLOR}"

conf="%AURL% %APORT% %AWALLET% %AWORKER% noreply@test.com 195"

acorn_wallet=`echo $CUSTOM_TEMPLATE | tr "." "\n" | head -n 1` 
conf=$(sed "s/%AWALLET%/$acorn_wallet/g" <<< "$conf")

[[ -z $CUSTOM_URL ]] && echo -e "${RED}CUSTOM_URL is empty${NOCOLOR}" 
pool_url=`echo $CUSTOM_URL | cut -d "/" -f3 | cut -d ":" -f1` 
pool_port=`echo $CUSTOM_URL | tr ":" "\n" | tail -n 1` 
conf=$(sed "s/%AURL%/$pool_url/g" <<< "$conf") 
conf=$(sed "s/%APORT%/$pool_port/g" <<< "$conf")


[[ ! -z $WORKER_NAME ]] && conf=$(sed "s/%AWORKER%/$WORKER_NAME/g" <<< "$conf") #|| echo "${RED}WORKER_NAME not set${NOCOLOR}"

[[ -z $CUSTOM_CONFIG_FILENAME ]] && echo -e "${RED}No CUSTOM_CONFIG_FILENAME is set${NOCOLOR}"
echo "$conf" > $CUSTOM_CONFIG_FILENAME
