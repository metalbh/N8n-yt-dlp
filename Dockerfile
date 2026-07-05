FROM alpine:3.20 AS tools
RUN apk add --no-cache yt-dlp python3 wget xz
RUN wget -O /tmp/ff.tar.xz https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz \
    && mkdir -p /tmp/ff && tar -xf /tmp/ff.tar.xz -C /tmp/ff --strip-components=1 \
    && cp /tmp/ff/ffmpeg /tmp/ff/ffprobe /usr/local/bin/ \
    && chmod a+rx /usr/local/bin/ffmpeg /usr/local/bin/ffprobe
RUN mkdir -p /bundle \
    && tar -cf /bundle/py.tar \
        /usr/bin/yt-dlp \
        /usr/bin/python3 \
        $(ls -d /usr/bin/python3.* 2>/dev/null) \
        $(ls -d /usr/lib/python3.* 2>/dev/null) \
        $(ls /usr/lib/libpython3.*.so* 2>/dev/null)

FROM n8nio/n8n:2.27.3
USER root
COPY --from=tools /bundle/py.tar /tmp/py.tar
RUN tar -xf /tmp/py.tar -C / && rm /tmp/py.tar
COPY --from=tools /usr/local/bin/ffmpeg  /usr/local/bin/ffmpeg
COPY --from=tools /usr/local/bin/ffprobe /usr/local/bin/ffprobe
RUN ln -sf /usr/bin/yt-dlp /usr/local/bin/yt-dlp
ENV YT_DLP_PATH=/usr/bin/yt-dlp
USER node
