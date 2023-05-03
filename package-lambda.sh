#!/bin/bash

###########################################################
# Make Zip archive of lambda function for upload
###########################################################
rm -f lambda-src.zip
cp -R src lambda-src
pip install -r requirements.txt --target lambda-src --no-cache-dir

cd lambda-src \
    && zip ../lambda-src.zip -r . \
    && rm -r lambda-src
