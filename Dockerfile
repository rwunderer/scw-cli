#-------------------
# Download scw
#-------------------
FROM alpine:3.20.2@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5 as builder

# renovate: datasource=github-releases depName=scw-cli lookupName=scaleway/scaleway-cli
ARG SCW_VERSION=2.33.0
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
FROM gcr.io/distroless/static-debian12:nonroot@sha256:8dd8d3ca2cf283383304fd45a5c9c74d5f2cd9da8d3b077d720e264880077c65 as scw-cli-minimal

COPY --from=builder /bin/scw /bin/scw

ENTRYPOINT ["/bin/scw"]

#-------------------
# Debug image
#-------------------
FROM gcr.io/distroless/base-debian12:debug-nonroot@sha256:8d946e4103571ec0e2f471eac7c4859a7f169686d222f5c8b2d9d391d6d1e50c as scw-cli-debug

COPY --from=builder /bin/jq /bin/jq
COPY --from=builder /bin/scw /bin/scw

ENTRYPOINT ["/bin/scw"]
