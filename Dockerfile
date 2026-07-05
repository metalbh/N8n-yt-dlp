FROM n8nio/n8n:2.27.3

USER root

# ffmpeg 用 apk 裝；yt-dlp 直接抓官方 zipapp(只需系統 python3，musl 相容)
RUN set -x \
    && apk add --no-cache ffmpeg python3 \
    && wget -O /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    && chmod a+rx /usr/local/bin/yt-dlp \
    && /usr/local/bin/yt-dlp --version \
    && ffmpeg -version

ENV YT_DLP_PATH=/usr/local/bin/yt-dlp

USER node
