#-------------------
# Download scw
#-------------------
FROM alpine:3.19.1@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b as builder

# renovate: datasource=github-releases depName=scw-cli lookupName=scaleway/scaleway-cli
ARG SCW_VERSION=2.26.0
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
FROM gcr.io/distroless/static-debian12:nonroot@sha256:39ae7f0201fee13b777a3e4a5a9326a8889269172c8b4f4289d9f19c831f45f4 as scw-cli-minimal

COPY --from=builder /bin/scw /bin/scw

ENTRYPOINT ["/bin/scw"]

#-------------------
# Debug image
#-------------------
FROM gcr.io/distroless/base-debian12:debug-nonroot@sha256:6f48e2b7225cf09a7c9b813910518d16c9517d76f65ebf306c742eb0e21d1ae4 as scw-cli-debug

COPY --from=builder /bin/jq /bin/jq
COPY --from=builder /bin/scw /bin/scw

ENTRYPOINT ["/bin/scw"]
