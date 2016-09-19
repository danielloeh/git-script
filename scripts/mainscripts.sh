#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

addToBashRC(){
	# TODO: extend it to more bash specific files
	is_already_in_bashrc=`cat ~/.bashrc | grep "gitscripts-all" | wc -l`
	is_already_in_bashrc="$(echo -e "${is_already_in_bashrc}" | tr -d '[[:space:]]')"
	
	if [ "1" != "$is_already_in_bashrc" ]; then
		printf '%s' 'Do you want to append to source this script to your bashrc? (y/n)'
		read  yn
		if [ "$yn" = "y" ]; then
			if [ -f ~/.bashrc ]; then	
				echo "source $SCRIPT_DIR/gitscripts-all.sh" >>~/.bashrc	
			else 
				echo ".bashrc does not exist"
			fi
		else
			break;
		fi
	else 
		echo "gitscripts is already in bashrc, please change manually"
	fi
}


stashall()  {
	(
	if [ -d "./.git" ]
	then
		echo "$PWD is git root, stashing locally"
		git stash
	else
		echo "$PWD is no git root, stashing subfolders"
		find . -mindepth 1 -maxdepth 1 -type d -print -exec git -C {} stash \;
	fi
		echo 'Done.'
	)
}

pullall()  {
	(
	if [ -d "./.git" ]
	then
		echo "$PWD is git root, pulling locally"
		git pull --rebase
	else
		echo "$PWD is no git root, pulling subfolders"
		find . -mindepth 1 -maxdepth 1 -type d -print -exec git -C {} pull --rebase \;
	fi
	echo 'Done.'
	)
}

statusall(){
	(
	if [ -d "./.git" ]
	then
		echo "$PWD is git root, getting status of current project"
		git status
	else
		echo "$PWD is no git root, getting status of subfolders"
		find . -mindepth 1 -maxdepth 1 -type d -print -exec git -C {} status \;
	fi
		echo 'Done.'
	)
}


