from centos:7

RUN yum -y install java-1.8.0-openjdk unzip && curl -sSLf "https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.2.tgz" | tar -C "/opt/" -xz

ADD https://repo1.maven.org/maven2/kg/apc/cmdrunner/2.2/cmdrunner-2.2.jar /opt/apache-jmeter-5.2/lib
ADD https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/1.3/jmeter-plugins-manager-1.3.jar /opt/apache-jmeter-5.2/lib/ext

RUN java -cp /opt/apache-jmeter-5.2/lib/ext/jmeter-plugins-manager-1.3.jar org.jmeterplugins.repository.PluginManagerCMDInstaller \
    && /opt/apache-jmeter-5.2/bin/PluginsManagerCMD.sh install jpgc-casutg,jpgc-ggl,jpgc-standard,jpgc-tst

ADD ./conf/* /opt/apache-jmeter-5.2/bin/
ADD ./entrypoint.sh ./entrypoint.sh
RUN chmod u+x ./entrypoint.sh

ENTRYPOINT ./entrypoint.sh
