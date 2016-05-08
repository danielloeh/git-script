function prepushHook() {
	echo "Executing prepush hooks..."
	return 1;
}

function pushitgood() {
	
	up_to_date_with_master=`git status | grep "up-to-date" | wc -l`
	# remove whitespace
	up_to_date_with_master="$(echo -e "${up_to_date}" | tr -d '[[:space:]]')"
	
	if [ "1" != "$up-to-date" ]; then

	
		wasSuccessful=prepushHook
		
		if [ "1" != "$wasSuccessful" ]; then
			echo "Prepush hooks failed"
			exit 0
		else
			git push
		fi 	 
	else	
		echo 'Nothing available to push.'
	fi
}

