# syntax=docker/dockerfile:1
#
# postgres-db (k8s) service worker image — the in-cluster Postgres service
# built on the lean gRPC worker bridge. The bridge dials over gRPC and runs
# the bash entrypoint on each package-exec action; this image adds the
# tooling the helm/kubectl steps need and bakes the service in, so the
# channel needs no cmdline.
FROM public.ecr.aws/nullplatform/scopes/worker-bridge:2.0.1

# Tooling the workflows call (the bridge base stays minimal on purpose):
# gomplate renders the chart values, openssl generates passwords, uuidgen
# (util-linux) names the psql client pods. bash, jq, np, base64 and curl ship
# in the base. psql is not needed here: queries run in a short-lived pod.
RUN apk add --no-cache gomplate openssl util-linux

# kubectl + helm: pinned official static binaries for the build arch, the
# same way scripts/k8s/ensure_tools installs them when missing.
ARG KUBECTL_VERSION=v1.31.14
ARG HELM_VERSION=v3.22.0
ARG TARGETARCH
RUN curl -fsSL -o /usr/local/bin/kubectl \
      "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" \
    && chmod +x /usr/local/bin/kubectl \
    && curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" \
      | tar -xz -C /usr/local/bin --strip-components=1 "linux-${TARGETARCH}/helm" \
    && kubectl version --client && helm version

# Bake the service in and point the bridge at its entrypoint + service path.
# Bake the service in. --chown so the files belong to the uid this image runs
# as: `np` chmods the action script in place at runtime, and a root-owned tree
# would be read-only for the non-root user.
COPY --chown=10001:10001 . /app/pkg
ENV NP_PACKAGE_NAME=postgres-db \
    NP_SERVICE_PATH=/app/pkg/postgres-db \
    NP_SCOPE_ENTRYPOINT=/app/pkg/postgres-db/entrypoint/entrypoint

# Hand HOME to the runtime user. The RUN steps above ran as root with HOME
# already set to /home/app by the base, so tools invoked at build time left
# root-owned config and cache dirs there (tofu: ~/.terraform.d, az: ~/.azure)
# that the non-root user could not write to at runtime.
RUN chown -R 10001:10001 /home/app

# Drop root for the runtime. Everything above installs as root, as usual; the
# base (worker-bridge 2.0.0+) ships the app user, np on PATH and a writable
# HOME, and leaves the switch to each image. Numeric on purpose: k8s
# admission with runAsNonRoot resolves USER to a numeric id to prove it
# isn't root, and a name doesn't satisfy that check.
USER 10001:10001
