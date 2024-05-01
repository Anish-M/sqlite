SHELL := /bin/bash

IMAGE_NAME ?= sql-lite-dev
IMAGE_VERSION ?= latest
RELEASE_IMAGE_NAME ?= sql-lite
RELEASE_IMAGE_VERSION ?= 5.1.0a1
SRC_DIR ?= $(shell pwd)

CONTAINER_TOOL ?= docker
CONTAINER_CONTEXT ?= default
CONTAINER_OPTS ?=
CONTAINER_CMD ?= bash -l
CONTAINER_SRC_DIR ?= ${SRC_DIR}
CONTAINER_BUILD_DIR ?= ${CONTAINER_SRC_DIR}/build
CONTAINER_WORK_DIR ?= ${CONTAINER_SRC_DIR}
INTERACTIVE ?= i
UNAME ?= $(shell whoami)
UID ?= $(shell id -u)
GID ?= $(shell id -g)

# Developer variables that should be set as env vars in startup files like .profile
SQL_LITE_PARALLELISM ?= 16
SQL_LITE_CONTAINER_MOUNTS ?=
SQL_LITE_CONTAINER_ENV ?=
SQL_LITE_PREFIX_PATH ?= ${CONTAINER_BUILD_DIR}
SQL_LITE_OUTPUT_FILE ?= ${CONTAINER_BUILD_DIR}/config.out

build-image:
	@${CONTAINER_TOOL} --context ${CONTAINER_CONTEXT} build \
	--build-arg UNAME=${UNAME} \
  --build-arg UID=${UID} \
  --build-arg GID=${GID} \
	-t ${IMAGE_NAME}:${IMAGE_VERSION} \
	--file Containerfile \
	--target build .

build-run:
	@${CONTAINER_TOOL} --context ${CONTAINER_CONTEXT} run --rm \
	-v ${SRC_DIR}/:${CONTAINER_SRC_DIR} \
	${SQL_LITE_CONTAINER_MOUNTS} \
	${SQL_LITE_CONTAINER_ENV} \
	--privileged \
	--workdir=${CONTAINER_WORK_DIR} ${CONTAINER_OPTS} -${INTERACTIVE}t \
	${IMAGE_NAME}:${IMAGE_VERSION} ${CONTAINER_CMD}

.PHONY: setup
setup:
	@AUTOMAKE_JOBS=${SQL_LITE_PARALLELISM} ${CONTAINER_SRC_DIR}/autogen.pl

.PHONY: configure
configure:
	@mkdir -p ${CONTAINER_BUILD_DIR}
	@cd ${CONTAINER_BUILD_DIR} && ${CONTAINER_SRC_DIR}/configure \
	--prefix=${SQL_LITE_PREFIX_PATH} 2>&1 | tee ${SQL_LITE_OUTPUT_FILE}

.PHONY: build
build:
	@make -C ${CONTAINER_BUILD_DIR} -j ${SQL_LITE_PARALLELISM}

build-amalgamation:
	@make -C ${CONTAINER_BUILD_DIR} -j ${SQL_LITE_PARALLELISM} sqlite3.c

.PHONY: test
test:
	@make -C ${CONTAINER_BUILD_DIR} devtest

deploy-image:
	@${CONTAINER_TOOL} --context ${CONTAINER_CONTEXT} build \
  --build-arg SQL_LITE_PREFIX_PATH=${SQL_LITE_PREFIX_PATH} \
	-t ${RELEASE_IMAGE_NAME}:${RELEASE_IMAGE_VERSION} \
	--file Containerfile \
	--target release .

deploy-run:
	@${CONTAINER_TOOL} --context ${CONTAINER_CONTEXT} run --rm \
	--privileged \
	-${INTERACTIVE}t \
	${RELEASE_IMAGE_NAME}:${RELEASE_IMAGE_VERSION} ${CONTAINER_CMD}
