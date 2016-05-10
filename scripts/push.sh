function prepushHook() {
	
	if [ -f "prepush_hooks.sh" ]; then
		echo "Executing pre push hooks..."
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
		
		eval "$1='1'" 
	else
		echo "No prepush_hooks.sh found."
	fi
}

function pushitgood() {

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
		retval=''
		prepushHook retval
		if [ "1" != "$retval" ]; then
			echo -e "\033[31m#########################"
			echo -e "\033[31m######   FAILED    ######"
			echo -e "\033[31m# Pre push hooks failed #"
			echo -e "\033[31m#########################"
		else
			echo -e "\033[32m#########################"
			echo -e "\033[32m######## SUCCESS ########"
			echo -e "\033[32m#########################"
			echo "Pushing..."
			git push
		fi 	 
	else
	    echo -e "\033[31m Diverged."
	fi
}

