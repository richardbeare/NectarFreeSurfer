#!/bin/bash

LOGGING=/mnt/transient_nfs/ubuntu/Logging/
# any new binaries/scripts should be installed in here
SCRIPTS=/mnt/transient_nfs/ubuntu/Scripts/

OBJDIR=GridData

LOCALSTORE=/mnt/Data/

FREESURFER=/usr/local/freesurfer/5.1/

TMPFILE=$(mktemp) || exit 1
trap 'rm -f $TMPFILE; exit 0' 0 1 2 3 14 15

function doSubmit()
{

cat >$TMPFILE<<EOF
#!/bin/bash
#\$ -S /bin/bash
#\$ -o $LOGGING/${jobname}.stdout
#\$ -e $LOGGING/${jobname}.stderr

source ${HOME}/Nectar/nicreds.sh

source ${FREESURFER}/SetupFreeSurfer.sh

export SUBJECTS_DIR=${LOCALSTORE}/

(
cd \${SUBJECTS_DIR}
FILES=\$(swift list $OBJDIR | grep "^$1")
swift download $OBJDIR \$FILES
)

recon-all -subjid $1
EOF

}

for i in $(swift list -d / ${OBJDIR}) ; do
# strip trailing /
I=${i%%/}
doSubmit $I
done