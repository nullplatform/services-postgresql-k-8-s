# syntax=docker/dockerfile:1
#
# postgres-db (k8s) service worker image — the in-cluster Postgres service
# built on the lean gRPC worker bridge. The bridge dials over gRPC and runs
# the bash entrypoint on each package-exec action; this image adds the
# tooling the helm/kubectl steps need and bakes the service in, so the
# channel needs no cmdline.
FROM public.ecr.aws/nullplatform/scopes/worker-bridge:1.0.0

# Tooling the workflows call (the bridge base stays minimal on purpose):
# gomplate renders the chart values, openssl generates passwords, uuidgen
# (util-linux) names the psql client pods. bash, jq, np, base64 and curl ship
# in the base. psql is not needed here: queries run in a short-lived pod.
RUN apk add --no-cache gomplate openssl util-linux

# kubectl + helm: pinned official static binaries for the build arch, the
# same way scripts/k8s/ensure_tools installs them when missing.
ARG KUBECTL_VERSION=v1.31.4
ARG HELM_VERSION=v3.17.3
ARG TARGETARCH
RUN curl -fsSL -o /usr/local/bin/kubectl \
      "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" \
    && chmod +x /usr/local/bin/kubectl \
    && curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" \
      | tar -xz -C /usr/local/bin --strip-components=1 "linux-${TARGETARCH}/helm" \
    && kubectl version --client && helm version

# Bake the service in and point the bridge at its entrypoint + service path.
COPY . /app/pkg
ENV NP_PACKAGE_NAME=postgres-db \
    NP_SERVICE_PATH=/app/pkg/postgres-db \
    NP_SCOPE_ENTRYPOINT=/app/pkg/postgres-db/entrypoint/entrypoint
