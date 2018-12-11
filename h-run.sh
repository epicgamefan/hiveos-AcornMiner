#!/usr/bin/env bash

cd `dirname $0`

[ -t 1 ] && . colors

. ./h-manifest.conf

[[ -z $CUSTOM_CONFIG_FILENAME ]] && echo -e "${RED}No CUSTOM_CONFIG_FILENAME is set${NOCOLOR}" && exit 1
[[ ! -f $CUSTOM_CONFIG_FILENAME ]] && echo -e "${RED}No $CUSTOM_CONFIG_FILENAME is found${NOCOLOR}" && exit 1 
[[ ! -s $CUSTOM_CONFIG_FILENAME ]] && echo -e "${RED}Config file is empty - check syntax! ${NOCOLOR}" && exit 1 

#TODO:  Add Driver Check


#Run binaries
mkdir -p /var/log/miner/custom/$CUSTOM_NAME
AcornMiner $(< /hive/miners/custom/$CUSTOM_NAME/$CUSTOM_NAME.conf) $@ 2>&1 | tee $CUSTOM_LOG_BASENAME.log
