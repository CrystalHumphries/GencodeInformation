#!/usr/bin/perl
use strict;
use warnings;
sub trim($);

##########################################
#  Title: findBiotypes.pl                #
#                                        #
#  Objective: give list of ensembl ids,  #
#  either ENSG or ENSTs, and obtain      #
#  corresponding data-type               #
#                                        #
#  Date: 7/2013                          #
##########################################

my %Biotype;
my ($data_type, $GencodeRef);

sub print_error{
print<<END_OF_LINE
cat <gencode list.txt> | perl findBiotypeInfo.pl -d \"data-type\" -g gencode.gtf
     data-type: 
           -biotype          describes the type of transcript (psuedogene, protein coding, ncRNA,etc.)
           -geneName         returns the UCSC REFSEQ gene name
           -ENSG             returns the ENSG name that corresponds to all transcripts
           -ENST             resturn the ENST name that corresponds to all trancsripts
           -status           retuns the status of annotation on transcripts
     genecode list.txt
            needs to be a list of either ENST or ENSG names (one per line)
     gencode_file
            a simple gtf file of gencode attributes will suffice, just make sure it matches the version of your gencode list
END_OF_LINE
}

print_error() and die "Please Retry\n" if ((-t STDIN) || (!@ARGV)); 

check_files();

my $FLAG="F";
my $line=0;

# input inquiries into a hash
while(<STDIN>){
    chomp;
    $line++;
    my $transcript = trim($_);
    # is it a ENST or ENSG?
    if ($line == 1){
	$FLAG="ENST" if $transcript=~m/ENST/i;
	$FLAG="ENSG" if $transcript=~m/ENSG/i;
    }else{
	die "Found more than one type of data input type\n" if ($transcript!~m/$FLAG/g);
    }
    $Biotype{$transcript}=0;            
}



##check incoming argument to make sure it corresponds desired data-type
sub check_files{
    my %opts = @ARGV;

    print "Missing gencode file" and die unless (exists ($opts{-g}));
    open $GencodeRef, $opts{-g} or die ("Gencode Reference file does not exist");

    print "Missing data type" and die unless (exists ($opts{-d}));
    $data_type=$opts{-d};
    print_error() and die if ($data_type!~m/biotype|geneName|ENSG|ENST/);
}

## upload GencodeRef
while (my $line=<$GencodeRef>){
    my ($transcript, $ENSG, $ENST, $biotypeID, $status, $geneName ) = split(/\t/, $line);
    $ENSG=~s/\"|gene_id|\s+//g;            # parse the file into data-types
    $ENST=~s/\"|transcript_id|\s+//g;
    $biotypeID=~s/\"|gene_type|\s+//g;
    $status=~s/\"|gene_status|\s+//g;
    $geneName=~s/\"|gene_name|\s+//g;

    if ($FLAG eq "ENST"){                # print the desired outcome if list consisted of ENST IDs
	next unless (exists $Biotype{$ENST});
	print "$ENST\t$ENSG\n"       and del($ENST) and next if ($data_type eq "ENSG");
	print "$ENST\t$geneName\n"   and del($ENST) and next if ($data_type eq "geneName");
	print "$ENST\t$status\n"     and del($ENST) and next if ($data_type eq "status");
	print "$ENST\t$biotypeID\n"  and del($ENST) and next if ($data_type eq "biotype");
    }
    elsif($FLAG eq "ENSG"){
	next unless (exists $Biotype{$ENSG}); # print desired outcome if list consisted of ENSG IDs
	print "$ENSG\t$ENST\n"       and del($ENSG) and next if ($data_type eq "ENST");
	print "$ENSG\t$geneName\n"   and del($ENSG) and next if ($data_type eq "geneName");
	print "$ENSG\t$status\n"     and del($ENSG) and next if ($data_type eq "status");
	print "$ENSG\t$biotypeID\n"  and del($ENSG) and next if ($data_type eq "biotype");
    }
}

sub del{
    my $item = shift;
    delete($Biotype{$item});
}
    

sub trim($)  # remove extra white spaces
{
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    $string =~ s/\"//g;
    return $string;
}
