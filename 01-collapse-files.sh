#!/usr/bin/env bash

# take data files with unique content and queue them to be processed. 

find "./data/" -type f -exec cksum {} + | awk '!ck[$1$2]++ { print $3 }' > "./artifacts/01-unique-files.txt"