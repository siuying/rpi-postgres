FROM resin/rpi-raspbian:jessie
MAINTAINER francis@ignition.hk

ENV PG_VERSION=9.4 \
    PG_USER=postgres \
    PG_HOME="/var/lib/postgresql"

ENV PG_CONFDIR="/etc/postgresql/${PG_VERSION}/main" \
    PG_BINDIR="/usr/lib/postgresql/${PG_VERSION}/bin" \
    PG_DATADIR="${PG_HOME}/${PG_VERSION}/main"

RUN echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && apt-get update \
 && apt-get install -y vim.tiny wget sudo net-tools ca-certificates unzip \
 && rm -rf /var/lib/apt/lists/*

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo 'deb-src http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
 && apt-get update \
 && apt-get install -y build-essential fakeroot

RUN apt-get build-dep postgresql-${PG_VERSION} \
 && apt-get build-dep postgresql-common \
 && apt-get build-dep postgresql-client-common \
 && apt-get build-dep pgdg-keyring \

RUN cd /tmp \
 && apt-get source --compile postgresql-${PG_VERSION} \
 && apt-get source --compile postgresql-common \
 && apt-get source --compile postgresql-client-common \
 && apt-get source --compile pgdg-keyring

RUN mkdir /var/local/repository \
  && echo "deb [ trusted=yes ] file:///var/local/repository ./" | sudo tee /etc/apt/sources.list.d/my_own_repo.list \
  && cd /var/local/repository \
  && mv /tmp/*.deb . \
  && dpkg-scanpackages ./ | tee Packages > /dev/null && sudo gzip -f Packages

RUN apt-get update \
  && apt-get install postgresql-${PG_VERSION}

# && rm -rf ${PG_HOME} \
# && rm -rf /var/lib/apt/lists/*

COPY start /start
RUN chmod 755 /start

EXPOSE 5432/tcp
VOLUME ["${PG_HOME}", "/run/postgresql"]
CMD ["/start"]
