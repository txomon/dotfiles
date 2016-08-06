function activate {
	oldpwd=$PWD
	while true; do
		if [ -f "$PWD/bin/activate" ]; then
			source $PWD/bin/activate
			break
		elif [ -f "$PWD/ve$1/bin/activate" ]; then
			source $PWD/ve$1/bin/activate
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
