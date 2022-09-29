FROM hydaz/baseimage-alpine-glibc:latest

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="AMP version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="hydaz"

# environment settings
ENV VERSION=${VERSION} \
	HOME=/config \ 
	USERNAME=admin \
	PASSWORD=password \
	MODULE=ADS \
	S6_SERVICES_GRACETIME=60000

RUN set -xe && \
	echo "**** install runtime packages ****" && \
	curl -o \
		/etc/apk/keys/hydaz.rsa.pub \
		"https://packages.hyde.services/hydaz.rsa.pub" && \
	echo "https://packages.hyde.services/alpine/apk" >>/etc/apk/repositories && \
	apk add --no-cache \
		git \
		iputils \
		ca-certificates-mono \
		openjdk11-jre-headless \
		procps \
		jq \
		socat \
		tmux \
		unzip && \
	echo "**** ensure abc has a shell ****" && \
	usermod -d /config -m -s /bin/bash abc && \
	echo "**** download ampinstmgr.zip ****" && \
	curl -o \
		/tmp/ampinstmgr.tgz -L \
		"https://repo.cubecoders.com/ampinstmgr-latest.tgz" && \
	echo "**** unzip ampinstmgr and make symlinks ****" && \
	tar xf \
		/tmp/ampinstmgr.tgz -C \
		/tmp --strip-components=1 && \
	mv /tmp/cubecoders/amp /app/ && \
	ln -s /app/amp/ampinstmgr /usr/bin/ampinstmgr && \
	echo "**** download AMPCache.zip ****" && \
	if [ -z ${VERSION} ]; then \
		VERSION=$(curl -sL https://cubecoders.com/AMPVersions.json | \
			jq -r '.AMPCore'); \
	fi && \
	curl -o \
		/app/amp/AMPCache-${VERSION//./}.zip -L \
		"http://cubecoders.com/Downloads/AMP_Latest.zip" && \
	echo "**** cleanup ****" && \
	rm -rf \
		/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8080
VOLUME /config
