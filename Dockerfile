# Wisecow container image
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
# fortune and cowsay install into /usr/games, which is not on PATH by default
ENV PATH="/usr/games:${PATH}"

RUN apt-get update && \
    apt-get install -y --no-install-recommends fortune-mod cowsay netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Run as a non-root user
RUN useradd -m -u 1001 wisecow
WORKDIR /app
COPY wisecow.sh /app/wisecow.sh
RUN chmod +x /app/wisecow.sh
USER 1001

EXPOSE 4499
CMD ["/app/wisecow.sh"]
