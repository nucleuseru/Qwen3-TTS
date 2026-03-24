FROM nvidia/cuda:13.2.0-cudnn-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HF_HOME=/app/models
ENV MODELSCOPE_CACHE=/app/models

RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg python3.12 python3.12-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app
COPY . .

RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -e .

ENV GRADIO_SERVER_NAME=0.0.0.0
EXPOSE 8000

CMD ["qwen-tts-demo", "Qwen/Qwen3-TTS-12Hz-1.7B-Base", "--ip", "0.0.0.0", "--port", "8000", "--no-flash-attn"]
