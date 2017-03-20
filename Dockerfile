
FROM node:7

ENV PG_VERSION 9.6.2

RUN set -ex \
    && mkdir -p /usr/src/postgres \
    && wget "https://ftp.postgresql.org/pub/source/v$PG_VERSION/postgresql-$PG_VERSION.tar.bz2" \
    && tar jxf postgresql-$PG_VERSION.tar.bz2 -C /usr/local/src

COPY src /usr/local/src

RUN set -ex \
    && cd /usr/local/src/postgresql-$PG_VERSION \
    && patch -p1 < ../patches/pgstudy-print-buffer.patch \
    && patch -p1 < ../patches/pgstudy-guc.patch \
    && ./configure \
    && make install

USER node

WORKDIR /home/node

RUN set -ex \
    && cp -r /usr/local/src/server . \
    && cd server \
    && npm install --no-bin-links \
    && /usr/local/pgsql/bin/initdb -D ../data > /dev/null \
    && /usr/local/pgsql/bin/pg_ctl start -w -D ../data \
    && /usr/local/pgsql/bin/createdb \
    && /usr/local/pgsql/bin/pg_ctl stop -w -D ../data

CMD /usr/local/pgsql/bin/postgres -D data | node server/server.js

EXPOSE 3000 5432
