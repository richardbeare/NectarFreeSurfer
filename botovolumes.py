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
ii=connection.get_all_volumes()
for K in ii:
    print K


