FROM alpine:3.20 AS tools
RUN apk add --no-cache python3 py3-pip wget xz
RUN python3 -m pip install --break-system-packages --no-cache-dir -U --target=/ytdlp-lib yt-dlp
RUN wget -O /tmp/ff.tar.xz https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz \
    && mkdir -p /tmp/ff && tar -xf /tmp/ff.tar.xz -C /tmp/ff --strip-components=1 \
    && cp /tmp/ff/ffmpeg /tmp/ff/ffprobe /usr/local/bin/ \
    && chmod a+rx /usr/local/bin/ffmpeg /usr/local/bin/ffprobe
RUN mkdir -p /bundle \
    && tar -cf /bundle/py.tar \
        /usr/bin/python3 \
        $(ls -d /usr/bin/python3.* 2>/dev/null) \
        $(ls -d /usr/lib/python3.* 2>/dev/null) \
        $(ls /usr/lib/libpython3.*.so* 2>/dev/null)

FROM n8nio/n8n:2.29.1
USER root
COPY --from=tools /bundle/py.tar /tmp/py.tar
RUN tar -xf /tmp/py.tar -C / && rm /tmp/py.tar
COPY --from=tools /ytdlp-lib /ytdlp-lib
COPY --from=tools /usr/local/bin/ffmpeg  /usr/local/bin/ffmpeg
COPY --from=tools /usr/local/bin/ffprobe /usr/local/bin/ffprobe
RUN printf '#!/bin/sh\nexec python3 /ytdlp-lib/yt_dlp "$@"\n' > /usr/bin/yt-dlp \
    && chmod a+rx /usr/bin/yt-dlp \
    && ln -sf /usr/bin/yt-dlp /usr/local/bin/yt-dlp
RUN printf -- '--js-runtimes node:/usr/local/bin/node\n--remote-components ejs:github\n--cookies /root/.n8n/cookies.txt\n' > /etc/yt-dlp.conf
ENV PYTHONPATH=/ytdlp-lib
ENV YT_DLP_PATH=/usr/bin/yt-dlp
USER node
