echo "Assembling scripts"
if [ -f 'gitscripts-all.sh' ]; then
	rm gitscripts-all.sh
fi	
touch gitscripts-all.sh
cat ./scripts/mainscripts.sh >> gitscripts-all.sh
cat ./scripts/commit.sh >> gitscripts-all.sh
cat ./scripts/push.sh >> gitscripts-all.sh
echo "Assembly complete"
