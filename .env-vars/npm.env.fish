function nactivate
	set -l oldpwd (pwd)
        while true
                if test -d (pwd)/node_modules/.bin
			set -l NEW_PATH
			for path in (echo $PATH | perl -pe "s/(.*?)([\w\/]*node_modules\/.bin)(.*)/\1\3/p"| sed -e 's/ \//\n\//g');
				set NEW_PATH $path $NEW_PATH
			end
                        set PATH (pwd)/node_modules/.bin $NEW_PATH
                        break
                else
                        cd ..
                        if test (pwd) = "/"
                                break
                        end
                end
        end
	cd $oldpwd
end
