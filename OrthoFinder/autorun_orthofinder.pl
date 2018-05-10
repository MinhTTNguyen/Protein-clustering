#! /usr/perl/bin -w
use strict;

my $filein_famy_list="families_of_interest_except_AA2.txt";
open(In,"<$filein_famy_list") || die "Cannot open file $filein_famy_list";
while (<In>)
{
	$_=~s/\s*//g;
	my $family=$_;
	my $cmd="OrthoFinder-2.2.1/orthofinder -M msa -f Without_characterized_seqs_each_species/$family";
	system $cmd;
}
close(In);