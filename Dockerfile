# ---------- Stage 1: build ColorSCAD ----------
FROM python:3.12-slim AS builder

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        git \
        cmake \
        g++ \
    && rm -rf /var/lib/apt/lists/*

# build colorscad
RUN git clone https://github.com/jschobben/colorscad.git /tmp/colorscad \
    && cd /tmp/colorscad \
    && mkdir build \
    && cd build \
    && cmake .. \
    && cmake --build .

# ---------- Stage 2: runtime ----------
FROM python:3.12-slim

# runtime dependencies only
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        openscad \
    && rm -rf /var/lib/apt/lists/*

# copy colorscad binaries/scripts from builder
COPY --from=builder /tmp/colorscad/colorscad.sh /usr/local/bin/colorscad
COPY --from=builder /tmp/colorscad/build/3mfmerge /usr/local/bin/3mfmerge

RUN chmod +x /usr/local/bin/colorscad

# python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

WORKDIR /app
COPY . /app

CMD ["/bin/bash"]