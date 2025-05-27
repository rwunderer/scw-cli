[![GitHub license](https://img.shields.io/github/license/rwunderer/scw-cli.svg)](https://github.com/rwunderer/scw-cli/blob/main/LICENSE)
<a href="https://renovatebot.com"><img alt="Renovate enabled" src="https://img.shields.io/badge/renovate-enabled-brightgreen.svg?style=flat-square"></a>

***As a contribution to [unplug Trump](https://www.kuketz-blog.de/unplugtrump-mach-dich-digital-unabhaengig-von-trump-und-big-tech/) this repository has moved to [codeberg](https://codeberg.org/capercode/scw-cli).***

# scw-cli
Minimal Docker image with [Scaleway cli utility](https://github.com/scaleway/scaleway-cli)

## Image variants

This image is based on [distroless](https://github.com/GoogleContainerTools/distroless) and comes in two variants:

### Minimal image

The minimal image is based on `gcr.io/distroless/static-debian12:nonroot` and does not contain a shell. It can be directly used from the command line, eg:

```
$ docker run --rm -it ghcr.io/rwunderer/scw-cli:v2.23.0-minimal version
Version    2.23.0
BuildDate  2023-10-16T12:02:36Z
GoVersion  go1.20.8
GitBranch  HEAD
GitCommit  af247ace
GoArch     amd64
GoOS       linux
```

### Debug image

The debug images is based on `gcr.io/distroless/base-debian12:debug-nonroot` and contains a busybox shell for use in ci images.
As scw's output is also available in json it also containts [jq](https://github.com/jqlang/jq).

E.g. for GitLab CI do:

```
list images:
  image:
    name: ghcr.io/rwunderer/scw-cli:v2.23.0-debug
    entrypoint: [""]
  variables:
    SCW_ACCESS_KEY=""
    SCW_SECRET_KEY=""

  script:
    - scw instance image list
```

## Workflows

| Badge      | Description
|------------|---------
|[![Auto-Tag](https://github.com/rwunderer/scw-cli/actions/workflows/renovate-create-tag.yml/badge.svg)](https://github.com/rwunderer/scw-cli/actions/workflows/renovate-create-tag.yml) | Automatic Tagging of new scw releases
|[![Docker](https://github.com/rwunderer/scw-cli/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/rwunderer/scw-cli/actions/workflows/docker-publish.yml) | Docker image build
