#-------------------
# Download scw
#-------------------
FROM alpine:3.19.1@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b as builder

# renovate: datasource=github-releases depName=scw-cli lookupName=scaleway/scaleway-cli
ARG SCW_VERSION=2.30.0
# renovate: datasource=github-releases depName=jq lookupName=jqlang/jq
ARG JQ_VERSION=1.7
ARG TARGETARCH
ARG TARGETOS
ARG TARGETVARIANT

WORKDIR /tmp

RUN apk --no-cache add --upgrade \
    curl

RUN curl -SsL -o jq https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-${TARGETARCH} && \
    install jq /bin/jq && \
    rm jq

RUN IMAGE=scaleway-cli_${SCW_VERSION}_${TARGETOS}_${TARGETARCH}${TARGETVARIANT} && \
    curl -SsL -o ${IMAGE} https://github.com/scaleway/scaleway-cli/releases/download/v${SCW_VERSION}/${IMAGE} && \
    install ${IMAGE} /bin/scw && \
    rm ${IMAGE}

#-------------------
# Minimal image
#-------------------
FROM gcr.io/distroless/static-debian12:nonroot@sha256:e9ac71e2b8e279a8372741b7a0293afda17650d926900233ec3a7b2b7c22a246 as scw-cli-minimal

COPY --from=builder /bin/scw /bin/scw

ENTRYPOINT ["/bin/scw"]

#-------------------
# Debug image
#-------------------
FROM gcr.io/distroless/base-debian12:debug-nonroot@sha256:08baf3b9b25ef61b205195747e8d8b746f10317cc37a0250f9ca66312be8bd1d as scw-cli-debug

COPY --from=builder /bin/jq /bin/jq
COPY --from=builder /bin/scw /bin/scw

ENTRYPOINT ["/bin/scw"]
