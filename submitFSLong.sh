#!/bin/bash

## this version if the object store contains
## archives of FS folders
LOGGING=/mnt/transient_nfs/ubuntu/Logging/
# any new binaries/scripts should be installed in here
SCRIPTS=/mnt/transient_nfs/ubuntu/Scripts/

#DTP1=Tascog1FreesurferOutput
#DTP2=Tascog2FreesurferOutput
#DTP3=Tascog3FreesurferOutput

DTP1=CDOT1FreesurferOutput
DTP2=CDOT2FreesurferOutput
DTP3=CDOT3FreesurferOutput

#Dest=TascogLongFreesurferOutput
Dest=CDOTLongFreesurferOutput

LOCALSTORE=/mnt/Data/

#FREESURFER=/usr/local/freesurfer/5.3/
FREESURFER=${LOCALSTORE}/freesurfer/5.3/

TMPFILE=$(mktemp) || exit 1
trap 'rm -f $TMPFILE; exit 0' 0 1 2 3 14 15

function doSubmit()
{
bb=$(basename $1)
SID=${bb}

tname=${SID}.tgz

jobname=$SID

## set up the download commands
SW1="swift download $DTP1 -o ${1}_tp1 $tname"
SW2="swift download $DTP2 -o ${1}_tp2 $tname"


SW3=""
if [ ! -z $3 ] ; then
    SW3="swift download $DTP3 -o ${1}_tp3 $tname"
fi

TP1=${SID}_tp1
TP2=${SID}_tp2

TP3=${SID}_tp3

TEMPLATENAME=${TP1/_tp1/_template}

TPL1=${TP1}.long.${TEMPLATENAME}
TPL2=${TP2}.long.${TEMPLATENAME}
TPL3=${TP3}.long.${TEMPLATENAME}

## build the FS commands here:

timepoints="-tp $TP1 -tp $TP2"

if [ ! -z $3 ] ; then
    timepoints="${timepoints} -tp $TP3"
else
    TP3=""
    TPL3=""
fi

COM1="recon-all -base-affine $TEMPLATENAME $timepoints  -all"
COM2="recon-all -long $TP1  $TEMPLATENAME -all"
COM3="recon-all -long $TP2  $TEMPLATENAME -all"
COM4=""
if [ ! -z $3 ] ; then
    COM4="recon-all -long $TP3  $TEMPLATENAME -all"
fi

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
$SW1
$SW2
$SW3

cd \${SUBJECTS_DIR}
tar xzf /tmp/${1}_tp1
mv ${SID} ${SID}_tp1

tar xzf /tmp/${1}_tp2
mv ${SID} ${SID}_tp2

if [ -e /tmp/${SID}_tp3 ] ; then
   tar xzf /tmp/${1}_tp3
   mv ${SID} ${SID}_tp3
fi
/bin/rm /tmp/${SID}_*
)

$COM1
$COM2
$COM3
$COM4

# need to upload at this point.
(
cd \${SUBJECTS_DIR}
# tar the folder
tar czf ${SID}.tgz ${TP1} ${TP2} ${TP3} ${TPL1} ${TPL2} ${TPL3} ${TEMPLATENAME}
swift upload $DESTDIR ${SID}.tgz
/bin/rm -rf ${SID}.tgz ${TP1} ${TP2} ${TP3} ${TPL1} ${TPL2} ${TPL3} ${TEMPLATENAME}
)
EOF

qsub -N $jobname $TMPFILE
}

( 
while read tp1 tp2 tp3 ; do
    doSubmit $tp1 $tp2 $tp3
    

tp1=""
tp2=""
tp3=""
done
) < cdot_long.txt
#) < tascog_long.txt
