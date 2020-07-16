#!/bin/bash

./req.sh || exit 1

i=$(require ls hello firefox chrome)
echo "$i"

