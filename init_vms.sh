#!/bin/bash
# version 0.1
# Choose one or all predefined values from an array
# and do some operations
# I created this script to automate VM preparation after reset

# Predefined arrays
HOSTNAMES=(d5 s5)
USERNAMES=(student root)

function choose_value_from_array {
    # Function to choose one or all values from input array
    # and assign them to output array variable
    #
	# First argument is output array variable
	# Second argument is input array variable
	local __resultvar=$1
	declare -a ARR=("${!2}")
	i=0
	for value in ${ARR[@]}; do
		echo "$i-${value}"
		i=$((i+1))
	done
	echo -n "Choose number or press Enter to choose all:"; read i;
	if [[ "$i" == "" ]]; then
		ARR=${ARR[@]};
	else
		ARR=${ARR[${i}]};
	fi
	eval $__resultvar="('$ARR')"
}

echo "Choose hostnames to work with:"
choose_value_from_array HOSTNAMES HOSTNAMES[@]
echo "Choose usernames to work with:"
choose_value_from_array USERNAMES USERNAMES[@]

for host in ${HOSTNAMES[@]}; do
	for name in ${USERNAMES[@]}; do
		echo "RUNNING SSH-COPY-ID ${name}@${host}"
		ssh-copy-id ${name}@${host}
		if [[ "$?" == "0" && "$name" == "root" ]]; then
			echo "ADD ROOT COMMAND TO THE SYSTEM"
		fi
		echo
	done
done
