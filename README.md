### This code is associated with the paper "Variation in olfactory neuron repertoires is genetically controlled and environmentally modulated". eLife, 2017. http://dx.doi.org/10.7554/eLife.21476

# RNASeqQuant
RNA-Seq quantification using a rescuing scheme that distributes ambiguously mapped reads based on uniquely mapped ones.
Implemented a rescueing scheme for RNA-Seq data quantification. It first maps reads to the genome, and then quantifies gene expression levels using counts obtained by only counting uniquely mapped reads. Then reads mapped to multiple loci are distributed based on the quantification from uniquely mapped reads. This pipeline is used for RNA-Seq data analysis in "Molecular profiling of activated olfactory neurons identifies odorant receptors for odors in vivo", Jiang et al., Nature Neuroscience, 2015.

No need to compile. Download the folder in an Unix environment, and run fast_step_wise_proportion.sh to see input options. If using the default bowtie as mapping tool, need to have bowtie installed. 
