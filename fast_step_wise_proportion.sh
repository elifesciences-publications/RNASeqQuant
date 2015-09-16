#!/bin/bash
# a faster version of step wise proportional mapping. Only do bowtie once. July 20 2013
# argument1: the fastq file
# argument2: number of iterations user wants
# argument3: the output file
# this script does the following: 
# allowing multiple alignment, map to mm10 with bowtie
# separate the alignment based on times of multiple alignment
# pick the newly added multiple alignments,distribute these according to previous OR counts
# perl scripts called: sam2bed.perl, merge_by_OR_v2.perl, proportion_hiro.perl
# package and softwares called: bowtie, bedtools (IntersectBed)
# files called: mm10_bowtie_index, ORs_CDs_combined.bed
# in this version, allow user to specify other gene coordinate bed files (other than ORs_CDs_combined.bed in the first version)
# the user specified gene coordinate bed file is mybed=$2

myfastq=$1
mybed=$2
stepnumber=$3
myoutput=$4
savemapping=$5
bowtieindex=$6
if [ "$#" -ne "6" ]; then
	echo "
		AGRV1: fastq file 
		ARGV2: bed coordinate file
		ARGV3: m value for bowtie
		ARGV4: output count file name
		ARGV5: save mapping result file as (or F)
		ARGV6: prebuilt bowtie index (or S to skip the bowtie mapping step, in this case you should provide mapping result in ARGV1 instead of fastq)
	"
else
	mkdir ${myoutput}${stepnumber}.temp
	cd ${myoutput}${stepnumber}.temp
#	echo "your fastq file is" $myfastq
#	echo "your multiple alignment number is" $stepnumber
	if [ "$stepnumber" -lt 1 ]; then
	echo "step number should be at least 1!"
	else 
		if [ "${bowtieindex}" != "S" ]; then 
			echo "Your fastq file is" $myfastq
        		echo "Your multiple alignment number is" $stepnumber
#			echo "REMOVING NEXTERA ADAPTORS"
#			cutadapt -a TCGTCGGCAGCGTCAGATGTGTATAAGAGACAG -a CTGTCTCTTATACACATCTCCGAGCCCACGAGAC -m 20 -q 25 ../$myfastq > myfastq.trim.tempYJ
			echo "DOING YOUR MULTIPLE ALIGNMENT WITH BOWTIE..."
#			bowtie -a -m ${stepnumber} ${bowtieindex} myfastq.trim.tempYJ > multi.sam.tempYJ
			bowtie -a -m ${stepnumber} ${bowtieindex} ../$myfastq > multi.sam.tempYJ
#			bowtie -a -m ${stepnumber} ${bowtieindex} ../$myfastq -3 50 > multi.sam.tempYJ
			if [ "$savemapping" != "F" ]; then
				cat multi.sam.tempYJ > ../${savemapping}
			fi
		else
			echo "You provided bowtie mapping output in ARGV1 as" $myfastq
			echo "You provided the m in ARGV3 as" ${stepnumber}
			echo "SKIP BOWTIE..."
			cat ../${myfastq} > multi.sam.tempYJ
		fi 
		./../sam2bed.perl multi.sam.tempYJ > multi.bed.tempYJ
		sort -k4 multi.bed.tempYJ > sorted.multi.bed.tempYJ
		./../mark_bed.perl sorted.multi.bed.tempYJ | awk -F "\t" '{print > "m"$7".bed.tempYJ"}' # this mark add the 7th column... have to remove to use proportion_hiro.perl
		./../bedtools-2.17.0/bin/intersectBed -a ../${mybed} -b m1.bed.tempYJ -c | sort -t\t -k4,4 | sort -k4 > OR_Count1_unmerged.sorted.tempYJ 
		./../merge_by_OR_v2.perl OR_Count1_unmerged.sorted.tempYJ > OR_Count1.tempYJ
		cat OR_Count1.tempYJ > store.tempYJ
		if [ "$stepnumber" = "1" ]; then
			cat store.tempYJ > ../${myoutput}
		else
			echo "ITERATION NUMBER 2"
                	./../bedtools-2.17.0/bin/intersectBed -a m2.bed.tempYJ -b ../${mybed} -wa -wb | cut -f -6,8- > m2.overlap.OR_CD.tempYJ                          
                	./../proportion_hiro.perl OR_Count1.tempYJ m2.overlap.OR_CD.tempYJ  > OR_Count2.tempYJ
			cut -f 2 OR_Count2.tempYJ > col22.tempYJ 
			paste store.tempYJ col22.tempYJ > append.tempYJ
			cat append.tempYJ > store.tempYJ
			if [ "$stepnumber" -gt 2 ]; then
				for i in `seq 3 $stepnumber`;
				do
					echo "ITERATION NUMBER" $i
					previous=$(expr $i - 1)
					./../bedtools-2.17.0/bin/intersectBed -a m${i}.bed.tempYJ -b ../${mybed} -wa -wb | cut -f -6,8-  > m${i}.overlap.OR_CD.tempYJ
					./../proportion_hiro.perl OR_Count${previous}.tempYJ m${i}.overlap.OR_CD.tempYJ  > OR_Count${i}.tempYJ	
					cut -f 2 OR_Count${i}.tempYJ > col2${i}.tempYJ
					paste store.tempYJ col2${i}.tempYJ > append.tempYJ
					rm store.tempYJ
					cat append.tempYJ > store.tempYJ
				done
			fi
			cat store.tempYJ > ../${myoutput}
		fi
	fi
	rm *.tempYJ
	cd ..
	rmdir ${myfastq}${stepnumber}${myoutput}.temp
fi
