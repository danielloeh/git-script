#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

addToBashRC(){
	# TODO: extend it to more bash specific files
	is_already_in_bashrc=`cat ~/.bashrc | grep "gitscripts" | wc -l`
	is_already_in_bashrc="$(echo -e "${is_already_in_bashrc}" | tr -d '[[:space:]]')"
	
	if [ "1" != "$is_already_in_bashrc" ]; then
		printf '%s' 'Do you want to append to source this script to your bashrc? (y/n)'
		read  yn
		if [ "$yn" = "y" ]; then
			if [ -f ~/.bashrc ]; then	
				echo "source $SCRIPT_DIR/gitscripts.sh" >>~/.bashrc	
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

initZshRC(){
	printf '%s' 'Do you want to append to source this script to your .zshrc? (y/n)'
	read  yn
	if [ "$yn" = "y" ]; then
		if [ -f "~/.zshrc" ]; then
			echo 'source $SCRIPT_DIR/gitscripts.sh' >>~/.zshrc
		else 
			echo ".zshrc does not exist"
		fi
	else
		break;
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

upto ()
{
    if [ -z "$1" ]; then
        return
    fi
    local upto=$1
    cd "${PWD/\/$upto\/*//$upto}"
}

_upto_bash()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local d=${PWD//\//\ }
    COMPREPLY=( $( compgen -W "$d" -- "$cur" ) )
}

#TODO: autocomplete with zsh not working yet
_upto_zsh()
{
    local word completions
    word="$1"
    completions=${PWD//\//\ }
	echo completions
    reply=${completions[@]}
}

#auto complete for zsh
if [ "$SHELL" = "/bin/zsh" ]; then
	compctl -K _upto_zsh upto
else #for all other shells
	complete -F _upto_bash upto
fi


