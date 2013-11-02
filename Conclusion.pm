#!/bin/perl 
##########################################
#
#In particular, we would like to know, given some sentences,
#whether other sentences are or are not logical conclusions.
#
#############################################

use warnings;
use strict;

package Conclusion;

use Data::Dumper;

use InferenceMotor;
use Compiler;

use feature qw/switch/;
our @EXPORT = qw(
	AddConclusion
	Conclusion
	VerifyConclusion
	CheckConcluded
	@AntecendentsBased
);
our @ISA = qw(Exporter);

my @Consecuents;
my @Concluded;
my $RuleTest=1;
our @AntecendentsBased;
sub AddConclusion()
{
    print "Test add Conclusion\n";
    my (%DefinedConclusion)=&GetConclusionHash();
    if (exists $DefinedConclusion{$_}){
	last;
    }else{
	$DefinedConclusion{$_}=$AntecedentValues{$_};
    }
}

sub Conclusion(){
    my ($entry_Value);
    my $atom;
    my $i=0;
    my ($ConclusionValue)=shift;
    print Dumper(@AntecendentsBased);
    my %DefinedConclusion=&GetConclusionHash();
    print "Conclusion obtanied by the following knowledge: \n ";
    if (exists $FinalConclusions{$ConclusionValue}){
	foreach (@AntecendentsBased){
	    sleep 1;

	    if (exists $IntConclusionHash{$_}){
		print  " -> | ".$IntConclusionHash{$_}." -> ";
		next;
	    }elsif($_ =~ /\!(\w)/){
		$atom=$1;
		print  "| not ".$AntecedentValues{$atom}." -> ";
	    }else{
		print  "| ".$AntecedentValues{$_}." -> ";
	    }	    
	}
	print "\nConclusion: $FinalConclusions{$ConclusionValue}\n";
	print "Actually, obtained a Final Conclusion\n";
	exit -1; 
    }
    foreach (keys %DefinedConclusion){
	if($ConclusionValue =~  /${_}\b/){
	    push @Concluded,$ConclusionValue;
	    print "Conclusion: $DefinedConclusion{$_}\n";
	    print "There's more Information, Would You like to continue (y/n)\n";
	    chomp ($entry_Value = <STDIN>);
	    if ($entry_Value =~ /y/i){
		    return 0;
		    next;
	    }else{
		exit -1;
	    }
	}
    }
}

sub VerifyConclusion(){
    my @actualRule=shift;
    my $NumRule=shift;
    my $flag=0;
    my $aux=undef;
    my ($row)=0;
    #sleep 1;
    my $tmpConclusion= do {if (defined $ArrayRules[$NumRule]){pop $ArrayRules[$NumRule]}else{next}};
    #print "$tmpConclusion\n";
    print Dumper($actualRule[0][$NumRule])." ~~ ".Dumper($ArrayRules[$NumRule]);
    foreach(@{$ArrayRules[$NumRule]}){
	#print " - $_ -";
	if ($_ ~~ $actualRule[0][$NumRule]){
	    #    print "\n*MATCH*\n";
	    $flag=1;
	}else{
	    $flag=0;
	    last;
	}
    }
    if($flag){
	$RuleTest=&Conclusion($tmpConclusion,$ArrayRules[$NumRule]);
	$flag=0;
    }

    push $ArrayRules[$NumRule],$tmpConclusion;
    unless($RuleTest){
	$RuleTest=1;
	foreach(@ArrayRules){
	    my $lastelement=do {if(defined($_)){pop $_}else{$row++ ;next;}};
	    $aux=$lastelement;
	    push $_,$lastelement;
	    if ($aux eq $tmpConclusion){
		delete $ArrayRules[$row];	
	    }
	$row++;
	}
	$aux=$tmpConclusion;
	push @AntecendentsBased,$aux;	
	#print Dumper(@ArrayRules);
	&InferenceMotor::validateRules([$tmpConclusion]);
       $row=0;	
    }
}   

sub CheckConcluded(){
    my ($Validate_Atom)=shift;
    my $flag1=0;
    # print "WORK\n";
    my @ArrayRules=&GetArrayRules();
    foreach (@ArrayRules){
	if (grep {
		    my $tmp=$_;
		    foreach(@{$tmp}){
			if($_ =~ /\b${Validate_Atom}\b/){
			    return 1;
			}
		    }
		} $_){
	    return 1;
	}else{
	    $flag1=0
	}
    }
    return $flag1;
}

1;
