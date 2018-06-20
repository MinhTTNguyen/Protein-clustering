# October 4th 2017
# Get list of protein ids and cluster information from CLAN clusters

#! /usr/perl/bin -w
use strict;

my $CLAN_cluster_folder="/home/mnguyen/Research/Symbiomics/AA3/AA3_2/AA3_2_manuscript/CLAN/CLAN_all_clusters";
my $fileout="/home/mnguyen/Research/Symbiomics/AA3/AA3_2/AA3_2_manuscript/CLAN/CLAN_all_clusters";

open(Out,">$fileout") || die "Cannot open file $fileout";
print Out "#Cluster\tID\tDomain_location\n";
opendir(DIR,"$CLAN_cluster_folder") || die "Cannot open folder $CLAN_cluster_folder";
my @files=readdir(DIR);
closedir(DIR);

foreach my $file (@files)
{
	if (($file ne ".") and ($file ne ".."))
	{
		open(In,"<$CLAN_cluster_folder/$file") || die "Cannot open file $file";
		my $cluster=$file;
		$cluster=~s/^.+\_//;
		while (<In>)
		{
			$_=~s/\s*$//;
			if ($_=~/^\>/)
			{
				my $id_line=$_;
				$id_line=~s/^\>//;
				$id_line=~s/\s+\d+$//;
				if ($id_line=~/\;/)
				{
					my @ids=split(/\;/,$id_line);
					foreach my $each_id (@ids)
					{
						my @id_domain=split(/\|/,$each_id);
						my $seq_id=$id_domain[0];
						my $domain_loc=$id_domain[1];
						$domain_loc=~s/\-/../;
						print Out "$cluster\t$seq_id\t$domain_loc\n";
					}
				}
				else
				{
					my @id_domain=split(/\|/,$id_line);
					my $seq_id=$id_domain[0];
					my $domain_loc=$id_domain[1];
					$domain_loc=~s/\-/../;
					print Out "$cluster\t$seq_id\t$domain_loc\n";
				}
			}
		}
		close(In);
	}
}

close(Out);