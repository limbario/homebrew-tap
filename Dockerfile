FROM alpine/curl:8.9.1 AS download
ARG SCRCPY_VERSION=v3.1
ARG LIM_VERSION=v0.8.8

# Note that scrcpy does not have static linux arm64 releases yet. So,
# this must be built only for arm64 for now.
RUN curl -L https://github.com/Genymobile/scrcpy/releases/download/${SCRCPY_VERSION}/scrcpy-linux-x86_64-${SCRCPY_VERSION}.tar.gz | tar -xvzf - -C /tmp && \
    mv /tmp/scrcpy-linux-x86_64-${SCRCPY_VERSION}/* /tmp/

RUN curl -Lo /tmp/lim https://github.com/limbario/homebrew-tap/releases/download/${LIM_VERSION}/lim-linux-amd64 && chmod +x /tmp/lim

FROM gcr.io/distroless/cc-debian12:nonroot

COPY --from=download /tmp/adb /usr/local/bin/adb
COPY --from=download /tmp/scrcpy /usr/local/bin/scrcpy
COPY --from=download /tmp/scrcpy-server /usr/local/bin/scrcpy-server
COPY --from=download /tmp/lim /usr/local/bin/lim

CMD [ "lim", "run", "android" ]
