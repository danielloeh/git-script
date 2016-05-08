function commit(){
	nothing_to_commit=`git status | grep "nothing to commit" | wc -l`
	nothing_added_to_commit=`git status | grep "nothing added to commit" | wc -l`	
	no_changes_added=`git status | grep "no changes added to commit" | wc -l`	
	# remove whitespace
	nothing_added_to_commit="$(echo -e "${nothing_added_to_commit}" | tr -d '[[:space:]]')"
	nothing_to_commit="$(echo -e "${nothing_to_commit}" | tr -d '[[:space:]]')"
	no_changes_added="$(echo -e "${no_changes_added}" | tr -d '[[:space:]]')"
	
	if [ "1" != "$nothing_to_commit" ] && [ "1" != "$nothing_added_to_commit" ] && [ "1" != "$no_changes_added" ]; then

    	touch /tmp/last_pair
    	touch /tmp/last_story
		
    	last_pair=`cat /tmp/last_pair`
    	last_story=`cat /tmp/last_story`

		printf 'pair [%s]:' $last_pair
    	read  pair
		printf 'story [%s]:' $last_story
		pair=${pair:-$last_pair}
    	read  story
		story=${story:-$last_story}
		printf '%s ' 'message:'
    	read  message
		
    	git commit -m "${story}|${pair}|${message}"

    	echo "${story}" > /tmp/last_story
    	echo "${pair}" > /tmp/last_pair
	else	
		echo 'Nothing available to commit.'
	fi
	
}
