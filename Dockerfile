# Wisecow container image
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/games:${PATH}"

RUN apt-get update && \
    apt-get install -y --no-install-recommends fortune-mod fortunes-min cowsay netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*
# Non-root user; -m creates /home/wisecow owned by this user
RUN useradd -m -u 1001 wisecow

# Run from the user's home so the script can create its "response" pipe
WORKDIR /home/wisecow
COPY --chown=1001:1001 wisecow.sh ./wisecow.sh
RUN sed -i 's/\r$//' wisecow.sh && chmod +x wisecow.sh

USER 1001
EXPOSE 4499
CMD ["./wisecow.sh"]