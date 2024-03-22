FROM archlinux:latest AS builder

#install base deps and docker
RUN pacman -Sy --noconfirm wget

#create bootstrap directories for pacman in destination image directory
#NOTE: taken from: https://github.com/lopsided98/archlinux-docker/blob/master/pacstrap-docker
RUN /usr/bin/bash -c '\
 mkdir -p /image/usr/bin \
 && mkdir -m 0755 -p /image/var/{cache/pacman/pkg,lib/pacman,log} /image/{dev,run,etc} \
 && mkdir -m 1777 -p /image/tmp \
 && mkdir -m 0555 -p /image/{sys,proc} \
 && mknod /image/dev/null c 1 3 \
'

#install docker into destination image directory
RUN /usr/bin/bash -c '\
  wget https://download.docker.com/linux/static/stable/x86_64/docker-25.0.4.tgz \
  && tar -vzxf docker-25.0.4.tgz --strip=1 -C /image/usr/bin \
'

#install all pacakges in destination image directory
RUN  pacman -r /image -Sy --noconfirm \
  qemu-user-static \
  qemu-user-static-binfmt \
  busybox \
  fuse-overlayfs \
  iptables

#install pacman
RUN /usr/bin/bash -c '\
  pacman -r /image -Sy --noconfirm pacman \
  && cp /etc/pacman.conf /image/etc \
  && cp -R /etc/pacman.d/ /image/etc/ \
'

#copy bootstrap image from builder stage into github image
FROM scratch as github
COPY --from=builder /image /

#install jq
RUN /usr/bin/busybox sh -c '\
  pacman -Sy --noconfirm jq \
  && rm -r /var/lib/pacman/sync \
'

#copy entrypoint script into github image
COPY ./.github/actions/dind-multiarch/entrypoint.sh /usr/bin/

ENTRYPOINT ["/usr/bin/busybox", "sh", "/usr/bin/entrypoint.sh"]

#ENTRYPOINT [\
#  "/usr/bin/busybox", "sh", "-c", "\
#    export image_id="docker container ps -a --format json --format \'status=running\' | jq -s 'sort_by(.CreatedAt)' | jq -r '.[0].ID'" \
#    && docker tag $image_id local:test-tag \
#  "\
#]

#ENTRYPOINT ["/usr/bin/busybox", "sh", "-c", "env && ls / && docker image ls && docker container ps -a"]

#ENV args="echo Set the command string in the 'args' environment variable"
#ENTRYPOINT ["/usr/bin/busybox", "sh", "-c", "$args"]
##ENTRYPOINT ["/usr/bin/busybox", "sh", "/usr/bin/docker", "image", "ps", "-a"]
##ENTRYPOINT ["/usr/bin/docker", "image", "ls"]
