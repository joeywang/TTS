# Use CUDA 11.8 base image
ARG BASE=nvidia/cuda:11.8.0-base-ubuntu22.04
FROM ${BASE}

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    gcc g++ make python3 python3-dev python3-pip python3-venv python3-wheel \
    git \
    espeak-ng libsndfile1-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Python dependencies
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel && \
    python3 -m pip install --no-cache-dir llvmlite --ignore-installed && \
    python3 -m pip install --no-cache-dir torch torchaudio --extra-index-url https://download.pytorch.org/whl/cu118 && \
    # Fix for arm-64
    pip install sudachipy --no-binary :all: --no-use-pep517 || \
    (git clone https://github.com/WorksApplications/SudachiPy.git && \
     cd SudachiPy && \
     pip install -e .)

# Set working directory
WORKDIR /app

# Copy TTS repository contents
COPY . /app

# Install TTS
RUN make install

# Set entrypoint and default command
ENTRYPOINT ["tts"]
CMD ["--help"]
