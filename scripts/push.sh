function prepushHook() {
	#add your custom calls
	echo "Excecuting pre push hooks.."
	#TODO: read and execute external script
	eval "$1='1'"
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
			echo "Prepush hooks failed"
		else
			git push
		fi 	 
	else
	    echo "Diverged"
	fi
}

