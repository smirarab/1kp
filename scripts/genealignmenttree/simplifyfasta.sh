#!/bin/bash

sed -e "s/>\(.*\)/@>\1@/g" $1|tr -d "\n"|tr "@" "\n"|tail -n+2
