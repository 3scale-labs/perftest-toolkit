from centos:7

RUN yum -y install java-1.8.0-openjdk unzip && curl -sSLf "https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-3.1.tgz" | tar -C "/opt/" -xz

ADD https://repo1.maven.org/maven2/kg/apc/cmdrunner/2.0/cmdrunner-2.0.jar /opt/apache-jmeter-3.1/lib/cmdrunner-2.0.jar
ADD https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/0.11/jmeter-plugins-manager-0.11.jar /opt/apache-jmeter-3.1/lib/ext/jmeter-plugins-manager-0.11.jar

RUN java -cp /opt/apache-jmeter-3.1/lib/ext/jmeter-plugins-manager-0.11.jar org.jmeterplugins.repository.PluginManagerCMDInstaller \
    && /opt/apache-jmeter-3.1/bin/PluginsManagerCMD.sh install jpgc-casutg \
    && /opt/apache-jmeter-3.1/bin/PluginsManagerCMD.sh install jpgc-ggl \
    && /opt/apache-jmeter-3.1/bin/PluginsManagerCMD.sh install jpgc-standard \
    && /opt/apache-jmeter-3.1/bin/PluginsManagerCMD.sh install jpgc-tst

ADD ./conf/* /opt/apache-jmeter-3.1/bin/
ADD ./entrypoint.sh ./entrypoint.sh
RUN chmod u+x ./entrypoint.sh

ENTRYPOINT ./entrypoint.sh
