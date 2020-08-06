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
#The variables for PAIRED end fastq-dumps, not others.
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


#2. Find a variant then explain its effect(s).
#On the 491st base of ebola.fa, there is a variant call for a possible mutation of the SRR read on the 8th amino acid
#for the CDS site for the virus' nucleoprotein. This variant call seen on the IGV and GFF, show that the variant on the 8th
#amino acid for this CDS results in a change from Isoleucine to Valine. This still results in a nonpolar amino acid, and
#results in only 1 less methyl group, but it could still have drastic effects on the formation of the nucleoprotein which
#encapsidates the genomic RNA. This loss of a methyl group would probably result in a loss of hydrophobic power to the
#nucleoprotein, and this small of an amino acid change could still significantly impact the way this protein aggregates
#to form the nucleoprotein. This is again just describing the single variant found in this protein coding region starting
#at 470-2689 bp. The protein ID is AAD14590.1, and its description on UniProtKB describes this protein as being able to
#oligomerize into helical filaments to encapsidate the viral genome. It also appears to be a pretty multifunctional
#protein, all of which could be affected by this variant, changing its affinity to surrounding proteins.

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
