FROM centos:latest

# This file creates an instance of the SAP Cloud Connector on your local machine.
# This file is based on the great work by Nabi Zamani (https://github.com/nzamani).

# Install a basic centos linux and update everything.
RUN yum -y update; yum clean all
RUN yum -y install initscripts which unzip wget net-tools less; yum clean all

# If you want to install the latest version of the cloud connector, update these version numbers.
# You will find the latest version here: https://tools.hana.ondemand.com/#cloud
# You need to quickly download the Linux version to obtain the Patch level for the cloud connector.

# Get the cloud connector
# If you run into error, check the URL for changed names or locations.
#
# URL AS OF AUG 9, 2019
# https://tools.hana.ondemand.com/additional/sapcc-2.12.0.1-linux-x64.zip
ARG SAPCC_VERSION=2.12.0
ARG SAPCC_PATCH=1

RUN wget --no-check-certificate --no-cookies \
--header "Cookie: eula_3_1_agreed=tools.hana.ondemand.com/developer-license-3_1.txt; \
path=/;" -S https://tools.hana.ondemand.com/additional/sapcc-$SAPCC_VERSION.$SAPCC_PATCH-linux-x64.zip

# Get the SAP Java Virtual Machine
# If you run into error, check the URL for changed names or locations.
#
# URL AS OF AUG 9, 2019
# https://tools.hana.ondemand.com/additional/sapjvm-8.1.055-linux-x64.rpm
ARG SAPJVM_VERSION=8.1.055
ARG SAPCC_MIN_PATCH=15

RUN wget --no-check-certificate --no-cookies \
--header "Cookie: eula_3_1_agreed=tools.hana.ondemand.com/developer-license-3_1.txt; \
path=/;" -S https://tools.hana.ondemand.com/additional/sapjvm-$SAPJVM_VERSION-linux-x64.rpm

# Install everything
RUN unzip sapcc-$SAPCC_VERSION.$SAPCC_PATCH-linux-x64.zip
RUN rpm -i sapjvm-$SAPJVM_VERSION-linux-x64.rpm &&\
 rpm -i com.sap.scc-ui-$SAPCC_VERSION-$SAPCC_MIN_PATCH.x86_64.rpm

# Start the Cloud Connector
RUN chsh -s /bin/bash sccadmin

# In the vanilla installation, the cloud connector runs on port 8443
EXPOSE 8443
USER sccadmin
WORKDIR /opt/sap/scc

# This is essentially copied from the starting script.
CMD /opt/sapjvm_8/bin/java \
    -server \
    -XtraceFile=log/vm_@PID_trace.log \
    -XX:+GCHistory \
    -XX:GCHistoryFilename=log/vm_@PID_gc.prf \
    -XX:+HeapDumpOnOutOfMemoryError \
    -XX:+DisableExplicitGC \
    -Xms1024m \
    -Xmx1024m \
    -XX:MaxNewSize=512m \
    -XX:NewSize=512m \
    -XX:+UseConcMarkSweepGC \
    -XX:TargetSurvivorRatio=85 \
    -XX:SurvivorRatio=6 \
    -XX:MaxDirectMemorySize=2G \
    -Dorg.apache.tomcat.util.digester.PROPERTY_SOURCE=com.sap.scc.tomcat.utils.PropertyDigester \
    -Dosgi.requiredJavaVersion=1.6 \
    -Dosgi.install.area=. \
    -DuseNaming=osgi \
    -Dorg.eclipse.equinox.simpleconfigurator.exclusiveInstallation=false \
    -Dcom.sap.core.process=ljs_node \
    -Declipse.ignoreApp=true \
    -Dosgi.noShutdown=true \
    -Dosgi.framework.activeThreadType=normal \
    -Dosgi.embedded.cleanupOnSave=true \
    -Dosgi.usesLimit=30 \
    -Djava.awt.headless=true \
    -Dio.netty.recycler.maxCapacity.default=256 \
    -jar plugins/org.eclipse.equinox.launcher_1.1.0.v20100507.jar
