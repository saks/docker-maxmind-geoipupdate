FROM debian:wheezy

MAINTAINER saksmlz <saksmlz@gmail.com>

ENV VERSION 2.1.0

# Download, build and install geoipupdate together with our licence key and config for it.
# This pulls in a tonne of dev/build dependencies.
# Sadly there's no binary package for this, geoipupdate from the geoip-bin package on Ubuntu only
# supports the legacy maxmind format, not GeoIP2 databases.
# TODO we could create our own pre-built binaries of geoipupdate to circumvent some of this
# nonsense.
RUN apt-get update \
  && apt-get install -y wget build-essential libcurl4-openssl-dev libcurl3 \
  && wget https://github.com/maxmind/geoipupdate/releases/download/v$VERSION/geoipupdate-$VERSION.tar.gz \
  && tar zxvf geoipupdate-$VERSION.tar.gz \
  && cd geoipupdate-$VERSION \
  && ./configure \
  && make \
  && make install \
  && cd ./.. \
  && rm -r ./geoipupdate-$VERSION \
  && apt-get purge -y --auto-remove wget build-essential libcurl4-openssl-dev gcc-4.7 \
  && apt-get -y autoremove \
  && rm -rf /var/lib/apt/lists/*

VOLUME /geoip_db

CMD [ "geoipupdate", "-d", "/geoip_db", "-f", "/etc/GeoIP.conf" ]
