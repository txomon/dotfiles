for d in `find ~/.gem/ruby/ 2>/dev/null | grep -e "/bin$"`; do
	export PATH=$d:$PATH
done

