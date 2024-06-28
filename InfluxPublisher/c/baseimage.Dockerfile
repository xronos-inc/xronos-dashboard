ARG BASEIMAGE=alpine:latest
FROM ${BASEIMAGE}

# LF tracing
ARG LF_TRACING_VERSION=v1.1
ENV LF_TRACING_VERSION=${LF_TRACING_VERSION}

# install build tools
RUN apk add --no-cache gcc musl-dev cmake make tar gzip

RUN mkdir -p /usr/lib/x86_64-linux-gnu/
ADD https://github.com/xronos-inc/xronos-dashboard/releases/download/${LF_TRACING_VERSION}/lf-tracing-x86_64-linux-gnu-${LF_TRACING_VERSION}.tar.gz /usr/lib/x86_64-linux-gnu/
RUN tar -xvf /usr/lib/x86_64-linux-gnu/lf-tracing-x86_64-linux-gnu-${LF_TRACING_VERSION}.tar.gz -C /usr/lib/x86_64-linux-gnu/ \
    && rm /usr/lib/x86_64-linux-gnu/lf-tracing-x86_64-linux-gnu-${LF_TRACING_VERSION}.tar.gz

RUN mkdir -p /usr/lib/aarch64-linux-gnu/
ADD https://github.com/xronos-inc/xronos-dashboard/releases/download/${LF_TRACING_VERSION}/lf-tracing-aarch64-linux-gnu-${LF_TRACING_VERSION}.tar.gz /usr/lib/aarch64-linux-gnu/
RUN tar -xvf /usr/lib/aarch64-linux-gnu/lf-tracing-aarch64-linux-gnu-${LF_TRACING_VERSION}.tar.gz -C /usr/lib/aarch64-linux-gnu/ \
    && rm /usr/lib/aarch64-linux-gnu/lf-tracing-aarch64-linux-gnu-${LF_TRACING_VERSION}.tar.gz

STOPSIGNAL SIGINT
