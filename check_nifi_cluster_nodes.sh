#!/bin/bash

function get_nifi_nodes_status() {
	
	nodes=($(/usr/bin/curl -k -s "https://${1}:${2}/nifi-api/controller/cluster/" | python -m json.tool))
	
	exit_code=3
	
	for (( i=0 ; i < ${#nodes[@]} ; i++ ))
	do
			if [ ${nodes[i]} == '"address":' ]
			then
			#       echo ${nodes[i]}
					servers="${servers}${nodes[i+1]}"
			fi
			if [ ${nodes[i]} == '"status":' ]
			then
			#       echo ${nodes[i+1]}
					status=("${status[@]}" "${nodes[i+1]}")
			fi
	done
	
	
	for (( k=0 ; k < ("${#status[@]}") ; k++ ))
	do
			if [ ${status[k]} == '"CONNECTED"' ]
			then
					((count++))
			fi
	done
	
	for (( i=0 ; i < ("${#servers[@]}"+"${#status[@]}")  ; i++ ))
	do
			join=("${join[@]}" "${servers[i]}" "${status[i]}")
	done
	
	echo ${join[@]}
	if [ $count != ${#status[@]} ]
	then
			echo "Not all nodes are connected to the cluster"
			exit_code=0
			exit $exit_code
	else
			echo "All nodes are connected to the cluster"
			exit_code=2
			exit $exit_code
	fi
}


##MAIN
while getopts ':hip:' OPTION; do
	case "$OPTION" in
		i ) 
			ip=$OPTARG
			;;
		p )
			port=$OPTARG
			;;
		h )
			echo "The options for the script are:"
			echo ""
			echo "-i enter the IP of the host"
			echo "-p enter the PORT of the host"
			exit 0
			;;
		\? )
			echo "Invalid option: $OPTARG, please use -h to see the options" 1>&2
			exit 2
			;;
	esac
done
shift $((OPTIND -1))

get_nifi_nodes_status "${ip}" "${port}"
