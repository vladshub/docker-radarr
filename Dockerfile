FROM mcr.microsoft.com/dotnet/runtime:6.0-focal
ARG TARGETARCH
ARG TIMEZONE="Asia/Jerusalem"
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=$TIMEZONE
RUN mkdir -p /var/lib/radarr && \
    apt update && apt instapp wget -yyq
# x64    arm     arm64
# amd64  arm/v7  arm64
RUN case $TARGETARCH in \
    amd64) echo "x64" > arch;;\
    arm) echo "arm" > arch;;\
    arm64) echo "arm64" > arch;;\
    *) echo "Failed to TARGETARCH=$TARGETARCH is not compatible with Radarr" && exit 2;;\
esac;

RUN export ARCH=$(cat arch); \
    wget -O Radarr.tar.gz "http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=${ARCH}"; \
    tar xzvf Radarr.tar.gz -C /opt; \
    rm -f Radarr.tar.gz arch; \
    test -f /opt/Radarr/Radarr && echo "installed successfully" || exit 1
WORKDIR /opt/Radarr
CMD /opt/Radarr/Radarr -nobrowser -data=/var/lib/radarr/

VOLUME [ "/var/lib/radarr" ]
EXPOSE 7878
# 6.0.2-alpine3