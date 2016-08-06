function activate --no-scope-shadowing
	set oldpwd $PWD
	while true
		test -f $PWD/ve$argv[1]/bin/activate.fish
		if test -f $PWD/bin/activate.fish
			source $PWD/bin/activate.fish
			break
		else if test -f $PWD/ve$argv[1]/bin/activate.fish
			source $PWD/ve$argv[1]/bin/activate.fish
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
