# Extract sequences from all subfamilies
#! /usr/bin/perl -w
use strict;

my $filein="/home/mnguyen/Research/Lysozyme/Fungi_GH23_24_25/filtered_intron150/Final_clusters/GH24/GH24_Erin_newsub/GH24sub1_subgroups.fasta";
my $folderout="/home/mnguyen/Research/Lysozyme/Fungi_GH23_24_25/filtered_intron150/Final_clusters/GH24/GH24_Erin_newsub/GH24sub1_subgroups";
mkdir $folderout;

open(In, "<$filein") || die "Cannot open file $filein";
my $id="";
my $seq="";
while (<In>)
{
	$_=~s/^\s*//;$_=~s/\s*$//;
	if ($_=~/^\>/)
	{
		if ($seq)
		{
			if ($id=~/^\>(sub\d+)\|/)
			{
				my $subfamily=$1;
				my $fileout=$subfamily.".fasta";
				open(Out, ">>$folderout/$fileout") || die "Cannot open file $fileout";
				print Out "$id\n$seq\n";
				close(Out);
			}else{print "\nError (line ".__LINE__."): cannot find subfamily information for this sequence: $id\n";exit;}
			$seq="";$id="";
		}
		$id=$_;
	}else{$_=~s/\s*//g;$seq=$seq.$_;}
}
if ($id=~/^\>(sub\d+)\|/)
{
	my $subfamily=$1;
	my $fileout=$subfamily.".fasta";
	open(Out, ">>$folderout/$fileout") || die "Cannot open file $fileout";
	print Out "$id\n$seq\n";
	close(Out);
}else{print "\nError (line ".__LINE__."): cannot find subfamily information for this sequence: $id\n";exit;}

close(In);
