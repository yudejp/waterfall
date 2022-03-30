FROM openjdk:slim-buster AS builder

ARG USERNAME=app
ARG GROUPNAME=app
ARG UID=1000
ARG GID=1000

# Install packages required to build
RUN apt update && apt -y install wget jq

# Retrieve Waterfall: waterfall.jar
ADD ./download-waterfall.sh /build/
RUN /build/download-waterfall.sh

FROM eclipse-temurin:17.0.2_8-jre-alpine AS runner

# Set timezone to Asia/Tokyo
RUN apk --update add tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata && \
    rm -rf /var/cache/apk/*

# Add entire papermc directory
WORKDIR /app

# Cleanup
# Copy files from builder
COPY --from=builder /build/waterfall.jar /bin/

# Run the server (Waterfall)
CMD java -server $JAVA_OPTS -jar /bin/waterfall.jar