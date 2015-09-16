#!/usr/bin/perl

# Parse a SAM file into a BED file that can be used in bedtools
# 081413: took another look at bowtie mannual... default output is 0-based. sam output is 1-based.
# Get the SAM file as the first argument

$sam = $ARGV[0];

if (! $ARGV[0])	# No argument is given
{
	print STDOUT "put sam file name\n";
	exit;
}

# Open the SAM file
open (SAM, "$sam") || die "Major problem: cannot open $sam for reading: $!";

while (<SAM>)		# Read one line at a time
{
	# 1
	if (! /^@/)		
	{
		chomp($_);					# Delete newline at end of each line
		@data = split(/\t/, $_);
		$chrom = $data[2];
		$start = $data[3]; # if default this is good. if sam use -1
		$end = $start+length($data[4]); # well this should be right... according to BED definition. 081413
		$name = $data[0];
		$strand = $data[1];	
		print STDOUT "$chrom\t$start\t$end\t$name\t0\t$strand\n";	
	}
}

close (SAM);

##########
