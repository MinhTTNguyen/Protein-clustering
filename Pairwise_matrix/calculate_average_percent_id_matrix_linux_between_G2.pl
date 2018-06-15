=pod
December 20th 2013
This script is to calculate average percentages of identities of different subfamilies from a MSA profile or an unaligned FASTA file
=cut

#! /usr/perl/bin -w
use strict;
use Bio::Tools::Run::Alignment::Clustalw;
use Bio::Seq;
use Bio::SeqIO;
use Bio::SimpleAlign;
#use Getopt::Long;

mkdir "G2" || die "Unable to create directory <$!>\n";
chmod 0777, "G2";

#print "\nInput FASTA file containing the MSA profile or unaligned sequences:";
#my $filein=<STDIN>;
#chomp($filein);

#my $filein="";
#my $fileout="";
#GetOptions('in=s'=>\$filein, 'out=s'=>\$fileout);

my $filein="/home/mnguyen/Research/Lysozyme/GH25_all_15Dec2017/Fungi/12June2018/temp_matrix_between_clusters/G2.fasta";
my $fileout="/home/mnguyen/Research/Lysozyme/GH25_all_15Dec2017/Fungi/12June2018/temp_matrix_between_clusters/G2_matrix.txt";


######################################################################################
# read information from the input file
open(In,"<$filein") || die "Cannot open file $filein";
open(Out,">$fileout") || die "Cannot open file $fileout";
my $seq="";
my $id="";
my %hash_id_seq;
my %hash_sub_id;
print "\nReading FASTA file...";
while (<In>)
{
	$_=~s/^\s*//;$_=~s/\s*$//;
	if ($_=~/^\>/)
	{
		if ($seq)
		{
			$seq=uc($seq);
			$seq=~s/\-//g; # in case the fasta input file is a MSA profile
			$hash_id_seq{$id}=$seq;
			$id="";
			$seq="";
		}
		$id=$_;
		$id=~s/^\>//;
		if ($id=~/^(sub\d+)\|/)#>sub1|Cluster0062369_1_543
		{
			my $sub=$1;
			if ($hash_sub_id{$sub}){$hash_sub_id{$sub}=$hash_sub_id{$sub}."\t".$id;}
			else{$hash_sub_id{$sub}=$id;}
		}else{print "\nError (line __LINE__): ID line is not as described!\n$id\n";exit;}
	}else{$_=~s/\s*//g;$seq=$seq.$_;}
}
$seq=uc($seq);
$seq=~s/\-//g;
$hash_id_seq{$id}=$seq;
print "done!\n";
######################################################################################


#######################################################################################
# Calculate average percent identity of 2 subfamilies
my %hash_pairsub_id;
my @subs=keys(%hash_sub_id);
#foreach my $x (@subs){print "\n$x\n";}exit;
foreach my $sub1 (@subs)
{
	foreach my $sub2 (@subs)
	{
		if ($sub1 ne $sub2)
		{
			my $pair_sub=$sub1."_".$sub2;
			my $reverse_pair_sub=$sub2."_".$sub1;
			if ($hash_pairsub_id{$reverse_pair_sub})
			{
				$hash_pairsub_id{$pair_sub}=$hash_pairsub_id{$reverse_pair_sub};
			}else
			{
				my $average_percent_id=&Percent_identity_2_subs($sub1,$sub2);
				$hash_pairsub_id{$pair_sub}=$average_percent_id;
			}
		}
	}
}
#######################################################################################


#######################################################################################
# print out the matrix
@subs=sort(@subs);
foreach my $sub1 (@subs)
{
	print Out "\t$sub1";
}
print Out "\n";

foreach my $sub1 (@subs)
{
	print Out "$sub1";
	foreach my $sub2 (@subs)
	{
		my $pair_sub=$sub1."_".$sub2;
		my $identity=$hash_pairsub_id{$pair_sub};
		print Out "\t$identity";
	}
	print Out "\n";
}

close(In);
close(Out);
rmdir "G2";
#######################################################################################



######################################################################################
sub Percent_identity_2_subs
{
	my %hash_pairwise_calculation;
	my $subfamily_1=$_[0];
	my $subfamily_2=$_[1];
	
	my $first_sub_ids=$hash_sub_id{$subfamily_1};
	my @first_sub_seq_ids=split(/\t/,$first_sub_ids);
	
	my $second_sub_ids=$hash_sub_id{$subfamily_2};
	my @second_sub_seq_ids=split(/\t/,$second_sub_ids);
	
	my $total_percent_id=0;
	my $total_pairs=0;
	
	foreach my $id_sub1 (@first_sub_seq_ids)
	{
		foreach my $id_sub2 (@second_sub_seq_ids)
		{
			if ($id_sub1 ne $id_sub2)
			{
				my $seq1=$hash_id_seq{$id_sub1};
				my $seq2=$hash_id_seq{$id_sub2};
				my $key=$id_sub2."_".$id_sub1;
				unless ($hash_pairwise_calculation{$key})
				{
					my $pairwise_id=&Pairwise_id($seq1, $seq2);
					$total_percent_id=$total_percent_id+$pairwise_id;
					$total_pairs++;
					$hash_pairwise_calculation{$key}++;
				}
			}
		}
	}
	
	my $average_pairwise_subs=$total_percent_id/$total_pairs;
	return($average_pairwise_subs);
}
######################################################################################


######################################################################################
sub Pairwise_id
{
	my $sequence_1=$_[0];
	my $sequence_2=$_[1];
	
	############################################################
	# Performing pairwise alignment using BioPerl
	
	my $seq_obj1 = Bio::Seq -> new(-seq=>$sequence_1, -display_id => "first_seq");
	my $seq_obj2 = Bio::Seq -> new(-seq=>$sequence_2, -display_id => "second_seq");
	my $seqIO_obj = Bio::SeqIO -> new(-file => ">G2\/G2.fasta", -format => 'fasta');
	$seqIO_obj->write_seq($seq_obj1);
	$seqIO_obj->write_seq($seq_obj2);

	my @params = ('matrix' => 'BLOSUM', 'type' => 'protein', 'outfile' => "G2\/MSA_G2.fasta", 'output' => 'fasta');
	my $factory = Bio::Tools::Run::Alignment::Clustalw->new(@params);
	my $simple_aln_obj = $factory-> align("G2\/G2.fasta", -format => 'fasta');
	my $pairwise_percent_identity=$simple_aln_obj->overall_percentage_identity;

	unlink("G2/MSA_G2.fasta");
	unlink("G2/G2.fasta");
	return($pairwise_percent_identity);
}
######################################################################################