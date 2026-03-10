# ---------- Stage 1: build ColorSCAD ----------
FROM python:3.12-slim AS builder

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        git \
        cmake \
        g++ \
    && rm -rf /var/lib/apt/lists/*

# build openscad
RUN git clone --recursive https://github.com/openscad/openscad.git /tmp/openscad \
    && cd /tmp/openscad \
    && ./scripts/uni-get-dependencies.sh qt6 \
    && ./scripts/check-dependencies.sh \
    && cmake -B build -DEXPERIMENTAL=1 -DHEADLESS=ON -DCMAKE_INSTALL_PREFIX=/opt/openscad \
    && cmake --build build -j 8 \
    && cmake --install build

# collect openscad dependencies
RUN mkdir /tmp/deps \
 && ldd /opt/openscad/bin/openscad \
      | grep "=> /" \
      | awk '{print $3}' \
      | sort -u \
      | xargs -I{} cp -v {} /tmp/deps/

# build colorscad
RUN git clone https://github.com/jschobben/colorscad.git /tmp/colorscad \
    && cd /tmp/colorscad \
    && mkdir build \
    && cd build \
    && cmake .. \
    && cmake --build . -j $(nproc)
# build 3mfmerge
RUN cd /tmp/colorscad/3mfmerge \
    && mkdir build \
    && cd build \
    && cmake .. \
    && cmake --build . -j $(nproc)

# ---------- Stage 2: runtime ----------
FROM python:3.12-slim

# Copy openscad binaries from builder
COPY --from=builder /opt/openscad /opt/openscad
# Add OpenSCAD to PATH and 
ENV PATH="/opt/openscad/bin:${PATH}"
# set LD_LIBRARY_PATH for its dependencies
COPY --from=builder /tmp/deps /opt/openscad/lib
ENV LD_LIBRARY_PATH="/opt/openscad/lib:${LD_LIBRARY_PATH}"

# python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy colorscad binaries from builder
COPY --from=builder /tmp/colorscad/colorscad.sh /usr/local/bin/colorscad
RUN chmod +x /usr/local/bin/colorscad

# Copy 3mfmerge binary from builder
COPY --from=builder /tmp/colorscad/3mfmerge/bin/3mfmerge /usr/local/bin/3mfmerge
RUN chmod +x /usr/local/bin/3mfmerge

WORKDIR /app
COPY . /app

# create a non-root user
RUN useradd -m appuser \
    && chown -R appuser:appuser /app

# switch to the unprivileged user for runtime
USER appuser

CMD ["/bin/bash"]