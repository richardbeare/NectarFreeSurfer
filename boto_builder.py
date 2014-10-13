#!/usr/bin/env python

import boto
import os

from boto.ec2.connection import EC2Connection
from boto.ec2.regioninfo import *

EC2_ACCESS_KEY=os.environ["EC2_ACCESS_KEY"]
EC2_SECRET_KEY=os.environ["EC2_SECRET_KEY"]


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


startup="""no_start: true"""

#instance = connection.run_instances('ami-00000198', min_count=count, max_count=count, security_groups=['ssh', 'sungrid'],key_name='rjb-nectar', user_data=startup, instance_type='m1.medium')

#instanceHN = connection.run_instances('ami-00000400', min_count=1, max_count=1, security_groups=['ssh', 'cloudman'],key_name='rjb-nectar', user_data=startup, instance_type='m1.small', placement="melbourne-np")

# This one for freesurfer
#instanceHN = connection.run_instances('ami-000005a7', min_count=1, max_count=1, security_groups=['ssh', 'CloudMan'],key_name='rjb-nectar', user_data=startup, instance_type='m1.small', placement="monash")

## New precise image
instanceHN = connection.run_instances('ami-000022b3', min_count=1, max_count=1, security_groups=['ssh', 'CloudMan'],key_name='rjb-nectar', user_data=startup, instance_type='m1.small', placement="melbourne")

# this one for R/bayesian networks
#instanceHN = connection.run_instances('ami-0000128e', min_count=1, max_count=1, security_groups=['ssh', 'CloudMan'],key_name='rjb-nectar', user_data=startup, instance_type='m1.medium', placement="monash")

