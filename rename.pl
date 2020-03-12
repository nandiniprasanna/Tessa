#!/usr/bin/perl
### Start of file
#rename L1_SGL01256-SI-GA-G9-4_HY2NTCCXY_L8_1.fq.gz to format needed by cellranger:

#[Sample Name]_S1_L00[Lane Number]_[Read Type]_001.fastq.gz

#usage:



#perl rename_tessa.pl Singapore-NUS-10premadeLib-lane-WOBI-A1186/raw_data/ renamed_data > cp.cmd

#perl rename_tessa.pl Singapore-NUS-10premadelibrary-lane-WOBI-A1066/raw_data/ renamed_data >>cp.cmd

#sh cp.cmd &



use File::Basename;



my $dir = $ARGV[0];

my $outdir = $ARGV[1];

my @dir = `ls -d $dir/*/`;

#foreach (@dir) {
#  print "$_\n";
#}

foreach my $d(@dir){

                chomp($d);

                my @a = `ls $d*.fq.gz`;

                #system("mkdir -p $outdir/$d");

                #system("mkdir -p $outdir/$d");
                my $basedir = basename($d);

               # print "$basedir";
                system("mkdir -m a=rwx -p $outdir/$basedir");

                foreach my $a(@a){

                        chomp($a);

                                my $name = basename($a);

                                if($name=~/(\S+)_L(\d+)_([1|2])/){

                                                print ("cp $a $outdir/$basedir/$1"."_S1_L00$2_R$3_001.fastq.gz\n");

                                }

                                else {

                                                print STDERR "Error trying to parse file name $d\n";

                                }

                }

}



### End of File
