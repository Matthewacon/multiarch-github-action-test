#/usr/bin/busybox sh 
export image_id="$(docker container ps -a --format json --filter 'status=running' | jq -s 'sort_by(.CreatedAt) | reverse' | jq -r '.[0].Image')"
docker tag $image_id dind-multiarch:latest

#TODO: remove, debug
docker image ls
docker container ps -a
env
