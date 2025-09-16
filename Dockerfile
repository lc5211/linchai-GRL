# Use a base image with CUDA support for GPU acceleration
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# Set environment variables to non-interactive to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3.11 \
    python3-pip \
    python3.11-venv \
    openjdk-21-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*



# Create a virtual environment
RUN python3.11 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip
RUN pip install --upgrade pip

RUN pip install git+https://github.com/ayaka14732/jax-smi.git
RUN pip install git+https://github.com/AI-Hypercomputer/pathways-utils.git
RUN pip install gcsfs

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . .

# Install submodules and their dependencies
RUN chmod +x scripts/install_submodules.sh
RUN ./scripts/install_submodules.sh --tunix

# Install Python dependencies
# As per README.md, install specific versions of torch and flash-attn
# RUN pip install torch==2.7.0 --index-url https://download.pytorch.org/whl/cu121
# RUN pip install flash-attn==2.8.0.post2 --no-build-isolation

# Install the project in editable mode
RUN pip install -e .

# Arguments for secrets
ARG WANDB_API_KEY
ARG WANDB_ENTITY
ARG HF_TOKEN

# Set environment variables for the container
ENV WANDB_API_KEY=$WANDB_API_KEY
ENV WANDB_ENTITY=$WANDB_ENTITY
ENV HF_TOKEN=$HF_TOKEN

# Set the default command to bash
CMD ["bash"]
