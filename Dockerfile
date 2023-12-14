#-------------------
# Download scw
#-------------------
FROM alpine:3.19.0@sha256:51b67269f354137895d43f3b3d810bfacd3945438e94dc5ac55fdac340352f48 as builder

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
FROM gcr.io/distroless/static-debian12:nonroot@sha256:45e75c9ed314a1723c628d401ec6025dcf505949ab07a3e6e3bf9b0dc240bd0e as scw-cli-minimal

COPY --from=builder /bin/scw /bin/scw

ENTRYPOINT ["/bin/scw"]

#-------------------
# Debug image
#-------------------
FROM gcr.io/distroless/base-debian12:debug-nonroot@sha256:8548e3041a2cc583998c6a6beabf13ae93e6b006a5f6a6194966b4327ea741f5 as scw-cli-debug

COPY --from=builder /bin/jq /bin/jq
COPY --from=builder /bin/scw /bin/scw

ENTRYPOINT ["/bin/scw"]
