#!/bin/bash
#read the csv file
input="$1"
input1="sample3.csv"
# converting csv to linuxformat
dos2unix $input
#ignoring the heading and storing to another file
exec < $input || exit 1
awk 'NR>1' $input > $input1
#while IFS=',' read -r id transcriptome fastqs sample gcsbucket <&3;

#function ctls(){
  #if test $# -eq 3; then
  #  csvtool drop $2 $1 | csvtool take $3 -
  #else
  #  echo ctls: csvtool list specified record
  #  echo Synopsis: ctls '<filename> <startNo> <count>'
 # fi
#}
#echo $input
#ctls Cellrangercount1.csv 3 1

#reading the values from csv
inputLength=`csvtool height $input1`
for ((i=0; i<$inputLength ;i++))
do
csvtool drop $i $input1 | csvtool take 1 - > output.csv
expid=`csvtool format '%(1)\n' output.csv`
id=`csvtool format '%(2)\n' output.csv`
sample=`csvtool format '%(3)\n' output.csv`
gcsbucket=`csvtool format '%(4)\n' output.csv`
referencedatabucket=`csvtool format '%(5)\n' output.csv`
transcriptomebase=`basename $referencedatabucket`
transcriptome="/mounttest/$transcriptomebase"
fastqsbase=`basename $gcsbucket`
fastqs="/mounttest/$fastqsbase"
#parse the sample value, remove double qoutes
sample1=`echo $sample | sed 's/"//g'`
#csvtool format '%(4)\n' output.csv
echo expid = $expid
echo id = $id
echo transcriptome = $transcriptome
echo fastqs = $fastqs
echo sample = $sample
echo sample1 = $sample1
echo gcsbucket = $gcsbucket
echo referencedatabucket = $referencedatabucket
size1=`gsutil du -s $gcsbucket`
echo $size1
#calculating the size for the k8-pvc
sizespilt="$(cut -d ' ' -f1 <<<"$size1")"
sizemul=`expr $sizespilt \* 4`
PVCSIZE=`expr $sizemul / 1073741824`
echo $PVCSIZE
#Checking for id in expid sql table
count=`mysql -hseurat-test -P3306 -ujenkinsuser -pjenkins123 -D tessa_output -B -N -e "Select count(Sample_ID) from $expid where Sample_ID='$id'";`
if [ $count -eq 1 ]
then
java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build  Cellranger-pipeline -p size=$PVCSIZE -p Experiment_ID=$expid -p id=$id -p transcriptome=$transcriptome -p sample=$sample1 -p fastqs=$fastqs -p gcsbucket=$gcsbucket -p referencedatabucket=$referencedatabucket
else
echo "Invalid ID for the corresponding Experiment"; 
fi
done
rm output.csv
rm $input1
