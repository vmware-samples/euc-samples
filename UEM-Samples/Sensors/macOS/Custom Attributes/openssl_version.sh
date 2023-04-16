#!/bin/bash

ssl_version=$(openssl version | awk '{print $2}')

echo $ssl_version