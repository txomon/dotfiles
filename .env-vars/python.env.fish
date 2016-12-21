function activate --no-scope-shadowing
	set oldpwd $PWD
	if test $argv[1]
		set dirname $argv[1]
	else
		set dirname (basename $PWD)
	end
	while true
		if test -f $PWD/bin/activate.fish
			source $PWD/bin/activate.fish
			break
		else if test -f $PWD/ve$dirname/bin/activate.fish
			source $PWD/ve$dirname/bin/activate.fish
			break
		else if test x = "x$argv[1]" -a -f $PWD/ve/bin/activate.fish
			source $PWD/ve/bin/activate.fish
			break
		else
			cd ..
			if test "$PWD" = "/"
				break
			end
		end
	end
	cd $oldpwd
	set -q oldpwd
end
alias pact=activate
