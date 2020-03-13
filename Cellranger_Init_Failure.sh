#!/bin/bash
BUILDID="$1"
JENKINSJOBID="$2"
ID="$3"
id="$ID"_"$BUILDID";
jenkinsjobid_buildid="$JENKINSJOBID"-"$BUILDID"
EXPID="$4"
podname=`hostname`;
var1=`echo "$EXPID" | awk '{print tolower($0)}'`;
expidlower=`echo "$var1" | tr '_' '-'`;
var2=`echo "$ID" | awk '{print tolower($0)}'`;
idlower=`echo "$var2" | tr '_' '-'`;
k8jobname="$expidlower"-"$idlower"-cellranger-"$BUILDID";
CELLRANGERGCSBUCKET="$5"
REFERENCEDATABUCKET="$6"


if gsutil cp -r $CELLRANGERGCSBUCKET /mounttest/ && gsutil cp -r $REFERENCEDATABUCKET /mounttest/ && ls
then
echo "Init container successfull"
else
java -jar /jenkins-cli.jar -s http://10.60.2.24:8080/ -auth admin:admin build Cellranger_init_failure_notification -p jenkinsjobID=$jenkinsjobid_buildid -p k8jobID=$k8jobname -p id=$id -p Experiment_ID=$EXPID -p Podname=$podname
fi
