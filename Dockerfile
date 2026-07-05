# 以 n8n 官方映像為基底，安裝「musl 原生」的 yt-dlp 與 ffmpeg。
#
# 為什麼要這樣做：
#   n8n-nodes-youtube-dl 自帶的是「glibc 版 yt-dlp binary」，在 Alpine(musl) 上會出現
#   dladdr1: symbol not found。改提供一顆 musl 原生的 yt-dlp，再用 YT_DLP_PATH 指過去。

FROM n8nio/n8n:2.27.3

USER root

# 用 python3 -m pip 而不是直接叫 pip，避免新版 Alpine 找不到 pip 指令(exit 127)。
# 先試 apk 直接裝 yt-dlp；若該版 Alpine 沒有此套件，再退回用 pip 安裝最新版。
RUN apk add --no-cache ffmpeg python3 py3-pip \
    && ( apk add --no-cache yt-dlp \
         || python3 -m pip install --break-system-packages --no-cache-dir -U yt-dlp ) \
    && ln -sf "$(command -v yt-dlp)" /usr/local/bin/yt-dlp \
    && /usr/local/bin/yt-dlp --version \
    && ffmpeg -version

# 讓 n8n-nodes-youtube-dl 直接用系統這顆 yt-dlp
ENV YT_DLP_PATH=/usr/local/bin/yt-dlp

USER node
