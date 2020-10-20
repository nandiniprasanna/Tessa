#!/bin/bash
BUILDID="$1"
EXPID="$7"
JENKINSJOBID="$2"
ID="$3"
TRANSCRIPTOME="$4"
FASTQS="$6"

#to obtain the values of sample when not provided in csv
#cd $FASTQS
#SAMPLE=`find . -type f -iname "*.fastq.gz" -exec basename "{}" \; | cut -d'_' -f 1-3 | sort -u | tr "\n" "," | sed 's/,$/ /' | tr " " "\n"`

SAMPLE="$5"
id="$ID"_"$BUILDID";
jenkinsjobid_buildid="$JENKINSJOBID"-"$BUILDID"
Outputgcsbucket="gs://testinggenomic/Cellranger_output"
podname=`hostname`;
var1=`echo "$EXPID" | awk '{print tolower($0)}'`;
expidlower=`echo "$var1" | tr '_' '-'`;
var2=`echo "$ID" | awk '{print tolower($0)}'`;
idlower=`echo "$var2" | tr '_' '-'`;
k8jobname="$expidlower"-"$idlower"-cellranger-"$BUILDID";

#i=1;
#if [ $i -eq 2 ]
#if ([cellranger count --id=$id --transcriptome=$TRANSCRIPTOME --sample=$SAMPLE --fastqs=$FASTQS] && [ls] && [gsutil cp -r $id gs://testinggenomic/Cellranger_output]);
if cellranger count --id=$id --transcriptome=$TRANSCRIPTOME --sample=$SAMPLE --fastqs=$FASTQS && ls && gsutil cp -r $id gs://testinggenomic/Cellranger_output ;
#if cellranger testrun --id=tiny ;
then
echo "Success"
df -h
mysql -h10.60.2.8 -P3306 -ujenkinsuser -ppoLKiuJH764 -D tessa_output -e "INSERT INTO cellranger_new_output_details(ExperimentID,SampleID,Sample_ID_BuildID,jenkinsjobid_buildid,k8jobname,podname,Outputgcsbucket,Cellranger_status,ApprovalStatus) 
VALUES ('$EXPID','$ID','$id','$jenkinsjobid_buildid','$k8jobname','$podname','$Outputgcsbucket/$id','Success','Denied')"
java -jar /jenkins-cli.jar -s http://10.60.2.24:8080/ -auth k8user:ASqwDFer^@34 build Cellranger-success-notification -p jenkinsjobID=$JENKINSJOBID-$BUILDID -p k8jobID=$k8jobname -p outputgcsbucket=gs://testinggenomic/Cellranger_output/$id -p id=$id -p Experiment_ID=$EXPID -p Podname=$podname -p cellrangerparentbuildID=$BUILDID
else
echo "Failed"
df -h
mysql -h10.60.2.8 -P3306 -ujenkinsuser -ppoLKiuJH764 -D tessa_output -e "INSERT INTO cellranger_new_output_details(ExperimentID,SampleID,Sample_ID_BuildID,jenkinsjobid_buildid,k8jobname,podname,Outputgcsbucket,Cellranger_status,ApprovalStatus) 
VALUES ('$EXPID','$ID','$id','$jenkinsjobid_buildid','$k8jobname','$podname','NA','Failure','NA')"
java -jar /jenkins-cli.jar -s http://10.60.2.24:8080/ -auth k8user:ASqwDFer^@34 build Cellranger-failure-notification -p jenkinsjobID=$JENKINSJOBID-$BUILDID -p k8jobID=$k8jobname -p id=$id -p Experiment_ID=$EXPID -p Podname=$podname -p cellrangerparentbuildID=$BUILDID
fi

ls $TRANSCRIPTOME;
ls /mounttest/reference;
