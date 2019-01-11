# Tutorial on how to start an iOS app that connects to a SAP S4 via SAP Cloud Connector

This is a tutorial for the use of iOS and SAP in an educational context. This tutorial assumes that you are a customer of a SAP UCC (University Competence Center) and that you have access to a SAP system provided by your UCC. 

The objective of this tutorial is to jumpstart an iOS development project that connects to a UCC-hosted SAP system. We connect to the SAP system via Cloud Connector, because in typical productive environments, the SAP system would be behind a firewall and not directly accessible to mobile devices. 

This tutorial allows you to:

* Install SAP Cloud Connector on your local machine via Docker
* Setup SAP Cloud Connector
* Setup the SAP Cloud Platform Cockpit
* Check the SAP UCC System to make sure that it works
* Use the SAP Cloud Platform SDK for iOS Assistant to build a small app that tests the connection.

## Prerequisites:

### Installed Docker Environment

* Install Docker by following the instructions [here](https://hub.docker.com/editions/community/docker-ce-desktop-mac)

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

## Install the SAP Cloud Connector on your local machine

This is an abbreviated installation 'how-to'. For a full-depth version, I recommend this [tutorial](https://github.com/nzamani/sap-cloud-connector-docker). There is even a YouTube video to follow.

* Open a terminal and run `docker --version`. If the machine returns a version number, you are good to go. If you get an error, check your Docker installation.
* Download the `Dockerfile` from the folder `sapcc` to a directory on your local machine.
* In Terminal, go into the new directory with the `Dockerfile` and run `docker build -t sapcc .`

