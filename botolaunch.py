#!/usr/bin/env python

import boto
import os

from boto.ec2.connection import EC2Connection
from boto.ec2.regioninfo import *

EC2_ACCESS_KEY=os.environ["EC2_ACCESS_KEY"]
EC2_SECRET_KEY=os.environ["EC2_SECRET_KEY"]

PASSWD=os.environ["PASSWD"]

region = RegionInfo(name="NeCTAR", endpoint="nova.rc.nectar.org.au")
connection = boto.connect_ec2(aws_access_key_id=EC2_ACCESS_KEY,
                              aws_secret_access_key=EC2_SECRET_KEY,
                              validate_certs=False,
                              is_secure=True,
                              region=region,
                              port=8773,
                              path="/services/Cloud")

# print image ids and names
#ii=connection.get_all_images()
#for K in ii:
#    print K, K.name

startup="""access_key: """ + EC2_ACCESS_KEY + """
cloud_name: NeCTAR
cluster_name: neurosge
freenxpass: """ + PASSWD + """
bucket_default: cloudman-dev
secret_key: """ + EC2_SECRET_KEY + """
instance_type: m1.small 
password: """ + PASSWD + """
s3_port: 8888
cloud_type: openstack
region_name: NeCTAR
region_endpoint: nova.rc.nectar.org.au
ec2_port: 8773
s3_host: swift.rc.nectar.org.au
is_secure: True
s3_conn_path: /
post_start_script_url: "https://swift.rc.nectar.org.au:8888/v1/AUTH_6c93c955fd1c489f9238ab50b9262d2a/CloudmanScripts/cloudman_headnode_config.sh"
worker_post_start_script_url: "https://swift.rc.nectar.org.au:8888/v1/AUTH_6c93c955fd1c489f9238ab50b9262d2a/CloudmanScripts/cloudman_worker_config.sh"
master_prestart_commands: 
  - "mkdir -p /mnt/transient_nfs/ubuntu/Logging"
  - "mkdir -p /mnt/transient_nfs/ubuntu/Scripts"
  - "chown ubuntu:ubuntu -R /mnt/transient_nfs/ubuntu"
ec2_conn_path: /services/Cloud"""

#instance = connection.run_instances('ami-00000198', min_count=count, max_count=count, security_groups=['ssh', 'sungrid'],key_name='rjb-nectar', user_data=startup, instance_type='m1.medium')

#instanceHN = connection.run_instances('ami-00000400', min_count=1, max_count=1, security_groups=['ssh', 'cloudman'],key_name='rjb-nectar', user_data=startup, instance_type='m1.small', placement="melbourne-np")

# This one for freesurfer
#instanceHN = connection.run_instances('ami-000005a7', min_count=1, max_count=1, security_groups=['ssh', 'CloudMan'],key_name='rjb-nectar', user_data=startup, instance_type='m1.small', placement="monash")

## New precise image
instanceHN = connection.run_instances('ami-00002f73', min_count=1, max_count=1, security_groups=['ssh', 'CloudMan'],key_name='rjb-nectar', user_data=startup, instance_type='m1.small', placement="monash")

# this one for R/bayesian networks
#instanceHN = connection.run_instances('ami-0000128e', min_count=1, max_count=1, security_groups=['ssh', 'CloudMan'],key_name='rjb-nectar', user_data=startup, instance_type='m1.medium', placement="monash")

