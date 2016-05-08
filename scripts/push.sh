function prepushHook() {
	#add your custom calls
	echo "Excecuting pre push hooks.."
	eval "$1='1'"
}

function pushitgood() {
	
	up_to_date_with_master=`git status | grep "up-to-date" | wc -l`
	# remove whitespace
	up_to_date_with_master="$(echo -e "${up_to_date}" | tr -d '[[:space:]]')"
	
	if [ "1" != "$up-to-date" ]; then

		retval=''
		prepushHook retval
		
		if [ "1" != "$retval" ]; then
			echo "Prepush hooks failed"
		else
			git push
		fi 	 
	else	
		echo 'Nothing available to push.'
	fi
}

