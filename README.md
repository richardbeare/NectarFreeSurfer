NectarFreeSurfer
================

Scripts to run freesurfer jobs on a SGE grid created by the cloudman
software on the AARNET Nectar cloud service.


Instructions for new cloudman
=============================

cloudman/galaxy is moving away from rabbit-mq and sge. This is my first attempt
to get a system running:

some instructions at:

https://wiki.galaxyproject.org/CloudMan/Building

0) Set up a host to run installation from. Target is builder

apt-get install ansible git emacs python-boto swift euca2ools

1) Fire up a trusty image - with 

no_start: true

pasted into user_data on dashboard. May need to write a python start if
this doesn't work.

boto_builder.py .

2) Log into the new instance

sudo apt-get update
sudo apt-get -y install git  python-pycurl

add the instance name to /etc/hosts to avoid errors

On another machine - e.g. local
Make sure ansible is installed - apt-get install ansible

git clone https://github.com/galaxyproject/cloudman-image-playbook.git

cd cloudman-image-playbook

export IP=115.146.94.148

export KEY=${HOME}/Nectar/rjb-nectar.pem

export PASSWD=

(
cd cloudman-image-playbook;
## Note need to change one of the ssh users to ubuntu.
sed -e "s#<instance_ip>#${IP}#" -e "s#<path_to_your_private_ssh_key>#${KEY}#" inventory/cloud-builder.sample > inventory/cloud-builder

ansible-playbook -vv -i inventory/cloud-builder cloud.yml --tags "cloudman" --extra-vars vnc_password=${PASSWD} --extra-vars cm_cleanup=true

)
