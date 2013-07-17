#!/bin/bash

LOGGING=/mnt/transient_nfs/ubuntu/Logging/
# any new binaries/scripts should be installed in here
SCRIPTS=/mnt/transient_nfs/ubuntu/Scripts/

OBJDIR=GridData

LOCALSTORE=/mnt/Data/

FREESURFER=/mnt/transient_nfs/ubuntu/freesurfer/5.3/

TMPFILE=$(mktemp) || exit 1
trap 'rm -f $TMPFILE; exit 0' 0 1 2 3 14 15

function doSubmit()
{
SID=${1/.nii.gz/}
jobname=$SID
cat >$TMPFILE<<EOF
#!/bin/bash
#\$ -S /bin/bash
#\$ -o $LOGGING/${jobname}.stdout
#\$ -e $LOGGING/${jobname}.stderr

source ${HOME}/Nectar/nicreds.sh

source ${FREESURFER}/SetUpFreeSurfer.sh

export SUBJECTS_DIR=${LOCALSTORE}/

(
cd \${SUBJECTS_DIR}
swift download $OBJDIR $1
)

recon-all -subjid $SID -i ${SUBJECTS_DIR}/$1 -all

# need to upload at this point.
(
cd \${SUBJECTS_DIR}
# delete the original nifti file
/bin/rm $1
# tar the folder
tar czf ${SID}.tgz ${SID}
swift upload $OBJDIR ${SID}.tgz
)
EOF

qsub -N $jobname $TMPFILE
}

for i in $(swift list ${OBJDIR}) ; do
# strip trailing /
I=${i%%/}
doSubmit $I
done