FROM n8nio/n8n:2.27.3

USER root

RUN apk add --no-cache ffmpeg python3 wget ca-certificates
RUN wget -O /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
RUN chmod a+rx /usr/local/bin/yt-dlp
RUN /usr/local/bin/yt-dlp --version
RUN ffmpeg -version

ENV YT_DLP_PATH=/usr/local/bin/yt-dlp

USER node
