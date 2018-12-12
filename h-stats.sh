#!/usr/bin/env bash

#######################
# Functions
#######################


get_cards_hashes(){
 # hs is global
 hs=''
 for (( i=1; i <= $(get_acorn_count); i++ )); do
 	 local MHS=`tail -n 300 $LOG_NAME | grep -a "$(echo $i | awk '{printf("A-%d",$1)}')" | tail -n 2 | head -n 1 | cut -d ":" -f8 | cut -d "M" -f1 | sed 's/ //g'`
	 hs[$i]=`echo $MHS | awk '{ printf("%.f",$1*1000) }'`
 done
 }

get_acorn_count(){
  local AcornCount=`lspci | grep "Processing accelerators" -c | awk '{printf "%d", $1}'`  
  echo $AcornCount 
}
get_acorns_temp(){
   
  for (( i=1; i <= $(get_acorn_count); i++ )); do                                                                                                                                                                   
         local t=`tail -n 300 $LOG_NAME | grep -a "$(echo $i | awk '{printf("A-%d",$1)}')" | tail -n 2 | head -n 1 | cut -d ":" -f4 | cut -d "C" -f1| sed 's/ //g'`                                                                 
         echo $t                                                                                                                                                                                                                                                                                                                                                     
 done	

}

get_acorns_vcc(){

for (( i=1; i <= $(get_acorn_count); i++ )); do                                                                                                                                                                  
         local t=`tail -n 300 $LOG_NAME | grep -a "$(echo $i | awk '{printf("A-%d",$1)}')" | tail -n 2 | head -n 1 | cut -d ":" -f5 | cut -d "V" -f1| sed 's/ //g' | awk '{ printf("%.f",$1*100) }'`  
         echo $t
                                                                                                         
 done
}


get_accepted_shares(){

local total=0
for (( i=1; i <= $(get_acorn_count); i++ )); do                                                                                                                                                                    
                                                                                                                                                                                                                   
   local t=`tail -n 300 $LOG_NAME | grep -a "$(echo $i | awk '{printf("A-%d",$1)}')" | tail -n 2 | head -n 1 | cut -d "/" -f7 | sed 's/ //g' | awk '{ printf("%.f",$1*1) }'`
   let total=total+$t  
done

echo $total
}


get_rejected_shares(){                                                                                                                                                                                             
                                                                                                                                                                                                                   
local total=0                                                                                                                                                                                                      
for (( i=1; i <= $(get_acorn_count); i++ )); do                                                                                                                                                                    
                                                                                                                                                                                                                   
   local t=`tail -n 300 $LOG_NAME | grep -a "$(echo $i | awk '{printf("A-%d",$1)}')" | tail -n 2 | head -n 1 | cut -d "/" -f9 | sed 's/ //g' | awk '{ printf("%.f",$1*1) }'`                                               
   let total=total+$t                                                                                                                                                                                              
done                                                                                                                                                                                                               
                                                                                                                                                                                                                   
echo $total                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                              
} 


get_miner_uptime(){
ps -p `pidof AcornMiner` -o etimes= | sed 's/ //g' | awk '{ printf("%d",$1) }'
}

get_total_hashes(){
 local Total=`tail -n 300 ${LOG_NAME} | grep -a "Total Hashrate" | tail -n 1 | cut -d ":" -f3 | cut -d "M" -f1 | sed 's/ //g' | awk '{printf "%.f",$1*1000}'`
 echo $Total
}


main(){

. ./h-manifest.conf
local LOG_NAME="$CUSTOM_LOG_BASENAME.log"

local hs=
get_cards_hashes					# hashes array
local hs_units='khs'				# hashes utits
local temp=$(get_acorns_temp) 
   #get_acorns_temp	# cards temp
local fan=$(get_acorns_vcc)		# cards fan
local uptime=$(get_miner_uptime)	# miner uptime
local algo="SHA-3"					# algo

# A/R shares by pool
    local ac=$(get_accepted_shares)
    local rj=$(get_rejected_shares)

# make JSON
stats=$(jq -nc \
            --argjson hs "`echo ${hs[@]} | tr " " "\n" | jq -cs '.'`" \
            --arg hs_units "$hs_units" \
            --argjson temp "`echo ${temp[@]} | tr " " "\n" | jq -cs '.'`" \
            --argjson fan "`echo ${fan[@]} | tr " " "\n" | jq -cs '.'`" \
            --arg uptime "$uptime" \
            --arg ac $ac --arg rj "$rj" \
            --arg algo "$algo" \
            '{$hs, $hs_units, $temp, $fan, $uptime, ar: [$ac, $rj], $algo}')
# total hashrate in khs
khs=$(get_total_hashes)

# debug output
#echo temp:  $temp
#echo fan:   $fan
#echo stats: $stats
#echo total hash rate:   $khs
#echo log path: $LOG_NAME
#echo $CUSTOM_LOG_BASENAME
#echo diff time: $diffTime
#echo acorn count: $(get_acorn_count)
#echo accepted shares: $(get_accepted_shares)
#echo rejected shares: $(get_rejected_shares)
}

#######################
# MAIN script body
#######################
. /hive/miners/custom/$CUSTOM_MINER/h-manifest.conf
main

