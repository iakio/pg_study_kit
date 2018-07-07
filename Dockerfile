FROM node:8

ENV PG_VERSION 9.6.2

USER node

WORKDIR /home/node

COPY src src

RUN set -ex \
    && mkdir pgsql \
    && wget "https://ftp.postgresql.org/pub/source/v$PG_VERSION/postgresql-$PG_VERSION.tar.bz2" \
    && tar jxf postgresql-$PG_VERSION.tar.bz2

RUN set -ex \
    && cd postgresql-$PG_VERSION \
    && ./configure --prefix=$HOME/pgsql\
    && make install

RUN set -ex \
    && /home/node/pgsql/bin/initdb -D data > /dev/null \
    && echo "host all all all trust" >> data/pg_hba.conf \
    && /home/node/pgsql/bin/pg_ctl start -w -D data \
    && /home/node/pgsql/bin/createdb \
    && /home/node/pgsql/bin/pg_ctl stop -w -D data

RUN set -ex \
    && cd postgresql-$PG_VERSION \
    && patch -p1 < ../src/patches/pgstudy-print-buffer.patch \
    && patch -p1 < ../src/patches/pgstudy-guc.patch \
    && ./configure --prefix=$HOME/pgsql\
    && make install


