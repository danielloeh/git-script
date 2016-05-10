function prepushHook() {
	#add your custom calls
	if [ -f "prepush_hooks.sh" ]; then
		echo "Excecuting pre push hooks."
		sh prepush_hooks.sh
		eval "$1='1'"
	else
		echo "No prepush_hooks.sh found."
		eval "$1='0'"
	fi
}

function pushitgood() {
	
	#fetching remote status
	git remote update 
	
	#comparing local to remote revision
	LOCAL=$(git rev-parse @)
	REMOTE=$(git rev-parse @{u})
	BASE=$(git merge-base @ @{u})

	if [ $LOCAL = $REMOTE ]; then
	    echo "Nothing to push."
	elif [ $LOCAL = $BASE ]; then
	    echo "Remote is ahead, please pull first."
	elif [ $REMOTE = $BASE ]; then
		retval=''
		prepushHook retval
		if [ "1" != "$retval" ]; then
			echo "Prepush hooks failed."
		else
			git push
		fi 	 
	else
	    echo "Diverged"
	fi
}

