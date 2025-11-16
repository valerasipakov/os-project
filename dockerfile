FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash coreutils \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY src/ src/
COPY config/ config/

RUN find src/scripts -type f -name "*.sh" -exec chmod +x {} +

RUN pip install --no-cache-dir pytest

ENV PYTHONUNBUFFERED=1

CMD ["bash","-lc","pytest -q src/tests/unit_tests && echo 'TESTS PASSED' || (echo 'TESTS FAILED'; exit 1)"]
