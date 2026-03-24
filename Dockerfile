FROM python:3.12-bookworm

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

RUN curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p $CONDA_DIR && \
    rm Miniconda3-latest-Linux-x86_64.sh && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r && \
    conda create -y --name qwen3-tts -c conda-forge python=3.12 && \
    conda install -n qwen3-tts -y nvidia/label/cuda-12.9.1::cuda-runtime nvidia/label/cudnn-9.10.0::cudnn && \
    conda clean -afy

# Set path to use the Conda environment directly
ENV PATH=$CONDA_DIR/envs/qwen3-tts/bin:$PATH
ENV LD_LIBRARY_PATH=$CONDA_DIR/envs/qwen3-tts/lib:${LD_LIBRARY_PATH:-}

WORKDIR /app

# Ensure all RUN commands execute inside the conda environment wrapper
SHELL ["conda", "run", "--no-capture-output", "-n", "qwen3-tts", "/bin/bash", "-c"]

RUN pip install -U qwen-tts

# Ensure Gradio binds to the network interface, enabling web access from outside the container
ENV GRADIO_SERVER_NAME=0.0.0.0
EXPOSE 8000

# Set the entrypoint command to execute explicitly inside the activated environment
CMD ["conda", "run", "--no-capture-output", "-n", "qwen3-tts", "qwen-tts-demo", "Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice", "--ip", "0.0.0.0", "--port", "8000", "--no-flash-attn"]
