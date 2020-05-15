function docker_export_image
	docker rm test &>/dev/null
	docker create --name test $argv / 1>/dev/null
	docker export test | tar t 
	docker rm test &>/dev/null
end
