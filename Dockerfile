FROM openjdk:8-alpine

# The bash shell is required by Polunote utilities
RUN apk add --no-cache bash python3 python3-dev gcc \
    gfortran musl-dev g++ \
    libffi-dev openssl-dev \
    libxml2 libxml2-dev \
    libxslt libxslt-dev \
    libc-dev linux-headers \
    mariadb-dev postgresql-dev \
    freetype-dev libpng-dev \
    libxml2-dev libxslt-dev \
    libjpeg-turbo-dev zlib-dev && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    \
    echo "**** install pip ****" && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    pip3 install --no-cache jep jedi virtualenv pyspark numpy pandas matplotlib

# Install build dependencies
RUN apk add --no-cache --virtual=.dependencies tar wget

RUN mkdir /usr/local/spark/ && \
    wget -O- "http://mirror.nbtelecom.com.br/apache/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz" \
    | tar xzf - -C /usr/local/spark --strip-components=1
RUN wget -O- "http://downloads.lightbend.com/scala/2.11.11/scala-2.11.11.tgz" \
    | tar xzf - -C /usr/local --strip-components=1

# Remove build dependencies
RUN apk del --no-cache .dependencies

COPY polynote /app

ENV SPARK_HOME /usr/local/spark
ENV PATH $PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin
ENV PYSPARK_ALLOW_INSECURE_GATEWAY 1

WORKDIR /app

EXPOSE 8192 8192

CMD ["./polynote"]
