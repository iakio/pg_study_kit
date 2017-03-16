
FROM node:7

ENV GOSU_VERSION 1.7

RUN set -ex \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

ENV PG_VERSION 9.6.2

RUN set -ex \
    && mkdir -p /usr/src/postgres \
    && wget -O postgresql.tar.bz2 "https://ftp.postgresql.org/pub/source/v$PG_VERSION/postgresql-$PG_VERSION.tar.bz2" \
    && tar jxf postgresql.tar.bz2 -C /usr/src/postgres

COPY src/patches/ /usr/src/postgres/patches

RUN set -ex \
    && cd /usr/src/postgres/postgresql-$PG_VERSION \
    && patch -p1 < ../patches/pgstudy-print-buffer.patch \
    && patch -p1 < ../patches/pgstudy-guc.patch \
    && ./configure \
    && make install