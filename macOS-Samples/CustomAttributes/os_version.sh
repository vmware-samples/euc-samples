#!/bin/bash

osvers=$(/usr/bin/sw_vers | grep ProductVersion | cut -c 17-23)
echo $osvers
