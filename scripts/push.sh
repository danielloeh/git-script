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

