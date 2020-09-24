FROM alpine:3.10


ENV ES_VERSION 7.8.1
ENV ES_HOME elasticsearch-$ES_VERSION
ENV JAVA_HOME /usr/lib/jvm/default-jvm/jre

ENV ES_JAVA_OPTS "-Xms256m -Xmx256m"

EXPOSE 9200 9300

COPY config /

RUN apk --update --upgrade add bash \
    su-exec \
    openjdk11-jre \

    && wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION-linux-x86_64.tar.gz \
    && tar -xzf elasticsearch-$ES_VERSION-linux-x86_64.tar.gz \

    && rm -rf /elasticsearch-$ES_VERSION/modules/x-pack-ml \
    && rm -rf elasticsearch-$ES_VERSION-linux-x86_64.tar.gz \

    && adduser -DH -s /sbin/nologin elasticsearch \
    && chown -R elasticsearch:elasticsearch /elasticsearch-$ES_VERSION/ /data \

    && rm /elasticsearch-$ES_VERSION/config/elasticsearch.yml \
    && mv elasticsearch.yml /elasticsearch-$ES_VERSION/config/elasticsearch.yml

