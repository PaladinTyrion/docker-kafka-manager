FROM java:8-jdk

MAINTAINER paladintyrion <paladintyrion@gmail.com>

ENV SCALA_VERSION 2.11.12
# ENV SBT_VERSION 0.13.9
ENV ZK_HOSTS=0.0.0.0:2181
ENV KM_VERSION=1.3.3.17
ENV KM_CONFIGFILE="conf/application.conf"
ENV KM_USERNAME="paladin"
ENV KM_PASSWORD="paladin"
ENV KM_ARGS="-Dhttp.port=9449"
ENV PATH=/opt/scala-${SCALA_VERSION}/bin:$PATH

RUN set -x && \
    apt-get update -qq && \
    apt-get install -y wget curl unzip vim && \
    # Install scala
    mkdir -p /opt && \
    curl -fsL https://downloads.lightbend.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /opt && \
    # Install sbt
    echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \
    apt-get update && \
    apt-get install sbt && \
    sbt --version && \
    # Install kafka-manager
    mkdir -p /tmp && \
    cd /tmp && \
    wget -q https://github.com/yahoo/kafka-manager/archive/${KM_VERSION}.tar.gz && \
    tar zxf ${KM_VERSION}.tar.gz && \
    cd /tmp/kafka-manager-${KM_VERSION} && \
    ./sbt clean dist && \
    unzip -d / ./target/universal/kafka-manager-${KM_VERSION}.zip && \
    rm -fr /tmp/* /root/.sbt /root/.ivy2 && \
    apt-get autoremove -y wget curl unzip sbt && apt-get clean -y && \
    set +x

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

COPY start-kafka-manager.sh /kafka-manager-${KM_VERSION}/start-kafka-manager.sh
RUN chmod +x /kafka-manager-${KM_VERSION}/start-kafka-manager.sh

WORKDIR /kafka-manager-${KM_VERSION}
EXPOSE 9449

ENTRYPOINT ["./start-kafka-manager.sh"]
