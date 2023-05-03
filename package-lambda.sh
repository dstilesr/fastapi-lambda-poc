#!/bin/bash

###########################################################
# Make Zip archive of lambda function for upload
###########################################################
rm -f lambda-src.zip
cp -R src lambda-src
pip install -r requirements.txt --target lambda-src --no-cache-dir

zip lambda-src.zip -r lambda-src \
    && rm -r lambda-src