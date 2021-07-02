if [ -f /usr/share/nvm/init-nvm.sh ]; then
	source /usr/share/nvm/init-nvm.sh
fi
function nactivate {
	oldpwd=$PWD

	while true; do
		if [ -d "$PWD/node_modules/.bin" ]; then
			#Delete any other node path and inster ours
			export PATH=$(echo $PATH | perl -pe "s/(.*?)([\w\/]*node_modules\/.bin:|:[\w\/]*node_modules\/.bin)(.*)/\1\3/p")
			export PATH=$PATH:$PWD/node_modules/.bin
			break
		else
			cd ..
			if [ $(pwd) = "/" ]; then
				break
			fi
		fi
	done
	cd $oldpwd
	unset oldpwd
}
