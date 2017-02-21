FROM alpine
MAINTAINER Michael Ruettgers <monty@ruettgers.eu>

ENV FHEM_VERSION 5.8
ENV FHEM_HOME=/opt/fhem-${FHEM_VERSION}
ENV FHEM_VAR=/var/lib/fhem
ENV FHEM_LOG=/var/log/fhem
ENV FHEM_PID=/var/run/fhem

RUN apk add --update perl \
  perl-device-serialport \
  perl-io-socket-ssl \
  perl-libwww \
  perl-xml-simple \
  perl-json && \
  rm -rf /var/cache/apk/*

RUN ([ -d /var/lib/fhem ] || mkdir -p /var/lib/fhem) && \
    addgroup fhem && \
    adduser -D -G fhem -h /var/lib/fhem -u 1000 fhem

RUN ([ -d /opt ] || mkdir -p /opt) && \
  ([ -d ${FHEM_LOG} ] || mkdir -p ${FHEM_LOG}) && \
  ([ -d ${FHEM_VAR} ] || mkdir -p ${FHEM_VAR}) && \
  ([ -d ${FHEM_PID} ] || mkdir -p ${FHEM_PID}) && \
  chown fhem:fhem ${FHEM_VAR} ${FHEM_LOG} ${FHEM_PID}

ADD http://fhem.de/fhem-${FHEM_VERSION}.tar.gz /tmp/fhem.tar
RUN cd /opt && tar xvf /tmp/fhem.tar && rm /tmp/fhem.tar

USER fhem

RUN echo "attr global nofork 1" > ${FHEM_VAR}/fhem.cfg && \
  echo "attr global modpath ${FHEM_HOME}" >> ${FHEM_VAR}/fhem.cfg && \
  echo "attr global statefile ${FHEM_VAR}/fhem.save" >> ${FHEM_VAR}/fhem.cfg && \
  echo "attr global pidfilename ${FHEM_PID}/fhem.pid" >> ${FHEM_VAR}/fhem.cfg && \
  cat ${FHEM_HOME}/fhem.cfg | \
  sed -E '/(modpath|statefile|pidfilename|nofork)/d' | \
  sed "s#\./log#${FHEM_LOG}#g" >> ${FHEM_VAR}/fhem.cfg

VOLUME [${FHEM_VAR}, ${FHEM_LOG}]

EXPOSE 8083 8084 8085 7072

WORKDIR ${FHEM_HOME}

CMD ["/usr/bin/perl", "fhem.pl", "/var/lib/fhem/fhem.cfg"]
