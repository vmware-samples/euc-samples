#!/bin/bash

ssh_version=$(/usr/bin/ssh -V 2>&1)

echo $ssh_version