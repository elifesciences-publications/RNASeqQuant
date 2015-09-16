#!/usr/bin/perl
#this script look at a sorted bed file, add an additional column to the right indicating number of consecutive read names. Next step is to split this file based on this new column
my ($k, $oldline, $newline, $OldReadName, $NewReadName, $ReadNumber, @line, @ReadName);
my $bedfile = $ARGV[0];
chomp $bedfile;

open(FIN, $bedfile) or die "can not open sorted bed file\n"; # file: sorted bed file.
$oldline = <FIN>; # read in 1 line to get started
chomp($oldline);
@eacholdline = split(/\t/,$oldline);
$OldReadName = $eacholdline[3]; #4th field is the read name
$ReadNumber = 0;
$line[$ReadNumber] = $oldline; #ReadName, ReadOR are for temporary storage of consecutive same read mapped to different OR. $ReadNumber is a count.
$ReadName[$ReadNumber] = $OldReadName;

while (<FIN>) {
	chomp($_);
	$newline = $_;
	@eachnewline = split(/\t/,$newline);
	$NewReadName = $eachnewline[3];
	if ($NewReadName eq $OldReadName ) {	# continue to read in the block with same read names.
		$ReadNumber++;
		$ReadName[$ReadNumber] = $NewReadName; #ReadName, line are for temporary storage of consecutive same read named lines. $ReadNumber is a count.
		$line[$ReadNumber] = $newline;
		next; #if found consecutive read names, store in ReadName, ReadOR. Then start reading a new line.
	}
#	print STDOUT "@ReadOR\n";
	if ($NewReadName ne $OldReadName) { #if consecutivity disrupted, start printing and marking the previous consecutive reads.
		$ReadNumber_add1 = $ReadNumber + 1;
		for ($k=0;$k<=$ReadNumber;$k++) { # go through all consecutive reads (mapped to different ORs)
			print STDOUT "$line[$k]\t$ReadNumber_add1\n";
		}			
		$OldReadName = $NewReadName; #to start the new round, reset everything
		$ReadNumber = 0;
		@line = "";
		@ReadName = "";
		$ReadName[0] = $OldReadName;
		$line[0] = $newline; 
	}
}
close (FIN);


