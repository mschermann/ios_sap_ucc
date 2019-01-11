# Tutorial on how to start an iOS app that connects to a SAP S4 via SAP Cloud Connector

This is a tutorial for the use of iOS and SAP in an educational context. This tutorial assumes that you are a customer of a SAP UCC (University Competence Center) and that you have access to a SAP system provided by your UCC. 

The objective of this tutorial is to jumpstart an iOS development project that connects to a UCC-hosted SAP system. We connect to the SAP system via Cloud Connector, because in typical productive environments, the SAP system would be behind a firewall and not directly accessible to mobile devices. 

This tutorial allows you to:

* Check the SAP UCC System to make sure that it works
* Install SAP Cloud Connector on your local machine via Docker
* Setup SAP Cloud Connector
* Setup the SAP Cloud Platform Cockpit
* Use the SAP Cloud Platform SDK for iOS Assistant to build a small app that tests the connection.

## Prerequisites:

### Installed Docker Environment

* Install Docker by following the instructions [here](https://hub.docker.com/editions/community/docker-ce-desktop-mac).

### From your UCC (University Competence Center)

* Host name (e.g., systemname.cob.csuchico.edu)
* Port number (e.g., 8022)
* Client number (e.g., 465)
* Login and password information 

### For access to the [SAP Cloud Platform Cockpit](https://account.hanatrial.ondemand.com/)

* Username and password (typically a trial account)
* If you do not have access, register [here](https://accounts.sap.com/ui/public/showRegisterForm?spName=https%3A%2F%2Fnwtrial.ondemand.com%2Fservices)

### For iOS Development

* Download Xcode from the Mac App Store
* Download the [SAP Cloud Platform SDK for iOS](https://developers.sap.com/topics/cloud-platform-sdk-for-ios.html)

## Check the SAP UCC System to make sure that it works



## Install the SAP Cloud Connector on your local machine

This is an abbreviated installation 'how-to'. For a full-depth version, I recommend this [tutorial](https://github.com/nzamani/sap-cloud-connector-docker). There is even a YouTube video to follow.

* Open a terminal and run `docker --version`. If the machine returns a version number, you are good to go. If you get an error, check your Docker installation.
* Download the `Dockerfile` from the folder `sapcc` to a directory on your local machine.
* In Terminal, go into the new directory with the `Dockerfile` and run `docker build -t sapcc .` to build the Docker container image (Do not forget the `.` at the end)
* Create a Docker container from the image by executing `docker run -p 8443:8443 --name sapcc -d sapcc`
* Start the Docker container with `docker start sapcc`
* Wait a minute to allow the SAP Cloud Connector to start and then point your favorite browser to [https://localhost:8433](https://localhost:8433). The default user is `Administrator` with the standard password `manage`. You will be asked to change the password.

## Setup the SAP Cloud Connector
* In the menu, choose `Connector`, and `+ Add Subaccount`. The Region is most likely `Europe (Rot) - Trial`. Enter your subaccount ID (which looks like pXXXXXXXXXXtrial) and the username is the same without `trial` at the end. If everything works, the statur should be green.
* In the menu, choose `Cloud To On-Premise` and setup your UCC SAP system. Choose `ABAP System` or `SAP HANA`, Protocol is `HTTP`, `Internal host` is the hostname of the UCC system, `Internal port` is the port number of the UCC system. Set `Virtual Host` to `ucc` and `Virtual port` to the same port as your internal port. `Principal type` should be set to `None`. Check the availability of the internal host. The Check Result column should say `Reachable` in green letters. Next, set `/` as the available resource and ensure the the access policy is set to `Path and all sub-paths`. In the tab `Principal Propagation` you can trust everything.

## Setup the SAP Cloud Platform Cockpit

In the SAP Cloud Platform Cockpit (I assume that you use the Neo Trial version), choose `Connectivity > Cloud Connectors` to confirm that a connection with your cloud connector exists. You should see a green `Connected`.
* Go to `Connectivity > Destinations` to setup a destination for your UCC SAP system. You choose a name, the type should be `HTTP`, the URL should be the virtual host from the cloud connector plus `/sap/opu/odata` (confirm this with your UCC SAP system), the proxy type should be `On Premise`, use `Basic Authentication` and include your SAP login and password. 
* You need to set additional properties based on the following table:

| Key | Value | Explanation |
|-----|-------|-------------|
|sap-client| <Your client number> | You want to access your client only.|
|WebIDEEnabled|true| For testing purposed and WebIDE access|
|WebIDESystem|<Your system id>| You need to identify your system|
|WebIDEUsage| dev_abap,bsp_execute_abap,ui5_execute_abap,odata_abap,odata_gen,mobile,ui5_execute_abap | Defines how to use the system, **mobile** is important|


