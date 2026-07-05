FROM n8nio/n8n:2.27.3

USER root

# 逐步執行 + 印記號，方便從 build log 看出到底卡在哪一步
RUN set -x \
    && echo ">>> STEP 0: alpine version" \
    && cat /etc/os-release | head -n 2 \
    && echo ">>> STEP 1: apk update" \
    && apk update \
    && echo ">>> STEP 2: install ffmpeg" \
    && apk add --no-cache ffmpeg \
    && echo ">>> STEP 3: try apk yt-dlp" \
    && apk add --no-cache yt-dlp \
    && echo ">>> STEP 4: symlink" \
    && ln -sf "$(command -v yt-dlp)" /usr/local/bin/yt-dlp \
    && echo ">>> STEP 5: versions" \
    && /usr/local/bin/yt-dlp --version \
    && ffmpeg -version

ENV YT_DLP_PATH=/usr/local/bin/yt-dlp

USER node
