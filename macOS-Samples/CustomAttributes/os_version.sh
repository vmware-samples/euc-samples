#!/bin/bash

osvers=$(/usr/bin/sw_vers | awk '/ProductVersion/{print $2}')
echo $osvers
