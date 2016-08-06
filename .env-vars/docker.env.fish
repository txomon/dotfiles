function docker_clean_images
	set temp (command docker images --filter=dangling=true --format "{{.ID}}")
	if test "$temp" 
		for image in $temp
			if test "$argv[1]" = '-n' ;or test "$argv[1]" = '--dry-run'
				echo "Would delete image $image"
			else
				echo -n "Deleting untagged image $image: "
				set success (command docker rmi $image)
				if test "$success" = "$image"
					echo done.
				else
					echo failed.
				end
			end
		end
	else
		echo "No untagged images"
	end
end

function docker_clean_containers 
	set temp (command docker ps --filter 'status=exited' --filter 'status=dead' --format '{{.ID}}')
	if test "$temp" 
		for container in $temp
			if test "$argv[1]" = '-n' ;or test "$argv[1]" = '--dry-run'
				echo "Would delete $container"
			else
				echo -n "Deleting exited/dead container $container: "
				set success (command docker rm $container)
				if test "$success"="$container"
					echo done.
				else
					echo failed.
				end
			end
		end
	else
		echo "No exited/dead containers"
	end
end

function docker_clean_volumes 
	echo 'Clean up volumes'
	sudo docker-cleanup-volumes.sh $argv
end

function docker_clean 
	set option $argv[1]
	set --erase argv[1]
	if test "$option" = "images"
		docker_clean_images $argv
	else if test "$option" = 'containers'
		docker_clean_containers $argv
	else if test "$option" = 'volumes'
		sudo docker-cleanup-volumes.sh $argv
	else if test "$option" = 'all'
		docker_clean_containers
		docker_clean_images
		docker_clean_volumes
	else
		echo 'docker: "clean" requires 1 argument.

Usage:  docker clean COMMAND [OPTIONS]

Options:

  -n, --dry-run    Dry-run

Commands:
  containers    Remove dead/stopped containers
  images        Remove untagged images
  volumes       Remove unused volumes

'
	end
end

function docker 
	set option $argv[1]
	if test "$option"="clean"
		set --erase argv[1]
		docker_clean $argv
	else
		command docker $argv
	end
end
