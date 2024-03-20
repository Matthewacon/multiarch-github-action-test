FROM archlinux:latest AS builder

#get docker cli
RUN /usr/bin/bash -c '\
 mkdir -p /image/usr/bin \
 && pacman -Sy --noconfirm wget \
 && wget https://download.docker.com/linux/static/stable/x86_64/docker-25.0.4.tgz \
 && tar -zxf docker-25.0.4.tgz --strip=1 docker/docker -O > /usr/bin/docker && chmod +x /usr/bin/docker \
 && cp /usr/bin/docker /image/usr/bin/ \
'

#create bootstrap directories from pacman
#NOTE: taken from: https://github.com/lopsided98/archlinux-docker/blob/master/pacstrap-docker
RUN /usr/bin/bash -c '\
 mkdir -m 0755 -p /image/var/{cache/pacman/pkg,lib/pacman,log} /image/{dev,run,etc} \
 && mkdir -m 1777 -p /image/tmp \
 && mkdir -m 0555 -p /image/{sys,proc} \
 && mknod /image/dev/null c 1 3 \
'

#install all pacakges for final image
RUN /usr/bin/bash -c "pacman -r /image -Sy --noconfirm qemu-user-static qemu-user-static-binfmt busybox"
RUN /usr/bin/bash -c "pacman -r /image -Sy --noconfirm pacman"
RUN /usr/bin/bash -c "cp /etc/pacman.conf /image/etc && cp -R /etc/pacman.d/ /image/etc/"

#copy reuslts into final image and set up entrypoint
FROM scratch

COPY --from=builder /image /
ENTRYPOINT ["/usr/bin/busybox", "sh", "docker", "image", "ps", "-a"]
