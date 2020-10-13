# Perform all these in the same directory as all your working data.

# Ensure all dependencies are installed for this operation (MacOSX).
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
wget https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
bash Miniconda3-latest-MacOSX-x86_64.sh
conda config --add channels conda-forge
conda config --add channels bioconda
brew install samtools
brew install fastqc
brew install readseq
brew install bwa
brew install bcftools

# To start, open the bioinfo environment
source activate bioinfo


ACC=ebola.fa
REF=$ACC
#This is an ebola SRR
SRR=SRR7813721
BAM=$SRR.bam
R1=${SRR}_1.fastq
R2=${SRR}_2.fastq

#Your reference genome must always be indexed by the aligner that you will use downstream, and of course you must fastq-dump the SRR number for alignment
bwa index $REF
#1. Use an SRR sequencing run of your choice. Show how you obtained the SRR sequence and describe what kind of data it is. 3/3 points possible
#Response: The data obtained from retrieving data from an SRR is fastq data. This fastq data can then be used by the aligner
fastq-dump -X 100000 --split-files $SRR

#This aligner will create a BAM file with all your variables, followed by indexing.
bwa mem $REF $R1 $R2 | samtools sort > $BAM
samtools index $BAM
#To variant call, you must convert to a vcf file, then use your tool. You can then "cat" or "less" the file to read in text format rather than visually.
samtools mpileup -uvf $REF $BAM > $SRR.vcf
bcftools call --ploidy 1 -vm -Ov $SRR.vcf > ebola11_18.vcf
#To get the GFF file of the Reference genome, I downloaded the GB file of the Reference, then converted it to GFF with readseq to "cat" and read.
cat theebola.gb | readseq -p -format=GFF > ebola.gff
cat ebola.gff

#CONDENSED SCRIPT
source activate bioinfo
ACC=ebola.fa
REF=$ACC
SRR=SRR7813721
BAM=$SRR.bam
R1=${SRR}_1.fastq
R2=${SRR}_2.fastq

bwa index $REF
fastq-dump -X 100000 --split-files $SRR

bwa mem $REF $R1 $R2 | samtools sort > $BAM
samtools index $BAM
samtools mpileup -uvf $REF $BAM > $SRR.vcf
bcftools call --ploidy 1 -vm -Ov $SRR.vcf > ebola11_18.vcf
cat theebola.gb | readseq -p -format=GFF > ebola.gff
cat ebola.gff
