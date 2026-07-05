# 以 n8n 官方映像為基底，安裝「musl 原生」的 yt-dlp 與 ffmpeg。
#
# 為什麼要這樣做：
#   n8n-nodes-youtube-dl 自帶的是「glibc 版 yt-dlp binary」(PyInstaller 打包)，
#   裡面內含 libpython3.xx.so。Alpine 是 musl libc，載入它時會出現
#     Failed to load Python shared library ... dladdr1: symbol not found
#   連節點內建的 libmuslfix.so shim 也補不好這個 relocation。
#
# 解法：改提供一顆「musl 原生」的 yt-dlp(用 pip 裝，跑在系統 musl python3 上)，
#       再用 YT_DLP_PATH 讓節點改用它，不要再去執行自帶的 glibc binary。

FROM n8nio/n8n:2.27.3

USER root

RUN apk add --no-cache ffmpeg python3 py3-pip \
    && pip install --break-system-packages --no-cache-dir -U yt-dlp \
    && ln -sf "$(command -v yt-dlp)" /usr/local/bin/yt-dlp \
    && /usr/local/bin/yt-dlp --version \
    && ffmpeg -version

# 讓 n8n-nodes-youtube-dl 直接用系統這顆 yt-dlp
ENV YT_DLP_PATH=/usr/local/bin/yt-dlp

USER node
