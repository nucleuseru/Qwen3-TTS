FROM python:3.12-bookworm

ENV MAX_JOBS=4

RUN pip install -U qwen-tts && \
    pip install -U flash-attn --no-build-isolation

ENV GRADIO_SERVER_NAME=0.0.0.0
EXPOSE 8000

CMD ["qwen-tts-demo", "Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice", "--ip", "0.0.0.0", "--port", "8000"]
