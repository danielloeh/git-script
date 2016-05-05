#!/bin/bash
if [[ -z "$PROJECT_ROOT" ]]
then
  echo "Using projectroot$PROJECT_ROOT"
else 
	PROJECT_ROOT="$PWD"
	echo "Using current dir: $PROJECT_ROOT"
fi
	
	
PROJECT_ROOT="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

stashall()  {
	(
	cd $PROJECT_ROOT 
	find . -mindepth 1 -maxdepth 1 -type d -print -exec git -C {} stash \;
	)
}

pullall()  {
	(
	cd $PROJECT_ROOT 
	find . -mindepth 1 -maxdepth 1 -type d -print -exec git -C {} pull --rebase \;
	)
}

showchanges(){
	(
	cd $PROJECT_ROOT 
	find . -mindepth 1 -maxdepth 1 -type d -print -exec git -C {} status \;
	)
}

launchAtStartZSH(){
	echo $SCRIPT_DIR
	# tmp="$pwd"
	# goto user dir
	# check for .zshrc
	# if not exists, break or create
	# if exists, append line: 
	# export PROJECT_ROOT=tmp
	# source $SCRIPT_DIR/functions.sh &> /dev/null
}

launchAtStartBASHRC(){
	# tmp="$pwd"
	# goto user dir
	# check for .bashrc 
	# .bash_profile
	# if not exists, break or create
	# if exists, append line: 
	# export PROJECT_ROOT=tmp
	# source $SCRIPT_DIR/functions.sh &> /dev/null
}

gadd(){
	echo "addit"
}


gcommit(){
	echo "commitit"
}

projectHooks(){
	echo 'hooks'
}

pushitgood(){
	git status;
	while true; do
		printf '%s ' 'Do you wish to add and commit the remaining changes? yn'
	    read -q yn
	    case $yn in
	        [Yy]* ) gadd(); break;;
			[Nn]* ) break;;
	        * ) echo "Please answer y or n.";;
	    esac
	done
}

export -f stashall
export -f pullall
export -f showchanges
export -f launchAtStartZSH
export -f launchAtStartBASHRC
export -f gadd
export -f gcommit
export -f projectHooks
export -f pushitgood