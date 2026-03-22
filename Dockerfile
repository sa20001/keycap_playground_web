FROM python:3.12-slim

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        inkscape \
        prusa-slicer \
        pstoedit \
        7zip \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

WORKDIR /app
RUN useradd -m appuser
# TODO do not copy files ignored by .gitignore -> dockerignore should be a copy of .gitignore
# TODO install more fonts
COPY --chown=appuser:appuser main.py /app/main.py
COPY --chown=appuser:appuser src /app/src

ENV DEV=False

USER appuser

CMD ["/bin/bash"]