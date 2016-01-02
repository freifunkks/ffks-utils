#!/bin/bash
# Interactively add a fastd peer to github repo

red='\033[0;31m'
green='\033[0;32m'
cyan='\033[0;36m'
nc='\033[0m' # no color

function parsed_as() {
	echo -e "${nc}\n  I parsed this as:\n    ${cyan}${1}${nc}"
	echo -en "\n  Is this correct? (${green}y${nc}/${red}N${nc}) ${cyan}"
}

function enter_name() {
	echo -en "  Please enter the name of the peer: ${cyan}\n    "
	read name
	echo -e "${nc}"
	sanitize "$name"; name="$ret"
	check_name || (echo -e "  ${red}Error parsing name... Cannot be empty!${nc}"; enter_name)
	parsed_as "${name}"
	read answer
	echo -e "${nc}"
	if [[ "$answer" == "y" ]]; then
		return
	fi
	echo -e "  OK, then please try again..."
	enter_name
}

function enter_key() {
	echo -en "  Please enter the public key of the peer: ${cyan}\n    "
	read key
	echo -e "${nc}"
	sanitize "$key"; key="$ret"
	check_key || (echo -e "  ${red}Error parsing key... Must be alphanumeric string of length 32!${nc}"; enter_key)
	parsed_as "${key}"
	read answer
	echo -e "${nc}"
	if [[ "$answer" == "y" ]]; then
		return
	fi
	echo -e "  OK, then please try again..."
	enter_key
}

function sanitize() {
	ret=$1
	# remove leading comments and possible whitespaces
	ret=$(echo $ret | sed 's/^# *//')
	# remove trailing spaces
	ret=$(echo $ret | sed 's/ *&//')
}

function check_name() {
	# [a-z0-9]+
	echo $name | grep -qc '[a-z0-9]\+' 
	return $?
}

function check_key() {
	# [a-z0-9]{32}
	echo $key | grep -qc '[a-z0-9]\{32\}' 
	return $?
}

echo "Adding a new fastd peer..."
enter_name
enter_key

echo "Generating key file..."
file="# ${name}\n# $(date --iso-8601)\nkey \"${key}\";"
echo -e "${file}" | sed 's/^/  /'
echo -e "${file}" > ${name}

echo "Commiting to GitHub..."
git add ${name}
git commit -m "Add ${name}"
git push

