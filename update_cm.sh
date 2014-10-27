#!/bin/bash
# This script is a convenience script for updating Galaxy CloudMan (CM)
# on S3. It deletes the old tarball with CM's source and creates a new one.
# Then, by calling a python script, the newly created file is uploaded
# to S3 in the respective bucket.
#
# Usage: sh update_cm.sh [cloud]
# The single optinal argument indicates which cloud to use. Supported values
# are provided in the upload_cm_to_S3.py script. If no value is provided,
# AWS EC2 cloud is assumed.

cm_path=`pwd`
cm_filename="cm.tar.gz"
cm_bucket_name="cloudman-os"

REPLY="y" # default to auto update
if [ "$cm_bucket_name" == "cloudman" ]; then
    REPLY="n"
    read -p "This is going to the 'cloudman' bucket. Are you sure (y/n)?"
fi
if [ "$REPLY" == "y" ]; then
    echo ""
    echo "Uploading to bucket '$cm_bucket_name' to cloud '$1' at `date`"
    echo ""

    cd $cm_path
    if [ -f $cm_filename ]; then
        echo "Removing the old CM tarball $cm_filename"
        rm $cm_filename
    fi
    echo "Creating a new CM tarball $cm_path/$cm_filename"
    tar -czf $cm_filename --exclude "paster.log" --exclude "ec2autorun.py" \
                          --exclude "update_cm.sh" --exclude "upload_cm_to_S3.py" \
                          --exclude "userData.txt" --exclude "userData.yaml" \
                          --exclude "persistent-volumes-latest.txt" --exclude "snaps.yaml"\
                          --exclude "cm_boot.py" --exclude ".hgignore" --exclude ".hg" *
    python upload_cm_to_S3.py $cm_bucket_name $cm_filename $1
    python upload_cm_to_S3.py $cm_bucket_name cm_boot.py $1
    # python upload_cm_to_S3.py $cm_bucket_name snaps.yaml $1
fi
echo ""
echo "Update complete at `date`"
