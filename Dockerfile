ARG IMAGE=latest

# Base image
#============
FROM renovate/yarn:1.22.4@sha256:6f559c0e98e931b0650e35418d385f13726244ec20b4dac6de3dfa808ad49319 AS base

USER root
WORKDIR /usr/src/app/

# Build image
#============
FROM base as tsbuild

# Python 3 and make are required to build node-re2
RUN apt-get update && apt-get install -y python3-minimal build-essential
# force python3 for node-gyp
RUN rm -rf /usr/bin/python && ln /usr/bin/python3 /usr/bin/python

COPY package.json .
COPY yarn.lock .
COPY tools tools
RUN yarn install --frozen-lockfile

COPY lib lib
COPY tsconfig.json tsconfig.json
COPY tsconfig.app.json tsconfig.app.json

RUN yarn build

# Prune node_modules to production-only so they can be copied into the final image

RUN yarn install --production --frozen-lockfile

# Full image
#============
FROM base as latest

RUN apt-get update && \
    apt-get install -y gpg wget unzip xz-utils openssh-client bsdtar build-essential openjdk-11-jre-headless dirmngr && \
    rm -rf /var/lib/apt/lists/*

USER ubuntu

# HOME does not get passed after user switch :-(
ENV HOME=/home/ubuntu

ENV PATH="${HOME}/.local/bin:$PATH"

# Renovate
#=========
FROM $IMAGE as final


COPY package.json .

COPY --from=tsbuild /usr/src/app/dist dist
COPY --from=tsbuild /usr/src/app/node_modules node_modules
COPY bin bin
COPY data data

USER root

RUN ln -sf /usr/src/app/dist/renovate.js /usr/local/bin/renovate
RUN ln -sf /usr/src/app/dist/config-validator.js /usr/local/bin/renovate-config-validator


# Numeric user ID for the ubuntu user. Used to indicate a non-root user to OpenShift
USER 1000

ENTRYPOINT ["node", "/usr/src/app/dist/renovate.js"]
