# March 13th 2018
# Read a fasta file and create a folder containing fasta files each of which contains sequences of the same species

#! /usr/perl/bin -w
use strict;

my $folderin="/home/mnguyen/Research/Lysozyme/GH25_all_15Dec2017/Fungi/12June2018/Temp";
my $folderout="/home/mnguyen/Research/Lysozyme/GH25_all_15Dec2017/Fungi/12June2018/Tempout";
mkdir $folderout;

opendir(DIR,$folderin) || die "Cannot open folder $folderin";
my @files=readdir(DIR);
foreach my $file (@files)
{
	if (($file ne ".") and ($file ne ".."))
	{
		my $folderout_family=substr($file,0,-6);
		mkdir "$folderout/$folderout_family";
		open(In,"<$folderin/$file") || die "Cannot open file $folderin/$file";
		my $id="";
		my $seq="";
		my $species="";
		while (<In>)
		{
			chomp($_);
			if ($_=~/^\>/)
			{
				if ($seq){print Out ">$id\n$seq\n";close(Out);$seq="";$id="";}
				$id=$_;
				$id=~s/^\>Fungi\|//;
				if ($id=~/^jgi/)
				{
					my @cols=split(/\|/,$id);
					$species=$cols[1];
				}
				#----------------------------------------------------------------------------#
				# This is for proteins downloaded from Broad
				#else
				#{
				#	if ($id=~/^ACLA\_/){$species="Aspcl";}
				#	elsif($id=~/^AFL2T\_/){$species="Aspfl";}
				#	elsif($id=~/^NFIA\_/){$species="Aspfi";}
				#	elsif($id=~/^ATET\_/){$species="Aspte";}
				#	elsif($id=~/^Afu/){$species="Aspfu";}
				#	else{$species="Aspor";}
				#}
				#----------------------------------------------------------------------------#
				
				#----------------------------------------------------------------------------#
				# This is for proteins downloaded from CSFG
				else
				{
					$species=$id;
					$species=~s/\_.+//;
				}
				#----------------------------------------------------------------------------#
				my $fileout=$species.".fasta";
				open(Out,">>$folderout/$folderout_family/$fileout") || die "Cannot open file $fileout";
			}else{$_=~s/\s*//g;$seq=$seq.$_;}
		}
		if ($id=~/^jgi/)
		{
			my @cols=split(/\|/,$id);
			$species=$cols[1];
		}
		
		#----------------------------------------------------------------------------#
		# This is for proteins downloaded from Broad
		#else
		#{
		#	if ($id=~/^ACLA\_/){$species="Aspcl";}
		#	elsif($id=~/^AFL2T\_/){$species="Aspfl";}
		#	elsif($id=~/^NFIA\_/){$species="Aspfi";}
		#	elsif($id=~/^ATET\_/){$species="Aspte";}
		#	elsif($id=~/^Afu/){$species="Aspfu";}
		#	else{$species="Aspor";}
		#}
		#----------------------------------------------------------------------------#
		
		else
		{
			$species=$id;
			$species=~s/\_.+//;
		}
		
		my $fileout=$species.".fasta";
		open(Out,">>$folderout/$folderout_family/$fileout") || die "Cannot open file $fileout";
		print Out ">$id\n$seq\n";
		close(Out);
		close(In);
	}
}
closedir(DIR);