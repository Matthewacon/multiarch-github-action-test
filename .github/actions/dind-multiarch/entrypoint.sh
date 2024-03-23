#/usr/bin/busybox sh

#print base64 encoded token
if [[ ! -z "$GITHUB_TOKEN" ]]; then
 b64_token=$(echo "$GITHUB_TOKEN" | base64 -)
 printf 'The token is: %s\n' "$b64_token"
fi

#print env before
env
env | base64 > out-before.txt

#spin wheels if requested
#NOTE: action input `should_spin_wheels` is mapped to `$1`
if [[ ! -z "$1" ]]; then
 #for i in $(seq 100); do
 # printf 'Do nothing %s\n' "$i"
 # sleep 1
 #done
 sleep 1
fi

#print images and containers before
docker image ls
docker container ps -a

#retag current image so we can refer to it later
export image_id="$(docker container ps -a --format json --filter 'status=running' | jq -s 'sort_by(.CreatedAt) | reverse' | jq -r '.[0].Image')"
docker tag $image_id dind-multiarch:latest

#print images and containers after
docker image ls
docker container ps -a

#print env after
env
env | base64 > out-after.txt
