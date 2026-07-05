FROM alpine:3.20 AS tools
RUN apk add --no-cache wget tar xz
# yt-dlp_linux：靜態單檔，內含自己的 python，不依賴目標映像
RUN wget -O /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux \
    && chmod a+rx /usr/local/bin/yt-dlp
# ffmpeg 靜態版(不依賴系統函式庫)
RUN wget -O /tmp/ff.tar.xz https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz \
    && mkdir -p /tmp/ff && tar -xf /tmp/ff.tar.xz -C /tmp/ff --strip-components=1 \
    && cp /tmp/ff/ffmpeg /usr/local/bin/ffmpeg \
    && cp /tmp/ff/ffprobe /usr/local/bin/ffprobe \
    && chmod a+rx /usr/local/bin/ffmpeg /usr/local/bin/ffprobe

FROM n8nio/n8n:2.27.3
USER root
COPY --from=tools /usr/local/bin/yt-dlp /usr/local/bin/yt-dlp
COPY --from=tools /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=tools /usr/local/bin/ffprobe /usr/local/bin/ffprobe
ENV YT_DLP_PATH=/usr/local/bin/yt-dlp
USER node
