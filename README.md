# EUC-samples (previously AirWatch-Samples)

## Table of Contents
- [Introduction](#introduction)
- [Submitting samples](#submitting-samples)
  - [Required Information](#required-information)
  - [Suggested Information](#suggested-information)
  - [Contribution Process](#contribution-process)
  - [Developer Certificate of Origin](#developer-certificate-of-origin)
  - [Code Style](#code-style)
- [Resource Maintenance](#resource-maintenance)
  - [Maintenance Ownership](#maintenance-ownership)
  - [Filing Issues](#filing-issues)
  - [Resolving Issues](#resolving-issues)
  - [VMware Sample Exchange](#vmware-sample-exchange)
- [VMware Resources](#vmware-resources)


## Introduction
Welcome to the **EUC-samples** repository.  This project is intended for the community and VMware to share commonly used code snippets that can aid VMWare Workspace ONE and Horizon administrators. 

Some examples of items to submit for consideration and use by the community:
* Custom XML Profile Payloads
* Script content for Custom Attributes
* Scripts to be leveraged via Products  (Bash/shell, Python, Powershell, Batch, etc)
* Scripts to assist with automation against the various VMware REST API's
* Markdown Documents describing suggested best practices or procedures that may be outside the realm of typical documentation


## Submitting samples

### Required Information
The following information must be included in the README.md or in the sample docstring in case README already exists in same folder.
* Author Name
  * This can include full name, email address or other identifiable piece of information that would allow interested parties to contact author with questions.
* Date
  * Date the sample was originally written
* Minimal/High Level Description
  * What does the sample do ?
* Any KNOWN limitations or dependencies

### Suggested Information
The following information should be included when possible. Inclusion of information provides valuable information to consumers of the resource.
* VMWare Product version against which the sample was developed/tested
* Client Operating System version against which the sample was developed/tested (e.g. Windows Build number, or macOS Version and Build Number)
* Language (Bash/Python/Powershell) version against which the sample was developed/tested

### Contribution Process

Follow the [GitHub process](https://help.github.com/articles/fork-a-repo)
* Please use one branch per sample or change-set
* Please use one commit and pull request per sample
* Please post the sample output along with the pull request
* If you include a license with your sample, use the project license

### Developer Certificate of Origin
The EUC-samples project team welcomes contributions from the community. Before you start working with EUC-samples, please read our [Developer Certificate of Origin](https://cla.vmware.com/dco). All contributions to this repository must be signed as described on that page. Your signature certifies that you wrote the patch or have the right to pass it on as an open-source patch.

### Code Style

We won't actively enforce any "official" style guides, but do ask that you do what you can to:
* Make your samples easily readable
* Make your samples easily reusable
* Include in-line comments to help with readability

## Resource Maintenance

### Maintenance Ownership
Maintenance of any and all submitted samples is to be performed by the community.  If you can make a sample better, please feel free to submit a pull request to improve it!

### Filing Issues
Any bugs or other issues should be filed within GitHub by way of the repository’s Issue Tracker.

### Resolving Issues
Any community member can resolve issues within the repository, however only the board member can approve the update. Once approved, assuming the resolution involves a pull request, only a board member will be able to merge and close the request.

### VMware Sample Exchange
It is highly recommended to add any and all submitted samples to the VMware Sample Exchange:  <https://code.vmware.com/samples>

Sample Exchange can be allowed to access your GitHub resources, by way of a linking process, where they can be indexed and searched by the community. There are VMware social media accounts which will advertise resources posted to the site and there's no additional accounts needed, as the VMware Sample Exchange uses MyVMware credentials.

### Windows Users
Some of the samples result in a long file path that may cause cloning to fail on Windows machines. If you an error message is displayed during cloning indicating that the file name is too long then run the below command to allow longer file names during checkout.
* ```git config --system core.longpaths true```
* [Additional Information](https://confluence.atlassian.com/bamkb/git-checkouts-fail-on-windows-with-filename-too-long-error-unable-to-create-file-errors-867363792.html)


## VMware Resources
* [VMware Code](https://code.vmware.com/home)
* [VMware Tech Zone](https://techzone.vmware.com)
* [VMware Developer Community](https://communities.vmware.com/community/vmtn/developer)
* [VMware End-User Computing Blog](https://blogs.vmware.com/euc)

