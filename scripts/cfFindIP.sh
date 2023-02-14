#!/bin/bash  -
#===============================================================================
#
#          FILE: cfFindIP.sh
#
#         USAGE: ./cfFindIP.sh [ThreadCount]
#
#   DESCRIPTION: Scan all 1.5 Mil CloudFlare IP addresses
#
#       OPTIONS: ---
#  REQUIREMENTS: ThreadCount (integer Number which defines the parallel processes count)
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Morteza Bashsiz (mb), morteza.bashsiz@gmail.com
#  ORGANIZATION: Linux
#       CREATED: 01/24/2023 07:36:57 PM
#      REVISION:  1 by Nomad
#===============================================================================

#set -o nounset                                  # Treat unset variables as an error

# Function fncShowProgress
# Progress bar maker function (based on https://www.baeldung.com/linux/command-line-progress-bar)
function fncShowProgress {
	current="$1"
  	total="$2"

  	barSize="$(($(tput cols)-70))" # 70 cols for description characters

  	# calculate the progress in percentage 
  	percent=$(bc <<< "scale=$barPercentageScale; 100 * $current / $total" )
  	# The number of done and todo characters
  	done=$(bc <<< "scale=0; $barSize * $percent / 100" )
  	todo=$(bc <<< "scale=0; $barSize - $done")
  	# build the done and todo sub-bars
  	doneSubBar=$(printf "%${done}s" | tr " " "${barCharDone}")
  	todoSubBar=$(printf "%${todo}s" | tr " " "${barCharTodo} - 1") # 1 for barSplitter
  	spacesSubBar=$(printf "%${todo}s" | tr " " " ")

  	# output the bar
  	progressBar="| Progress bar of main IPs: [${doneSubBar}${barSplitter}${todoSubBar}] ${percent}%${spacesSubBar}" # Some end space for pretty formatting
}
# End of Function showProgress

# Function fncCheckSubnet
# Check Subnet
function fncCheckSubnet {
	local ipList scriptDir resultFile timeoutCommand domainFronting
	ipList="${1}"
	resultFile="${3}"
	scriptDir="${4}"
	configId="${5}"
	configHost="${6}"
	configPort="${7}"
	configPath="${8}"
	configServerName="${9}"
	frontDomain="${10}"
	scanDomain="${11}"
	downloadFile="${12}"
	osVersion="${13}"
	v2rayCommand="v2ray"
	configDir="$scriptDir/../config"
	# set proper command for linux
	if command -v timeout >/dev/null 2>&1; 
	then
	    timeoutCommand="timeout"
	else
		# set proper command for mac
		if command -v gtimeout >/dev/null 2>&1; 
		then
		    timeoutCommand="gtimeout"
		else
		    echo >&2 "I require 'timeout' command but it's not installed. Please install 'timeout' or an alternative command like 'gtimeout' and try again."
		    exit 1
		fi
	fi
	# set proper command for v2ray
	if [[ "$osVersion" == "Linux" ]]
	then
		v2rayCommand="v2ray"
	elif [[ "$osVersion" == "Mac"  ]]
	then
		v2rayCommand="v2ray-mac"
	else
		echo "OS not supported only Linux or Mac"
		exit 1
	fi
	for ip in ${ipList}
		do
			if $timeoutCommand 1 bash -c "</dev/tcp/$ip/443" > /dev/null 2>&1;
			then
				domainFronting=$($timeoutCommand 2 curl -s -w "%{http_code}\n" --tlsv1.2 -servername "$frontDomain" -H "Host: $frontDomain" --resolve "$frontDomain":443:"$ip" https://"$frontDomain" -o /dev/null | grep '200')
				if [[ "$domainFronting" == "200" ]]
				then
					ipConfigFile="$configDir/config.json.$ip"
					cp "$scriptDir"/config.json.temp "$ipConfigFile"
					ipO1=$(echo "$ip" | awk -F '.' '{print $1}')
					ipO2=$(echo "$ip" | awk -F '.' '{print $2}')
					ipO3=$(echo "$ip" | awk -F '.' '{print $3}')
					ipO4=$(echo "$ip" | awk -F '.' '{print $4}')
					port=$((ipO1 + ipO2 + ipO3 + ipO4))
					if [[ "$osVersion" == "Mac" ]]
					then
						sed -i "" "s/IP.IP.IP.IP/$ip/g" "$ipConfigFile"
						sed -i "" "s/PORTPORT/3$port/g" "$ipConfigFile"
						sed -i "" "s/IDID/$configId/g" "$ipConfigFile"
						sed -i "" "s/HOSTHOST/$configHost/g" "$ipConfigFile"
						sed -i "" "s/CFPORTCFPORT/$configPort/g" "$ipConfigFile"
						sed -i "" "s/ENDPOINTENDPOINT/$configPath/g" "$ipConfigFile"
						sed -i "" "s/RANDOMHOST/$configServerName/g" "$ipConfigFile"
					elif [[ "$osVersion" == "Linux" ]]
					then
						sed -i "s/IP.IP.IP.IP/$ip/g" "$ipConfigFile"
						sed -i "s/PORTPORT/3$port/g" "$ipConfigFile"
						sed -i "s/IDID/$configId/g" "$ipConfigFile"
						sed -i "s/HOSTHOST/$configHost/g" "$ipConfigFile"
						sed -i "s/CFPORTCFPORT/$configPort/g" "$ipConfigFile"
						sed -i "s/ENDPOINTENDPOINT/$configPath/g" "$ipConfigFile"
						sed -i "s/RANDOMHOST/$configServerName/g" "$ipConfigFile"
					fi
					# shellcheck disable=SC2009
					pid=$(ps aux | grep config.json."$ip" | grep -v grep | awk '{ print $2 }')
					if [[ "$pid" ]]
					then
						kill -9 "$pid"
					fi
					nohup "$scriptDir"/"$v2rayCommand" -c "$ipConfigFile" > /dev/null &
					sleep 2
					timeMil=$($timeoutCommand 2 curl -x "socks5://127.0.0.1:3$port" -s -w "TIME: %{time_total}\n" https://"$scanDomain"/"$downloadFile" --output /dev/null | grep "TIME" | tail -n 1 | awk '{print $2}' | xargs -I {} echo "{} * 1000 /1" | bc )
					# shellcheck disable=SC2009
					pid=$(ps aux | grep config.json."$ip" | grep -v grep | awk '{ print $2 }')
					if [[ "$pid" ]]
					then
						kill -9 "$pid" > /dev/null 2>&1
					fi
					if [[ "$timeMil" ]] && [[ "$timeMil" != 0 ]]
					then
						echo -e "${GREEN}OK${NC} $ip ${BLUE}ResponseTime $timeMil${NC}" 
						echo "$timeMil $ip" >> "$resultFile"
					else
						echo -e "${YELLOW}FAILED${NC} $ip"
					fi
				else
					echo -e "${YELLOW}FAILED${NC} $ip"
				fi
			else
				echo -e "${YELLOW}FAILED${NC} $ip"
			fi
	done
}
# End of Function fncCheckSubnet
export -f fncCheckSubnet

# Function fncCheckDpnd
# Check for dipendencies
function fncCheckDpnd {
	osVersion="Linux"
	if [[ "$(uname)" == "Linux" ]]; then
			osVersion="Linux"
	    command -v parallel >/dev/null 2>&1 || { echo >&2 "I require 'parallel' but it's not installed. Please install it and try again."; exit 1; }
	    command -v nmap >/dev/null 2>&1 || { echo >&2 "I require 'nmap' but it's not installed. Please install it and try again."; exit 1; }
	    command -v bc >/dev/null 2>&1 || { echo >&2 "I require 'bc' but it's not installed. Please install it and try again."; exit 1; }
			command -v timeout >/dev/null 2>&1 || { echo >&2 "I require 'timeout' but it's not installed. Please install it and try again."; exit 1; }
	
	elif [[ "$(uname)" == "Darwin" ]];then
			osVersion="Mac"
	    command -v parallel >/dev/null 2>&1 || { echo >&2 "I require 'parallel' but it's not installed. Please install it and try again."; exit 1; }
	    command -v nmap >/dev/null 2>&1 || { echo >&2 "I require 'nmap' but it's not installed. Please install it and try again."; exit 1; }
	    command -v bc >/dev/null 2>&1 || { echo >&2 "I require 'bc' but it's not installed. Please install it and try again."; exit 1; }
	    command -v gtimeout >/dev/null 2>&1 || { echo >&2 "I require 'gtimeout' but it's not installed. Please install it and try again."; exit 1; }
	fi
	echo "$osVersion"
}
# End of Function fncCheckDpnd

# Function fncValidateConfig
# Install packages on destination host
function fncValidateConfig {
	local config
	config="$1"
	if [[ -f "$config" ]]
	then
		echo "reading config ..."
		configId=$(grep "^id" "$config" | awk -F ":" '{ print $2 }' | sed "s/ //g")	
		configHost=$(grep "^Host" "$config" | awk -F ":" '{ print $2 }' | sed "s/ //g")	
		configPort=$(grep "^Port" "$config" | awk -F ":" '{ print $2 }' | sed "s/ //g")	
		configPath=$(grep "^path" "$config" | awk -F ":" '{ print $2 }' | sed "s/ //g" | sed 's/\//\\\//g')	
		configServerName=$(grep "^serverName" "$config" | awk -F ":" '{ print $2 }' | sed "s/ //g")	
		if ! [[ "$configId" ]] || ! [[ $configHost ]] || ! [[ $configPort ]] || ! [[ $configPath ]] || ! [[ $configServerName ]]
		then
			echo "config is not correct"
			exit 1
		fi
	else
		echo "config file does not exist $config"
		exit 1
	fi
}
# End of Function fncValidateConfig

# Function fncCreateDir
# creates needed directory
function fncCreateDir {
	local dirPath
	dirPath="${1}"
	if [ ! -d "$dirPath" ]; then
		mkdir -p "$dirPath"
	fi
}
# End of Function fncCreateDir

# Function fncCheckSpeed
# validates speed return proper downloadFile
function fncCheckSpeed {
	local downloadFile speedList speed
	speed="${1}"
	downloadFile="NULL"
	speedList=(25 50 100 150 200 250 500)
	declare -a downloadFileArr
	downloadFileArr["25"]="data.50k"
	downloadFileArr["50"]="data.100k"
	downloadFileArr["100"]="data.200k"
	downloadFileArr["150"]="data.300k"
	downloadFileArr["200"]="data.400k"
	downloadFileArr["250"]="data.500k"
	downloadFileArr["500"]="data.1000k"
	
	if [[ "${speedList[*]}" =~ $speed ]]
	then
		downloadFile="${downloadFileArr[${speed}]}"
	fi
	echo "$downloadFile"
}
# End of Function fncCheckSpeed

# Function fncMainCFFind
# main Function
function fncMainCFFind {
	local threads progressBar resultFile scriptDir configId configHost configPort configPath configServerName frontDomain scanDomain speed  downloadFile osVersion parallelVersion subnetsFile cloudFlareASNList cloudFlareOkList
	threads="${1}"
	progressBar="${2}"
	resultFile="${3}"
	scriptDir="${4}"
	configId="${5}"
	configHost="${6}"
	configPort="${7}"
	configPath="${8}"
	configServerName="${9}"
	frontDomain="${10}"
	scanDomain="${11}"
	speed="${12}"
	osVersion="${13}"
	subnetsFile="${14}"
	
	cloudFlareASNList=( AS209242 )
	cloudFlareOkList=( 5 23 31 38 45 64 65 66 72 80 89 91 93 95 103 104 108 123 141 146 147 154 156 159 160 162 168 170 172 174 176 185 188 191 192 193 194 195 196 199 202 203 204 205 206 207 208 212 216 )

	parallelVersion=$(parallel --version | head -n1 | grep -Ewo '[0-9]{8}')

	downloadFile="$(fncCheckSpeed "$speed")"
	if [[ "$downloadFile" == "NULL" ]]
	then
		echo "Speed $speed is not valid, choose be one of (25 50 100 150 200 250 500)"
		exit 0
	fi
	if [[ "$subnetsFile" == "NULL" ]]	
	then
		case $IpNo in
        		45) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.45.iplist);;
        		103) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.103.iplist);;
        		104) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.104.iplist);;
        		108) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.108.iplist);;
        		12) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.12.iplist);;
        		123) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.123.iplist);;
        		141) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.141.iplist);;
        		146) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.146.iplist);;
        		147) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.147.iplist);;
        		154) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.154.iplist);;
        		156) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.156.iplist);;
        		159) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.159.iplist);;
        		160) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.160.iplist);;
        		162) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.162.iplist);;
        		168) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.168.iplist);;
        		170) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.170.iplist);;
        		172) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.172.iplist);;
        		174) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.174.iplist);;
        		176) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.176.iplist);;
        		185) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.185.iplist);;
        		188) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.188.iplist);;
        		191) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.191.iplist);;
        		192) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.192.iplist);;
        		193) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.193.iplist);;
        		194) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.194.iplist);;
        		195) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.195.iplist);;
        		196) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.196.iplist);;
        		199) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.199.iplist);;
        		202) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.202.iplist);;
        		203) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.203.iplist);;
        		204) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.204.iplist);;
        		205) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.205.iplist);;
        		206) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.206.iplist);;
        		207) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.207.iplist);;
        		208) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.208.iplist);;
        		212) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.212.iplist);;
        		216) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.216.iplist);;
        		23) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.23.iplist);;
        		31) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.31.iplist);;
        		38) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.38.iplist);;
        		5) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.5.iplist);;
        		64) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.64.iplist);;
        		65) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.66.iplist);;
        		72) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.72.iplist);;
        		80) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.80.iplist);;
        		89) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.89.iplist);;
        		91) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.91.iplist);;
        		93) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.93.iplist);;
        		95) cloudFlareIpList=$(cat "$scriptDir"/ip/cf.95.iplist);;
			*) exit;;
		esac
		ipListLength=$(echo "$cfSubnetList" | wc -l)
		passedIpsCount=0
		for subNet in ${cfSubnetList}
		do
			fncShowProgress "$passedIpsCount" "$ipListLength"
			firstOctet=$(echo "$subNet" | awk -F "." '{ print $1 }')
			if [[ "${cloudFlareOkList[*]}" =~ $firstOctet ]]
			then
				killall v2ray > /dev/null 2>&1
				ipList=$(nmap -sL -n "$subNet" | awk '/Nmap scan report/{print $NF}')
		      		tput cuu1; tput ed # rewrites Parallel's bar
		      		if [[ $parallelVersion -gt "20220515" ]];
		      		then
		        		parallel --ll --bar -j "$threads" fncCheckSubnet ::: "$ipList" ::: "$progressBar" ::: "$resultFile" ::: "$scriptDir" ::: "$configId" ::: "$configHost" ::: "$configPort" ::: "$configPath" ::: "$configServerName" ::: "$frontDomain" ::: "$scanDomain" ::: "$downloadFile" ::: "$osVersion"
		      		else
		        		echo -e "${RED}$progressBar${NC}"
		        		parallel -j "$threads" fncCheckSubnet ::: "$ipList" ::: "$progressBar" ::: "$resultFile" ::: "$scriptDir" ::: "$configId" ::: "$configHost" ::: "$configPort" ::: "$configPath" ::: "$configServerName" ::: "$frontDomain" ::: "$scanDomain" ::: "$downloadFile" ::: "$osVersion"
		      		fi
				killall v2ray > /dev/null 2>&1
			fi
		    	passedIpsCount=$(( passedIpsCount+1 ))
		done
#	else
#		cfSubnetList=$(cat "$subnetsFile")
#		ipListLength=$(echo "$cfSubnetList" | wc -l)
#		passedIpsCount=0
#		for subNet in ${cfSubnetList}
#		do
#			fncShowProgress "$passedIpsCount" "$ipListLength"
#			firstOctet=$(echo "$subNet" | awk -F "." '{ print $1 }')
#			if [[ "${cloudFlareOkList[*]}" =~ $firstOctet ]]
#			then
#				killall v2ray > /dev/null 2>&1
#				ipList=$(nmap -sL -n "$subNet" | awk '/Nmap scan report/{print $NF}')
#		    		tput cuu1; tput ed # rewrites Parallel's bar
#		    		if [[ $parallelVersion -gt "20220515" ]];
#		    		then
#		      			parallel --ll --bar -j "$threads" fncCheckSubnet ::: "$ipList" ::: "$progressBar" ::: "$resultFile" ::: "$scriptDir" ::: "$configId" ::: "$configHost" ::: "$configPort" ::: "$configPath" ::: "$configServerName" ::: "$frontDomain" ::: "$scanDomain" ::: "$downloadFile" ::: "$osVersion"
#		    		else
#		      			echo -e "${RED}$progressBar${NC}"
#		      			parallel -j "$threads" fncCheckSubnet ::: "$ipList" ::: "$progressBar" ::: "$resultFile" ::: "$scriptDir" ::: "$configId" ::: "$configHost" ::: "$configPort" ::: "$configPath" ::: "$configServerName" ::: "$frontDomain" ::: "$scanDomain" ::: "$downloadFile" ::: "$osVersion"
#		    		fi
#				killall v2ray > /dev/null 2>&1
#			fi
#		  	passedIpsCount=$(( passedIpsCount+1 ))
#		done
#	fi
	
	sort -n -k1 -t, "$resultFile" -o "$resultFile"
}
# End of Function fncMainCFFind

function batchspeedtest(){
	resultFile2="$resultDir/$now-result2.cf"
	cloudFlareIpList2=$(awk '{print $2}' "$resultFile")
	ipListLength2=$(echo "$cloudFlareIpList2" | wc -l)
	url=$(sed -n '1p' url.txt)
	domain=$(echo $url | cut -f 1 -d'/')
	file=$(echo $url | cut -f 2- -d'/')
	port=443
        ii=$ipListLength2
        clear
        for subNet2 in ${cloudFlareIpList2}
        do
                ((ii--))
                ipp="$subNet2"
                echo "ip:$ipp being download speed tested! remaining:$ii"
		speed_download=$(curl --resolve $domain:$port:$ipp https://$domain:$port/$file -o /dev/null --connect-timeout 5 --max-time $dTime -w %{speed_download} | awk -F\. '{printf ("%d\n",$1/1024)}')
		if [ ${#speed_download} -eq 4 ]; then
                       sapce=""
                elif [ ${#speed_download} -eq 3 ]; then
                        space=" "
                elif [ ${#speed_download} -eq 2 ]; then
                        space="  "
                elif [ ${#speed_download} -eq 1 ]; then
                        space="   "
		fi
                echo "$speed_download$space kb/s $ipp" >> "$resultFile2"
                clear
        done
	sort -r -k1 -t, "$resultFile2" -o "$resultFile2"
	clear
	echo "Done"
}


read -p "Enter the parallel threads no.(8,16,32,..):" threads
config=./config.real
speed=100
clear

frontDomain="fronting.sudoer.net"
scanDomain="scan.sudoer.net"
downloadFile="data.100k"

now=$(date +"%Y%m%d-%H%M%S")
scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
resultDir="$scriptDir/../result"
resultFile="$resultDir/$now-result.cf"
configDir="$scriptDir/../config"

configId="NULL"
configHost="NULL"
configPort="NULL"
configPath="NULL"
configServerName="NULL"

barCharDone="="
barCharTodo=" "
barSplitter='>'
barPercentageScale=2
progressBar=""

export GREEN='\033[0;32m'
export BLUE='\033[0;34m'
export RED='\033[0;31m'
export ORANGE='\033[0;33m'
export YELLOW='\033[1;33m'
export NC='\033[0m'

fncCreateDir "${resultDir}"
fncCreateDir "${configDir}"
echo "" > "$resultFile"

clear
read -p "Enter the IP Range: " IpNo

osVersion="$(fncCheckDpnd)"
fncValidateConfig "$config"
fncMainCFFind	"$threads"	"$progressBar"	"$resultFile"	"$scriptDir"	"$configId"	"$configHost"	"$configPort"	"$configPath"	"$configServerName"	"$frontDomain"	"$scanDomain"	"$speed" "$osVersion" "$subnetsFile"

clear
echo "Do yoy want to have an extra speed test?"
echo "It may cause you some significant amount of data usage"
read -p " 					      (y/n): " stAllow
if [ "$stAllow" == "y" ]; then
	clear
	echo "For testing the Download speed we need a specific amount of time to spend"
	echo "If your Internet speed is high, enter 5"
	echo "If your Internet speed is medium, enter 10"
	echo "If your Internet speed is low, enter 15"
	read -p "Enter the download time: " dTime
	clear
	batchspeedtest
fi
