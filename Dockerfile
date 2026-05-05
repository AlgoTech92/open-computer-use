# SPDX-License-Identifier: BUSL-1.1
# Copyright (c) 2025 Open Computer Use Contributors
# Dockerfile for Coolify deployment - Computer Use MCP Server only
# This builds just the orchestrator (computer-use-server/), NOT the workspace image

FROM python:3.14-slim

LABEL maintainer="Open Computer Use Contributors"
LABEL description="Computer Use MCP Server for Coolify deployment"

# Set working directory
WORKDIR /app

# Copy requirements first (for caching)
COPY computer-use-server/requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire computer-use-server directory
COPY computer-use-server/ /app/

# Copy skills directory (needed for skill management)
COPY skills/ /app/skills/

# Copy static files if needed
COPY computer-use-server/static/ /app/static/

# Environment variables
ENV PYTHONUNBUFFERED=1
ENV MCP_API_KEY=""
ENV DOCKER_IMAGE=open-computer-use:latest
ENV PUBLIC_BASE_URL=http://localhost:8081
ENV COMMAND_TIMEOUT=600
ENV SUB_AGENT_TIMEOUT=3600

# Expose MCP server port
EXPOSE 8081

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:8081/health')"

# Run the MCP server
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8081", "--workers", "2"]
