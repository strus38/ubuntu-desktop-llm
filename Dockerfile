FROM ubuntu:mantic
LABEL maintainer="Nimbix, Inc."

# Update SERIAL_NUMBER to force rebuild of all layers (don't use cached layers)
ARG SERIAL_NUMBER
ENV SERIAL_NUMBER ${SERIAL_NUMBER:-20240408.1000}

ARG GIT_BRANCH
ENV GIT_BRANCH ${GIT_BRANCH:-master}

RUN apt-get -y update && \
    apt-get -y install curl && \
    curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/image-common/$GIT_BRANCH/install-nimbix.sh \
        | bash -s -- --setup-nimbix-desktop --image-common-branch $GIT_BRANCH

#Install all the softwaree for local LLM
#Install ollama
RUN curl -H 'Cache-Control: no-cache' \
    -fsSL https://ollama.com/install.sh | sh
#Install anythingllm
RUN curl -H 'Cache-Control: no-cache' \
    https://s3.us-west-1.amazonaws.com/public.useanything.com/latest/AnythingLLMDesktop.AppImage -o /tmp/AnythingLLMDesktop.AppImage \
    chmod a+x /tmp/AnythingLLMDesktop.AppImage \
    /tmp/AnythingLLMDesktop.AppImage --appimage-extract         

# Go back to Jarvice install
COPY NAE/screenshot.png /etc/NAE/screenshot.png
COPY NAE/AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://cloud.nimbix.net/api/jarvice/validate

# Expose port 22 for local JARVICE emulation in docker
EXPOSE 22

# for standalone use
EXPOSE 5901
EXPOSE 443
