function git-conflict-split
	for file in (git ls-files -u | cut -c 51- | sort -u)
		rm $file
		git checkout-index --stage 3 -- $file
		mv $file $file.THEIRS
		git checkout-index --stage 2 -- $file
		mv $file $file.OURS
		git checkout-index --stage 1 -- $file
		echo "meld $file.OURS $file $file.THEIRS"
	end
end
