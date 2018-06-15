#! /usr/perl/bin -w
use strict;

my $folderin="/home/mnguyen/Research/Lysozyme/GH25_all_15Dec2017/Fungi/12June2018/Clusters";
my $folderout="/home/mnguyen/Research/Lysozyme/GH25_all_15Dec2017/Fungi/12June2018/Clusters_ALN";
mkdir $folderout;

opendir(DIR,"$folderin") || die "Cannot open $folderin";
my @files=readdir(DIR);
foreach my $file (@files)
{
	if (($file ne ".") and ($file ne ".."))
	{
		my $cmd="perl run_pairwise_aln.pl --in $folderin/$file --out $folderout/$file --temp $file";
		system $cmd;
	}
}
closedir(DIR);