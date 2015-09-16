#!/usr/bin/perl
# new version of merge by OR (or Gene name), does not need sorted input anymore.
my $Intersectbed_output = $ARGV[0];
my @OR = "";
my @Count = "";
my @Check = "";
my @MergedOR = "";
my @MergedCount= "";
my $i = 0;
my $j = 0;
my $k = 0;
my $l = 0;
my $m = 0;
open(FIN, $Intersectbed_output) or die "can not open file\n"; # file: Intersectbed output, with ORs and counts, this script merges those rows and sum the count number.  list of ORs in column , read counts in column
while (<FIN>)
{
    chomp($_);
    $newline = $_;
    @eachnewline = split(/\t/,$newline);
    $OR[$i] = $eachnewline[3];
    $Count[$i] = $eachnewline[6];
	$Check[$i] = 0;
	$i++;
}

close (FIN);

for ($j=0;$j<$i;$j++) {
	if ($Check[$j]==0) {
		$MergedOR[$m]=$OR[$j];
		$Check[$j]=1;
		$MergedCount[$m]=$Count[$j];
		for ($k=0;$k<$i;$k++) {
			if ($Check[$k]==0 && $MergedOR[$m] eq $OR[$k]) {
				$MergedCount[$m] = $MergedCount[$m] + $Count[$k];
				$Check[$k] = 1;
			}
		}
	$m++;
	}
	if ($Check[$j]==1) {
		next;
	}
	else {
		print STDOUT "Something going wrong!!!!\n";
	}
}

for ($l=0;$l<$m;$l++) {
	print STDOUT "$MergedOR[$l]\t$MergedCount[$l]\n";
}
