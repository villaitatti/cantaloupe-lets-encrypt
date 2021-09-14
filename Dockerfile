FROM debian:buster

ENV CANTALOUPE_VERSION=5.0.3

EXPOSE 8182

VOLUME /imageroot

# Update packages and install tools
RUN apt-get update -qy && apt-get dist-upgrade -qy && \
    apt-get install -qy --no-install-recommends curl imagemagick \
    libopenjp2-tools ffmpeg unzip default-jre-headless && \
    apt-get -qqy autoremove && apt-get -qqy autoclean

# Install various dependencies

RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-11-jdk-headless \
                ffmpeg \
                libopenjp2-tools \
                liblcms2-dev \
                libpng-dev \
                libzstd-dev \
                libtiff-dev \
                libjpeg-dev \
                zlib1g-dev \
                libwebp-dev \
                libimage-exiftool-perl \
    && rm -rf /var/lib/apt/lists/*

# Run non privileged
RUN adduser --system cantaloupe

# Get and unpack Cantaloupe release archive
RUN curl --silent --fail -OL https://github.com/medusa-project/cantaloupe/releases/download/v$CANTALOUPE_VERSION/Cantaloupe-$CANTALOUPE_VERSION.zip \
    && unzip Cantaloupe-$CANTALOUPE_VERSION.zip \
    && ln -s cantaloupe-$CANTALOUPE_VERSION cantaloupe \
    && rm Cantaloupe-$CANTALOUPE_VERSION.zip \
    && mkdir -p /var/log/cantaloupe /var/cache/cantaloupe \
    && chown -R cantaloupe /cantaloupe /var/log/cantaloupe /var/cache/cantaloupe \
    && cp -rs /cantaloupe/deps/Linux-x86-64/* /usr/

USER cantaloupe
CMD ["sh", "-c", "java -Dcantaloupe.config=/cantaloupe/cantaloupe.properties.sample -jar /cantaloupe/cantaloupe-$CANTALOUPE_VERSION.jar"]
