#!/bin/bash
echo "Reading file $1"
value=$(cat $1)
echo "$value"
echo "$value" > $2