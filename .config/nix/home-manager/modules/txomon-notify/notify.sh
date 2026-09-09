if [ "$#" -eq 0 ]; then
	notify-send -et 2 "Done!"
else
	notify-send "$@"
fi

