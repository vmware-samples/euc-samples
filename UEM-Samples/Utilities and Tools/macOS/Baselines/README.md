# macOS Baselines

## Overview

- **Authors**: Matt Zaske
- **Email**: mzaske@vmware.com
- **Date Created**: 6/16/2022
- **Supported Platforms**: Workspace ONE UEM v2203
- **Tested on macOS Versions**: macOS Monterey

## Purpose

Utilizing the macOS Security Compliance Project (mSCP) to enforce baselines on macOS devices using Workspace ONE. We will review briefly how to use the mSCP to generate the baseline you are wanting to configure and then go into detail on how to deploy this configuration using Workspace ONE. We will review two different deployment options as well for environments that are Freestyle enabled and those that are not. Here is a high level overview:

1) [Prerequisites for mSCP](#prerequisites-for-mSCP)
2) Generating a Baseline
3) Generating Guidance (profiles and scripts)
4) Deploying via Workspace ONE with Freestyle Orchestrator
5) Deploying via Workspace ONE without Freestyle Orchestrator

## Prerequisites for mSCP

The first few sections are primarily going to follow along with the [mSCP wiki](https://github.com/usnistgov/macos_security/wiki) and how I go about utilizing the project to generate a baseline for CIS Level 1 in my example. First, we need to clone or download the project and necessary modules:
1) Using Terminal on your Mac, run the following commands:
  - 'git clone https://github.com/usnistgov/macos_security.git

cd macos_security

pip3 install -r requirements.txt --user

bundle install'
2) This will drop all the project files locally on your Mac in a new directory called 'macos_security'

## Generating a Baseline