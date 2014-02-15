GencodeInformation
==================

Purpose: To easily extract anntation information from Gencode ENSG/ENST IDs (Biotype,RefSeq Name, ENSG, ENST, status)

How to Run:
  
    cat <gencode list.txt> | perl findBiotypeInfo.pl -d "data-type" -g gencode.gtf
     data-type: 
           -biotype          describes the type of transcript (psuedogene, protein coding, ncRNA,etc.)
           -geneName         returns the UCSC REFSEQ gene name
           -ENSG             returns the ENSG name that corresponds to all transcripts
           -ENST             resturn the ENST name that corresponds to all trancsripts
           -status           retuns the status of annotation on transcripts
     genecode list.txt
            needs to be a list of either ENST or ENSG names (one per line)
     gencode_attributes
            10th column of a gtf file of gencode attributes, seperating fields by "\t" instead of ";"
    
Input list needs to consist of only ENSG IDS or ENST IDs. 

The gencode_attributes.txt consists of the 10th column of the Gencode_annotations.gtf file which has ';' replaced by a tab "\t"

To create this file, do the following:

    perl -nle 'next if $_=~m/\#{2}/; @a=split(/\t/); @b=split(";",$a[8]); $f=$b[0]; $ENSG=~s/gene_id|\"//g; print join("\t",$ENSG, @b)' gencode.v19.annotation.gtf > annotation_attributes.txt
  
biotype:  psuedogene, protein-coding, ncRNA, etc.
geneName: APOE, ABCA1, GAPDH, etc.
ENSG:     ENSG00000227232.4
ENST:     ENST00000541675.1
status:   KNOWN, NOVEL, or PUTATIVE
