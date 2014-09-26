#!/bin/bash

## this version if the object store contains
## archives of FS folders
LOGGING=/mnt/transient_nfs/ubuntu/Logging/
# any new binaries/scripts should be installed in here
SCRIPTS=/mnt/transient_nfs/ubuntu/Scripts/


LOCALSTORE=/mnt/Data/

TMPFILE=$(mktemp) || exit 1
trap 'rm -f $TMPFILE; exit 0' 0 1 2 3 14 15

function doSubmit()
{
HOST=$1
jobname=$HOST



cat >$TMPFILE<<EOF
#!/bin/bash
#\$ -S /bin/bash
#\$ -o $LOGGING/${jobname}.stdout
#\$ -e $LOGGING/${jobname}.stderr

if [ ! -e /etc/apt/sources.list.d/R.sources.list ] ; then
sudo cp /mnt/transient_nfs/ubuntu/NectarFreeSurfer/R.sources.list /etc/apt/sources.list.d/
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
sudo apt-get update
sudo apt-get -y install r-base-dev
sudo R --file=/mnt/transient_nfs/ubuntu/NectarFreeSurfer/install.R
fi
EOF

qsub -N $jobname -q all.q@${HOST} $TMPFILE
}

for i in $(grep server /etc/hosts |grep -v $(hostname) | awk '{print $3}' | tail ) ; do
#for i in $(cat missingfs ) ; do
doSubmit $i
done
