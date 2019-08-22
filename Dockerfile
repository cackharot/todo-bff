FROM ubuntu:18.04
ARG BINARY_PATH
ENV APP_DIR=/opt/app
RUN mkdir -p $APP_DIR
WORKDIR $APP_DIR
RUN apt-get update && apt-get install -y \
  ca-certificates \
  libgmp-dev \
  curl
COPY "$BINARY_PATH" $APP_DIR/app-exe
RUN chmod +x $APP_DIR/app-exe
ENTRYPOINT "$APP_DIR/app-exe"
