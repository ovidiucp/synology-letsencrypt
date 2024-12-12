FROM ubuntu:24.04
MAINTAINER Ovidiu Predescu <ovidiu@jollyturns.com>

RUN (apt-get update; \
    apt-get install -y curl cron; \
    )

ADD entrypoint.sh /entrypoint.sh

RUN curl https://get.acme.sh >/acme-install.sh

ENTRYPOINT ["/entrypoint.sh" ]
