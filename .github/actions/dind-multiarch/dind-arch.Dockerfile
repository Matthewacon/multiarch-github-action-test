FROM archlinux:latest AS builder

#install base deps
RUN mkdir -p /image/usr/bin && pacman -Sy --noconfirm wget

#download docker
RUN wget https://download.docker.com/linux/static/stable/x86_64/docker-25.0.4.tgz

#TODO: extract docker
RUN tar -vzxf docker-25.0.4.tgz --strip=1 -C /image/usr/bin

#create bootstrap directories from pacman
#NOTE: taken from: https://github.com/lopsided98/archlinux-docker/blob/master/pacstrap-docker
RUN /usr/bin/bash -c '\
 mkdir -m 0755 -p /image/var/{cache/pacman/pkg,lib/pacman,log} /image/{dev,run,etc} \
 && mkdir -m 1777 -p /image/tmp \
 && mkdir -m 0555 -p /image/{sys,proc} \
 && mknod /image/dev/null c 1 3 \
'

#install all pacakges for final image
RUN /usr/bin/bash -c "pacman -r /image -Sy --noconfirm qemu-user-static qemu-user-static-binfmt busybox fuse-overlayfs iptables"

#install pacman
#RUN /usr/bin/bash -c "pacman -r /image -Sy --noconfirm pacman"
#RUN /usr/bin/bash -c "cp /etc/pacman.conf /image/etc && cp -R /etc/pacman.d/ /image/etc/"

#copy reuslts into final image and set up entrypoint
FROM scratch

COPY --from=builder /image /

ENV args="echo Set the command string in the 'args' environment variable"
ENTRYPOINT ["/usr/bin/busybox", "sh", "-c", "$args"]
#ENTRYPOINT ["/usr/bin/busybox", "sh", "/usr/bin/docker", "image", "ps", "-a"]
#ENTRYPOINT ["/usr/bin/docker", "image", "ls"]
