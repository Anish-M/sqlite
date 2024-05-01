ARG BUILD_IMAGE=ubuntu:22.04
ARG RELEASE_IMAGE=ubuntu:22.04
FROM ${BUILD_IMAGE} AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update -y \
  &&  apt install -y \
  vim \
  sudo \
  git \
  make \
  m4 \
  autoconf \
  automake \
  libtool \
  flex \
  python3 \
  zlib1g-dev \
  tcl \
  &&  apt clean

ARG UNAME
ARG UID
ARG GID

RUN if [ "${UNAME}" != "root" ] ; then groupadd -g ${GID} ${UNAME} \
  &&  useradd -ms /bin/bash  -u "${UID}" -g "${GID}" ${UNAME} ; fi

RUN mkdir -p /home/${UNAME} \
  && chown ${UNAME}:${UNAME} /home/${UNAME}

USER ${UNAME}
