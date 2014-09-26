#!/bin/bash

## this version if the object store contains
## archives of FS folders
LOGGING=/mnt/transient_nfs/ubuntu/Logging/
# any new binaries/scripts should be installed in here
SCRIPTS=/mnt/transient_nfs/ubuntu/Scripts/

OBJDIR=CDOT2FreesurferInput
DESTDIR=CDOT2FreesurferOutput

LOCALSTORE=/mnt/Data/

#FREESURFER=/usr/local/freesurfer/5.3/
FREESURFER=${LOCALSTORE}/freesurfer/5.3/

TMPFILE=$(mktemp) || exit 1
trap 'rm -f $TMPFILE; exit 0' 0 1 2 3 14 15

function doSubmit()
{
bb=$(basename $1)
SID=${bb/.tgz/}
jobname=fs2_$SID
cat >$TMPFILE<<EOF
#!/bin/bash
#\$ -S /bin/bash
#\$ -o $LOGGING/${jobname}.stdout
#\$ -e $LOGGING/${jobname}.stderr

source ${HOME}/Nectar/nicreds.sh

source ${FREESURFER}/SetUpFreeSurfer.sh
source ${HOME}/PyVirtEnv/bin/activate
export SUBJECTS_DIR=${LOCALSTORE}/

(
cd /tmp/
swift download $OBJDIR -o $bb $1

cd \${SUBJECTS_DIR}
tar xzf /tmp/$bb
/bin/rm /tmp/$bb
)

recon-all -subjid $SID -make all -no-isrunning
#recon-all -subjid $SID -no-isrunning -autorecon1 -autorecon2 -nofill -notessellate -nosmooth1 -noinflate1 -noqsphere -nofix -nowhite -nosmooth2 -noinflate2
# need to upload at this point.
(
cd \${SUBJECTS_DIR}
# tar the folder
tar czf ${SID}.tgz ${SID}
swift upload $DESTDIR ${SID}.tgz
/bin/rm -rf ${SID}.tgz ${SID}
)
EOF
qsub -N $jobname $TMPFILE
}

#qstat -r | grep Full | awk '{print $3}' > /tmp/donefs
. ${HOME}/Nectar/nicreds.sh

. ${HOME}/PyVirtEnv/bin/activate

for i in $(swift list ${OBJDIR}) ; do
#DONE=$(grep ${i/.tgz/} /tmp/donefs)
#if [ -z "${DONE}" ] ; then
# strip trailing /
I=${i%%/}
echo $I
doSubmit $I
#fi
done
