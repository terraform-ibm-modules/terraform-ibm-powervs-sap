---

copyright:
  years: 2023
lastupdated: "2023-04-13"

keywords:

subcollection: deployable-reference-architectures

authors:
  - name: Arnold Beilmann

version: v1.0.0

# Whether the reference architecture is published to Cloud Docs production.
# When set to false, the file is available only in staging. Default is false.
production: true

deployment-url: https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-sap-9aa6135e-75d5-467e-9f4a-ac2a21c069b8-global

docs: https://cloud.ibm.com/docs/sap-powervs

image_source: https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/blob/main/reference-architectures/sap-ready-to-go/deploy-arch-ibm-pvs-sap-ready-to-go.svg

related_links:
  - title: 'SAP in IBM Cloud documentation'
    url: 'https://cloud.ibm.com/docs/sap'
    description: 'SAP in IBM Cloud documentation.'
  - title: 'Reference architecture for "Power Virtual Server with VPC landing zone" as full stack deployment'
    url: 'https://cloud.ibm.com/docs/deployable-reference-architectures?topic=deployable-reference-architectures-deploy-arch-ibm-pvs-inf-full-stack'
    description: 'Reference architecture for "Power Virtual Server with VPC landing zone" as full stack deployment'
  - title: 'Reference architecture for "Power Virtual Server with VPC landing zone" as extension of existing deployment'
    url: 'https://cloud.ibm.com/docs/deployable-reference-architectures?topic=deployable-reference-architectures-deploy-arch-ibm-pvs-inf-extension'
    description: 'Reference architecture for "Power Virtual Server with VPC landing zone" as extension of existing deployment'

use-case: ITServiceManagement

industry: Technology

compliance: SAPCertified

content-type: reference-architecture

---

{{site.data.keyword.attribute-definition-list}}

# Power Virtual Server for SAP HANA - variation 'SAP ready PowerVS'
{: #deploy-arch-ibm-pvs-sap-ready-to-go}
{: toc-content-type="reference-architecture"}
{: toc-industry="Technology"}
{: toc-use-case="ITServiceManagement"}
{: toc-compliance="SAPCertified"}
{: toc-version="1.0.0"}

The SAP ready PowerVS variation of the Power Virtual Server for SAP HANA creates a basic and expandable SAP system landscape. The variation builds on the foundation of the VPC landing zone and Power Virtual Server with VPC landing zone. PowerVS instances for SAP HANA, SAP NetWeaver, and optionally for shared SAP files are deployed and preconfigured for SAP installation.

Services such as DNS, NTP and NFS running in VPC and provided by Power Virtual Server with VPC landing zone are leveraged.

Redundant IBM Cloud® connections provide the network bridge between the IBM Power infrastructure and the IBM Cloud® VPC and public internet.

The resulting SAP landscape leverages the services such as Activity Tracker, Cloud Object Storage, Key Management from the VPC landing zone and the network connectivity configuration provided by Power Virtual Server with VPC landing zone.

## Architecture diagram
{: #architecture-diagram}

![Architecture diagram for 'SAP on Power Virtual Server for SAP HANA' - variation 'SAP ready PowerVS'.](deploy-arch-ibm-pvs-sap-ready-to-go.svg "Architecture diagram"){: caption="Figure 1. PowerVS instances prepared to run SAP in PowerVS workspace" caption-side="bottom"}{: external download="deploy-arch-ibm-pvs-sap-ready-to-go.svg"}

## Design requirements
{: #design-requirements}

![Design requirements for 'Power Virtual Server for SAP HANA' - variation 'SAP ready PowerVS'.](heat-map-deploy-arch-ibm-pvs-sap-ready-to-go.svg "Design requirements"){: caption="Figure 2. Scope of the solution requirements" caption-side="bottom"}

IBM Cloud Power Virtual Servers (PowerVS) is a public cloud offering that lets an enterprise establish its own private IBM Power computing environment on shared public cloud infrastructure. Because of scalability and resiliency, PowerVS is the premium platform for SAP workloads in the cloud world. The reference architecture for 'Power Virtual Server for SAP HANA' - variation 'SAP ready PowerVS' is designed to provide PowerVS Linux instances prepared and configured for SAP HANA and SAP NetWeaver workloads according to the best practices and requirements using IBM Cloud® deployable architectures framework.

## Components
{: #components}

### PowerVS networks for SAP - architecture decisions
{: #vpc-components}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|* Provide reliable network for communication between SAP HANA and SAP NetWeaver instances  \n * Ensure that SAP network meet SAP requirements related to throughput and latency|SAP network|Create a separate SAP network for each SAP system. Tune SAP network in operating system according to SAP on Power best practices.|For very large SAP systems more than one SAP network may be needed. | Additional networks might be created manually and attached to the SAP system.|
|* Provide network for SAP system backups  \n * Ensure that backup network provides enough throughput| Backup network | Attach backup network that was created with the PowerVS workspace in 'Power infrastructure for deployable architecture'|For large landscapes with several SAP systems more than one backup network may be needed. | Additional networks might be created manually and attached to the SAP system.|
| Provide network for SAP system management | Management network | Attach management network that was created with the PowerVS workspace in 'Power infrastructure for deployable architecture'| |
{: caption="Table 1. PowerVS networks for SAP - architecture decisions" caption-side="bottom"}

### PowerVS instances for SAP - architecture decisions
{: #pvs-components}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|* Deploy PowerVS instance for SAP HANA workload  \n * Use SAP certified configurations regarding CPU and memory combinations (t-shirt sizes)  \n * Prepare operating system for SAP HANA workload | PowerVS instance | * Allow customer to specify certified SAP configuration and calculate all additional parameters automatically  \n * Attach all required storage filesystems based on PowerVS instance memory size  \n * Attach networks for management, backup and for SAP system internal communication  \n * Connect instance with infrastructure management services like DNS, NTP, NFS  \n * Perform OS configuration for SAP HANA| Allow customer to specify additional parameters, like non-standard file system sizes |
|* Deploy PowerVS instances for SAP NetWeaver workload  \n * Prepare operating system for SAP NetWeaver workload | PowerVS instance | * Allow customer to specify number of instances that must be deployed and CPU and memory for every instance  \n * Attach all required storage filesystems  \n * Attach networks for management, backup and for SAP system internal communication  \n * Connect instance with infrastructure management services like DNS, NTP, NFS  \n * Perform OS configuration for SAP NetWeaver | Allow customer to specify additional parameters, like non-standard file system sizes |
|* Deploy PowerVS instance for hosting shared SAP system files  \n * Prepare operating system | PowerVS instance | Host shared SAP system files on one of PowerVS instances for SAP NetWeaver and do not deploy a separate PowerVS instance | * Allow customer to deploy PowerVS instance with specified CPU and memory  \n * Attach specified storage filesystems  \n * Attach networks for management, backup and for SAP system internal communication  \n * Connect instance with infrastructure management services like DNS, NTP, NFS  \n * Perform OS configuration  \n * Allow customer to specify additional parameters, like non-standard file system sizes |
{: caption="Table 2. PowerVS workspace architecture decisions" caption-side="bottom"}

### Key and password management architecture decisions
{: #full-key-pw}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
|* Use public/private SSH key to access virtual server instances by using SSH  \n * Use SSH proxy to log in to all virtual server instances by using the bastion host  \n * Do not store private SSH keys on any virtual instances or on the bastion host  \n * Do not allow any other SSH login methods except the one with specified private and public SSH key pairs|Public SSH key - provided by customer. Private SSH key - provided by customer.|Ask customer to specify the keys. Accept the input as secure parameter or as reference to the key stored in IBM Cloud Secure Storage Manager. Do not print SSH keys in any log files. Do not persist private SSH key.|                    |
{: caption="Table 3. Key and passwords management architecture decisions" caption-side="bottom"}

## Compliance
{: #compliance}

This deployable architecture is certified for SAP deployments.

## Next steps
{: #next-steps}

Install the SAP system.
