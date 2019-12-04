FROM ubuntu:18.04

# Install networking utils / other dependancies
RUN apt-get update \
 && apt-get install -y \
     docker.io \
     netcat-openbsd \
     curl \
     jq \
     lsof \
     net-tools \
     udhcpc \
     isc-dhcp-client \
     dhcpcd5 \
     arping \
     ndisc6 \
     fping \
     sipcalc \
     bc \
 && apt-get clean

# Install pipework
COPY pipework /sbin/pipework

# workaround for dhclient error due to ubuntu apparmor profile - http://unix.stackexchange.com/a/155995
# dhclient: error while loading shared libraries: libc.so.6: cannot open shared object file: Permission denied
RUN mv /sbin/dhclient /usr/sbin/dhclient

# Our pipework wrapper script
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
