if `test -d ~/.bash_aliases.d`; then
	for f in `find ~/.bash_aliases.d -name *.alias`; do
		. $f
	done
fi
