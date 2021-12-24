FROM vapor/toolbox:2.0.4

RUN apt-get update -y && apt-get install -y \
    libpq-dev

RUN useradd -ms /bin/bash swift
RUN mkdir -p /usr/src/app && chown swift:swift /usr/src/app

USER swift

COPY --chown=swift:swift . /usr/src/app

WORKDIR /usr/src/app

EXPOSE 8080

CMD ["vapor", "run", "serve"]