FROM java:8-jdk

MAINTAINER paladintyrion <paladintyrion@gmail.com>

ENV SCALA_VERSION 2.12.4 \
    SBT_VERSION 1.0.2 \
    ZK_HOSTS=0.0.0.0:2181 \
    KM_VERSION=1.3.3.14 \
    KM_CONFIGFILE="conf/application.conf" \
    KM_USERNAME="paladin" \
    KM_PASSWORD="paladin" \
    KM_ARGS="-Dhttp.port=9449"

RUN apt-get -qq update && \
    apt-get install -y wget curl unzip

# Install scala
RUN curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
    echo >> /root/.bashrc && \
    echo "export PATH=~/scala-$SCALA_VERSION/bin:$PATH" >> /root/.bashrc

# Install sbt
RUN curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
    dpkg -i sbt-$SBT_VERSION.deb && \
    rm sbt-$SBT_VERSION.deb && \
    apt-get update && \
    apt-get install sbt && \
    sbt sbtVersion

# Install kafka-manager
RUN mkdir -p /tmp && \
    cd /tmp && \
    wget https://github.com/yahoo/kafka-manager/archive/${KM_VERSION}.tar.gz && \
    tar zxf ${KM_VERSION}.tar.gz && \
    cd /tmp/kafka-manager-${KM_VERSION} && \
    sbt clean dist && \
    unzip -d / ./target/universal/kafka-manager-${KM_VERSION}.zip && \
    rm -fr /tmp/* /root/.sbt /root/.ivy2 && \
    apt-get autoremove -y wget unzip curl sbt

COPY start-kafka-manager.sh /kafka-manager-${KM_VERSION}/start-kafka-manager.sh
RUN chmod +x /kafka-manager-${KM_VERSION}/start-kafka-manager.sh

WORKDIR /kafka-manager-${KM_VERSION}
EXPOSE 9449

ENTRYPOINT ["./start-kafka-manager.sh"]
