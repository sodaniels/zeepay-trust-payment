#!/bin/bash

# Read parameters.
FOLDER_NAME=$1

# Zip functions

function zip_folder() {
    echo -e "Run zip ${FOLDER_NAME}"
    # Create zip
    zip -r target/${FOLDER_NAME}.zip ${FOLDER_NAME}
}

# Program execution

# Remove previously created files.

rm -f target/${FOLDER_NAME}.zip
mkdir target
zip_folder
