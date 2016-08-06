function docker_clean_images {
	local temp=$(docker images --filter=dangling=true --format "{{.ID}}")
	if [[ "$temp" ]]; then
		for image in $temp; do
			if [[ $1 = '-n' || $1 = '--dry-run' ]]; then
				echo "Would delete image $image"
			else
				echo -n "Deleting untagged image $image: "
				local success=$(command docker rmi $image)
				if [[ $success = $image ]]; then
					echo done.
				else
					echo failed.
				fi
			fi
		done
	elif [[ $1 = '-n' || $1 = '--dry-run' ]]; then
		echo "No untagged images"
	fi
}

function docker_clean_containers {
	local temp=$(docker ps --filter 'status=exited' --filter 'status=dead' --format '{{.ID}}')
	if [[ "$temp" ]]; then
		for container in $temp; do
			if [[ $1 = '-n' || $1 = '--dry-run' ]]; then
				echo "Would delete $container"
			else
				echo -n "Deleting exited/dead container $container: "
				local success=$(echo command docker rm $container)
				if [[ $success = $container ]]; then
					echo done.
				else
					echo failed.
				fi
			fi
		done
	elif [[ $1 = '-n' || $1 = '--dry-run' ]]; then
		echo "No exited/dead containers"
	fi
}

function docker_clean_volumes {
	echo 'Clean up volumes'
	sudo docker-cleanup-volumes.sh $@
}

function docker_clean {
	local option=$1
	shift
	if [[ $option == "images" ]]; then
		docker_clean_images $@
	elif [[ $option == 'containers' ]]; then
		docker_clean_containers $@
	elif [[ $option == 'volumes' ]]; then
		sudo docker-cleanup-volumes.sh
	elif [[ $option == 'all' ]]; then
		docker_clean_containers
		docker_clean_images
		docker_clean_volumes
	else
		cat <<HERE
docker: "clean" requires 1 argument.

Usage:  docker clean COMMAND [OPTIONS]

Options:

  -n, --dry-run    Dry-run

Commands:
  containers    Remove dead/stopped containers
  images        Remove untagged images
  volumes       Remove unused volumes

HERE
	fi

}

function docker {
	local option=$1
	if [[ $option == "clean" ]]; then
		shift
		docker_clean $@
	else
		command docker $@
	fi
}
