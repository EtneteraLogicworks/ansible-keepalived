#!/bin/bash

echo "${1} ${2} is in ${3} state" > "/var/run/keepalived.${1}.${2}.state"
