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


function commit(){
	# has to be line broken in several lines because of zsh
	local nothing_to_commit
	nothing_to_commit=`git status | grep "nothing to commit" | wc -l`
	local nothing_added_to_commit
	nothing_added_to_commit=`git status | grep "nothing added to commit" | wc -l`	
	local no_changes_added
	no_changes_added=`git status | grep "no changes added to commit" | wc -l`	
	# remove whitespace
	nothing_added_to_commit="$(echo -e "${nothing_added_to_commit}" | tr -d '[[:space:]]')"
	nothing_to_commit="$(echo -e "${nothing_to_commit}" | tr -d '[[:space:]]')"
	no_changes_added="$(echo -e "${no_changes_added}" | tr -d '[[:space:]]')"
	
	if [ "1" != "$nothing_to_commit" ] && [ "1" != "$nothing_added_to_commit" ] && [ "1" != "$no_changes_added" ]; then

    	touch /tmp/last_pair
    	touch /tmp/last_story
		
    	local last_pair
		last_pair=`cat /tmp/last_pair`
    	local last_story
		last_story=`cat /tmp/last_story`

		printf 'pair [%s]:' "$last_pair"
    	read  pair
		printf 'story [%s]:' "$last_story"
		pair=${pair:-$last_pair}
    	read  story
		story=${story:-$last_story}
		printf '%s ' 'message:'
    	read  message
		
    	git commit -m "${pair}|${story}|${message}"

    	echo "${story}" > /tmp/last_story
    	echo "${pair}" > /tmp/last_pair
	else	
		echo 'Nothing available to commit.'
	fi
}
#
#
#	This script pushes current commits if:
#		- There is somthing to push
#		- The branches have not diverged
#		- The remote branch is not ahead
#		- the precommit hooks (specified as bash commands in precommit_hooks.sh) ran succesfully
#
#   Usage: 'pushitgood' 
#

function pushitgood() {
	
	__print_pushitgood
	
	__checkForOpenChanges run
	
	if [ "0" = "$run" ]; then
		return 0
	fi
		
	git remote update 

	echo "Comparing local to remote revision..."
	LOCAL=$(git rev-parse @)
	REMOTE=$(git rev-parse @{u})
	BASE=$(git merge-base @ @{u})

	if [ $LOCAL = $REMOTE ]; then
	    echo -e "\033[31mNothing to push."
	elif [ $LOCAL = $BASE ]; then
	    echo -e "\033[31mRemote is ahead, please pull first."
	elif [ $REMOTE = $BASE ]; then
		return_value=''
		runtests return_value
		if [ "1" = "$return_value" ]; then
			
			git push			
			if [ $? -eq 0 ]; then
			 	__print_success
			else
				__print_failed
			fi   
		else
			__print_failed	                                                                                               
		fi 	
	else
	    echo -e "\033[31m Branches have diverged. Please pull first."
	fi
}

# Counts commits for a certain given author for either the current dir or the directories one below
# Parameter: $1 for the authors name
function countCommitsForAuthor()  {
    echo "Finding commits for $1"
        (
        if [ -d "./.git" ];then
           git shortlog -s -n --all --no-merges | grep $1
        else
           for dir in ./*/
            do
                dir=${dir%*/}
                echo "Checking commit counts for ${dir##*/}"
                (cd ${dir} && git shortlog HEAD -s -n --all --no-merges | grep $1 )
            done
          fi
        echo 'Done.'
        )
}

function runtests() {
	
	if [ -f "prepush_hooks.sh" ]; then
		echo "Executing pre push hooks..."


		# Internal variable to store the time elapsed
		SECONDS=0
		
		while read SCRIPTLINE
		do
		    eval "$SCRIPTLINE"
			if [ $? -eq 0 ]; then
				echo -e "\033[32m>> $SCRIPTLINE ran successfully." 
			else
				echo -e "\033[31m>> $SCRIPTLINE failed."
				return 0
			fi
		done < prepush_hooks.sh
		printf 'Finished executing pre push hooks in: %s seconds.' "$SECONDS"

		eval "$1='1'" 
	else
		echo "No prepush_hooks.sh found."
		printf "Do you want to push anyway (y/n)?"
    	read yn
		if [ "$yn" = "y" ]; then
			eval "$1='1'" 
		else
			eval "$1='0'" 
		fi
	fi
}

function __checkForOpenChanges(){
	if git diff-index --quiet HEAD --; then
	    eval "$1='1'" 
	else
		git status
		echo "There are uncommited changes!"
		printf "Do you want to push anyway (y/n)?"
    	read yn
		if [ "$yn" = "y" ]; then
			eval "$1='1'" 
		else
			eval "$1='0'" 
		fi
	fi
}


function __print_failed(){
	echo -e '\033[31m
	$$$$$$$$\  $$$$$$\  $$$$$$\ $$\       $$$$$$$$\ $$$$$$$\  
	$$  _____|$$  __$$\ \_$$  _|$$ |      $$  _____|$$  __$$\ 
	$$ |      $$ /  $$ |  $$ |  $$ |      $$ |      $$ |  $$ |
 	$$$$$\    $$$$$$$$ |  $$ |  $$ |      $$$$$\    $$ |  $$ |
	$$  __|   $$  __$$ |  $$ |  $$ |      $$  __|   $$ |  $$ |
	$$ |      $$ |  $$ |  $$ |  $$ |      $$ |      $$ |  $$ |
	$$ |      $$ |  $$ |$$$$$$\ $$$$$$$$\ $$$$$$$$\ $$$$$$$  |
	\__|      \__|  \__|\______|\________|\________|\_______/                                                           
 	\e[0m
	'
}

function __print_success(){
	echo -e '\033[32m
    $$$$$$\  $$\   $$\  $$$$$$\   $$$$$$\  $$$$$$$$\  $$$$$$\   $$$$$$\  
   $$  __$$\ $$ |  $$ |$$  __$$\ $$  __$$\ $$  _____|$$  __$$\ $$  __$$\ 
   $$ /  \__|$$ |  $$ |$$ /  \__|$$ /  \__|$$ |      $$ /  \__|$$ /  \__|
   \$$$$$$\  $$ |  $$ |$$ |      $$ |      $$$$$\    \$$$$$$\  \$$$$$$\  
    \____$$\ $$ |  $$ |$$ |      $$ |      $$  __|    \____$$\  \____$$\ 
   $$\   $$ |$$ |  $$ |$$ |  $$\ $$ |  $$\ $$ |      $$\   $$ |$$\   $$ |
   \$$$$$$  |\$$$$$$  |\$$$$$$  |\$$$$$$  |$$$$$$$$\ \$$$$$$  |\$$$$$$  |
    \______/  \______/  \______/  \______/ \________| \______/  \______/ 
    \e[0m
	'
}

function __print_pushitgood(){
	echo -e '\033[33m
	$$$$$$$\  $$\   $$\  $$$$$$\  $$\   $$\       $$$$$$\ $$$$$$$$\        $$$$$$\   $$$$$$\   $$$$$$\  $$$$$$$\  $$\ 
	$$  __$$\ $$ |  $$ |$$  __$$\ $$ |  $$ |      \_$$  _|\__$$  __|      $$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\ $$ |
	$$ |  $$ |$$ |  $$ |$$ /  \__|$$ |  $$ |        $$ |     $$ |         $$ /  \__|$$ /  $$ |$$ /  $$ |$$ |  $$ |$$ |
	$$$$$$$  |$$ |  $$ |\$$$$$$\  $$$$$$$$ |        $$ |     $$ |         $$ |$$$$\ $$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |
	$$  ____/ $$ |  $$ | \____$$\ $$  __$$ |        $$ |     $$ |         $$ |\_$$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |\__|
	$$ |      $$ |  $$ |$$\   $$ |$$ |  $$ |        $$ |     $$ |         $$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |    
	$$ |      \$$$$$$  |\$$$$$$  |$$ |  $$ |      $$$$$$\    $$ |         \$$$$$$  | $$$$$$  | $$$$$$  |$$$$$$$  |$$\ 
	\__|       \______/  \______/ \__|  \__|      \______|   \__|          \______/  \______/  \______/ \_______/ \__|                                                                                                                                         
   	\e[0m
	'
}

