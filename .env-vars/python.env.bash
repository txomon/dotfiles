function activate {
	oldpwd=$PWD
	if [ "$1" ]; then
		dirname="$1"
	else
		dirname=$(basename $PWD)
	fi
	while true; do
		if [ -f "$PWD/bin/activate" ]; then
			source $PWD/bin/activate
			break
		elif [ -f "$PWD/ve$dirname/bin/activate" ]; then
			source $PWD/ve$dirname/bin/activate
			break
		elif [ "x" = "x$1" -a -f "$PWD/ve/bin/activate" ]; then
			source $PWD/ve/bin/activate
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
alias pact=activate
