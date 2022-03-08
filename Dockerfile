FROM ubuntu
ARG TIMEZONE="Asia/Jerusalem"
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG BUILDPLATFORM
ARG BUILDOS
ARG BUILDARCH
ARG BUILDVARIANT
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=$TIMEZONE
RUN echo "I'm building for TARGETPLATFORM=$TARGETPLATFORM TARGETOS=$TARGETOS TARGETARCH=$TARGETARCH TARGETVARIANT=$TARGETVARIANT BUILDPLATFORM=$BUILDPLATFORM BUILDOS=$BUILDOS BUILDARCH=$BUILDARCH BUILDVARIANT=$BUILDVARIANT"
RUN ln -fs "/usr/share/zoneinfo/${TZ}" /etc/localtime
RUN apt update; apt install wget libterm-readline-gnu-perl apt-transport-https sqlite3 ca-certificates tzdata -yyq
RUN wget https://packages.microsoft.com/config/ubuntu/21.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb; dpkg -i packages-microsoft-prod.deb; rm packages-microsoft-prod.deb; 
RUN apt update; apt install -y aspnetcore-runtime-6.0
# x64    arm     arm64
# amd64  arm/v7  arm64
RUN case $TARGETARCH in \
    amd64) echo "x64" > /arch;;\
    arm) echo "arm" > /arch;;\
    arm64) echo "arm64" > /arch;;\
    *) echo "Failed to TARGETARCH=$TARGETARCH is not compatible with Radarr" && exit 2;;\
esac;

RUN mkdir -p /var/lib/radarr/

WORKDIR /tmp
RUN export ARCH=$(cat /arch); wget -O Radarr.tar.gz "http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=${ARCH}"
RUN tar xzvf Radarr.tar.gz -C /opt; rm -f Radarr.tar.gz /arch; test -f /opt/Radarr/Radarr && echo "installed successfully" || exit 1
WORKDIR /opt/Radarr
CMD ./Radarr -nobrowser -data=/var/lib/radarr/

EXPOSE 7878
