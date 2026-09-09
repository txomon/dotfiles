layer_id=$1

docker image ls -qa \
  | while read -r imageid; do
      docker image inspect --format '{{json .GraphDriver.Data}}' "$imageid" \
        | grep -q "$layer_id" && echo "$imageid"
    done
