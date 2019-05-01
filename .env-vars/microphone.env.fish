alias fix-microphone="while true; pacmd set-source-volume (pacmd list-sources | grep '^  \*' | sed -re 's/  \* index: //') 30000; end;"
