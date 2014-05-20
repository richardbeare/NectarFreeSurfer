#!/bin/bash

## this version if the object store contains
## archives of FS folders
LOGGING=/mnt/transient_nfs/ubuntu/Logging/
# any new binaries/scripts should be installed in here
SCRIPTS=/mnt/transient_nfs/ubuntu/Scripts/


LOCALSTORE=/mnt/Data/

#FREESURFER=/usr/local/freesurfer/5.3/
FREESURFER=${LOCALSTORE}/freesurfer/5.3/

TMPFILE=$(mktemp) || exit 1
trap 'rm -f $TMPFILE; exit 0' 0 1 2 3 14 15

function doSubmit()
{
HOST=$1
jobname=$HOST

## set up the download commands
SW1="swift download SoftwareBucket fs5.3.tgz"


cat >$TMPFILE<<EOF
#!/bin/bash
#\$ -S /bin/bash
#\$ -o $LOGGING/${jobname}.stdout
#\$ -e $LOGGING/${jobname}.stderr

source ${HOME}/Nectar/nicreds.sh
source ${HOME}/PyVirtEnv/bin/activate


(
cd $LOCALSTORE
du -sh freesurfer
)
EOF

qsub -N $jobname -q all.q@${HOST} $TMPFILE
}

for i in $(grep server /etc/hosts |grep -v $(hostname) | awk '{print $3}' ) ; do
doSubmit $i
done
