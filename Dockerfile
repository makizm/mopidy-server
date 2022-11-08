ARG DEBIAN_FRONTEND=noninteractive

FROM debian:bullseye-slim

RUN apt-get update \
	&& apt-get install -y curl gnupg

# fetch and install mopidy server
RUN mkdir -p /usr/local/share/keyrings
RUN curl -o /usr/local/share/keyrings/mopidy-archive-keyring.gpg \
	https://apt.mopidy.com/mopidy.gpg

RUN curl -o /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/buster.list

RUN apt-get update \
	&& apt-get install -y \
	mopidy \
	mopidy-mpd \
	mopidy-soundcloud \
	mopidy-spotify

# Clean-up
RUN apt-get purge --auto-remove -y gnupg git \
	&& apt-get clean

# Default configuration.
COPY mopidy.conf /etc/mopidy/mopidy.conf

# Runs as mopidy user by default.
USER mopidy

# Print effective config
# RUN mopidyctl config

VOLUME ["/tmp/snapfifo", "/tmp/snapfifo"]

EXPOSE 6600 6680

CMD ["mopidy"]

HEALTHCHECK --interval=5s --timeout=2s --retries=20 \
    CMD curl --connect-timeout 5 --silent --show-error --fail http://localhost:6680/ || exit 1