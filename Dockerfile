FROM resin/rpi-raspbian:wheezy
MAINTAINER francis@ignition.hk

ENV PG_VERSION=9.4 \
    PG_USER=postgres \
    PG_HOME="/var/lib/postgresql"

ENV PG_CONFDIR="/etc/postgresql/${PG_VERSION}/main" \
    PG_BINDIR="/usr/lib/postgresql/${PG_VERSION}/bin" \
    PG_DATADIR="${PG_HOME}/${PG_VERSION}/main"

RUN apt-get update \
 && apt-get install -y curl \
 && mkdir /var/local/repository \
 && cd /var/local/repository \
 && curl -sSL postgresql-9.4.4-raspbian.tgz https://www.dropbox.com/s/t9x78hbfo2mb8yi/postgresql-9.4.4-raspbian.tgz?dl=1 | tar xzC /var/local/repository \
 && echo "deb [ trusted=yes ] file:///var/local/repository ./" | tee /etc/apt/sources.list.d/my_own_repo.list \
 && apt-get update \
 && apt-get install -y postgresql-9.4 \
 && rm -rf /var/lib/apt/lists/*

COPY start /start
RUN chmod 755 /start

EXPOSE 5432/tcp
VOLUME ["/var/lib/postgresql", "/run/postgresql"]
CMD ["/start"]
