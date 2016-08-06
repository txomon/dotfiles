function activate --no-scope-shadowing
	set oldpwd $PWD
	while true
		test -f $PWD/ve$argv[1]/bin/activate.fish
		echo $status
		if test -f $PWD/bin/activate.fish
			echo "Found $PWD/bin/activate.fish"
			source $PWD/bin/activate.fish
			break
		else if test -f $PWD/ve$argv[1]/bin/activate.fish
			echo "Found $PWD/ve$argv[1]/bin/activate.fish"
			source $PWD/ve$argv[1]/bin/activate.fish
			break
		else
			echo "Nothing found in $PWD, going up"
			echo "Not found $PWD/bin/activate.fish"
			echo "Not found $PWD/ve$argv[1]/bin/activate.fish"
			cd ..
			if test "$PWD" = "/"
				echo "Nothing found"
				break
			end
		end
	end
	cd $oldpwd
	set -q oldpwd
end
alias pact=activate
