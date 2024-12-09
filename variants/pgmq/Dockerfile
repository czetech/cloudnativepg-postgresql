ARG POSTGRESQL_VERSION=17
ARG POSTGRESQL_DIGEST
ARG PGMQ_VERSION=1.4.4

ARG digest=${POSTGRESQL_DIGEST:+@${POSTGRESQL_DIGEST}}
FROM ghcr.io/cloudnative-pg/postgresql:${POSTGRESQL_VERSION}${digest} AS base

FROM base AS builder
# hadolint ignore=DL3002
USER root
RUN apt-get update && apt-get install --no-install-recommends --yes \
    make=4.* \
    && rm -r /var/lib/apt/lists/*
WORKDIR /build
ARG PGMQ_VERSION
ADD https://github.com/tembo-io/pgmq.git#v${PGMQ_VERSION}:pgmq-extension ./
RUN make && make install

FROM base
COPY --from=builder /usr/share/postgresql /usr/share/postgresql/
