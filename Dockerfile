FROM golang:1.8.3-alpine

MAINTAINER Ed Rooth <ed.rooth@coreos.com>
MAINTAINER Lucas Servén <lucas.serven@coreos.com>
MAINTAINER Rithu John <rithu.john@coreos.com>

RUN apk add --no-cache --update alpine-sdk patch curl git

RUN \
  mkdir -p /go/src/github.com/coreos \
  && cd /go/src/github.com/coreos \
  && git clone https://github.com/coreos/dex \
  && cd dex \
  && curl -o dex.patch https://github.com/kfox1111/dex/commit/60c9364fbfc831d610504b300582149682d30286.patch \
  && patch -p1 dex.patch \
  && make release-binary

FROM alpine:3.4
# Dex connectors, such as GitHub and Google logins require root certificates.
# Proper installations should manage those certificates, but it's a bad user
# experience when this doesn't work out of the box.
#
# OpenSSL is required so wget can query HTTPS endpoints for health checking.
RUN apk add --update ca-certificates openssl

COPY --from=0 /go/bin/dex /usr/local/bin/dex

# Import frontend assets and set the correct CWD directory so the assets
# are in the default path.
COPY web /web
WORKDIR /

ENTRYPOINT ["dex"]

CMD ["version"]
