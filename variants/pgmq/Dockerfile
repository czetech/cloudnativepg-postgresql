ARG POSTGRESQL_VERSION=17
ARG PGMQ_VERSION=1.4.4

FROM ghcr.io/cloudnative-pg/postgresql:$POSTGRESQL_VERSION AS base

FROM base AS builder
ARG PGMQ_VERSION
USER root
RUN apt-get update && apt-get install --no-install-recommends --yes \
    make \
    && rm -r /var/lib/apt/lists/*
WORKDIR /build
ADD https://github.com/tembo-io/pgmq.git#v$PGMQ_VERSION:pgmq-extension ./
RUN make && make install

FROM base
COPY --from=builder /usr/share/postgresql /usr/share/postgresql/
