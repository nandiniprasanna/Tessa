#!/bin/bash
#set -u
Unscannedfolder="$1"
checkfileformat()
{
SEARCH_FOLDER="$1"
OUTDIR=$SEARCH_FOLDER"_renamed_data"
#echo $SEARCH_FOLDER
var=$(find $SEARCH_FOLDER  -type f -name '*.fastq.gz' | wc -l)
#echo $var
if [ 0 -eq $var ]
then
var2=$(find $SEARCH_FOLDER  -type f -name '*.fq.gz' | wc -l)
#echo $var2
if [ 0 -lt $var2 ]
then
echo "Files are in format fg.gz. Calling perl script to rename the files"
#rename all files and move to renamed_data
#OUTDIR=$SEARCH_FOLDER"_renamed_data"
#echo $OUTDIR
perl "$WORKSPACE/rename.pl" $SEARCH_FOLDER $OUTDIR > cp.cmd
sh cp.cmd
#recursive function
checkfileformat $OUTDIR
else
echo "Files are not in format fastq.gz format or not in fq.gz format to convert to fastq.gz."
fi
#echo "Call perl script"
#var3=$(find $SEARCH_FOLDER  -type f -name '*.fastq.gz' | wc -l)
elif [ 0 -lt $var ]
then
echo "Files are in .fastq.gz format......Copying $SEARCH_FOLDER to GCS bucket."
cp $SEARCH_FOLDER gs://testinggenomic/Cellranger_Input
echo "This completes scanning the input data with Antivirus,Verifying checksums and Renaming the files from fq.gz to fastq.gz."
fi
}

function checkmd5
{
arg1=$1
cd $arg1
md5_all=$(find $arg1 -name "md5_all.dat" -print)
echo $md5_all
if ! [ -z $md5_all ]
then
        file=()
        file=`awk -F ' ' '{print $2}' $md5_all`
        #echo $file
        cp $md5_all $md5_all.tmp
        for f in ${file[@]};do
                absolutepath=$(find .. -name "$f" -exec readlink -f {} \;)
                #echo $f
                #echo $absolutepath
                if ! [ -z $absolutepath ]
                then
                        sed -i "s|$f|$absolutepath|g" "$md5_all.tmp"
                fi
                #cat $md5_all
        done
        md5sum -c $md5_all.tmp > $WORKSPACE/checksumlogs.txt
        if grep -c "FAILED" checksumlogs.txt > 0 ;
        then
                echo "These files have failed in verifying checksum"
                grep -i "Failed" $WORKSPACE/checksumlogs.txt
        else
                echo "Checksum successfull.We shall now check for file format"
                checkfileformat $arg1
        fi
else
        echo "$md5_all is not present"
fi
rm -rf $md5_all.tmp
}

sudo clamscan -r --bell -i $Unscannedfolder  >> /var/log/clamav/scan_summary/scan_logs.txt
tail -n 9 /var/log/clamav/scan_summary/scan_logs.txt > $WORKSPACE/scan_logs.txt.tmp
if grep -q "Infected files: 0" "scan_logs.txt.tmp";
then
        echo "There are no infected files"
        #echo $dir $file $action
        basename=`basename $Unscannedfolder`
        directory=`basename $(dirname $Unscannedfolder)`
                 if [ -d "/home/scanned/$directory" ]
        then
                echo "Directory /home/scanned/$directory exists."
                 mv  $Unscannedfolder /home/scanned/$directory/$basename
 else
                echo "Directory /home/scanned/$directory does not exists. So creating /home/scanned/$directory "
                mkdir /home/scanned/$directory
                mv  $Unscannedfolder /home/scanned/$directory/$basename
        fi
        echo "Clam scan success and the input folder is moved to /home/scanned/$directory"
        checkmd5 /home/scanned/$directory/$basename
else
echo "Clam scan fail for input folder $Unscannedfolder "
fi
