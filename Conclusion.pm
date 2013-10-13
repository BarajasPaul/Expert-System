#!/bin/perl 
###########################################
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
	Conclusion
	VerifyConclusion
);
our @ISA = qw(Exporter);

my @Consecuents;

sub Conclusion(){
    my ($entry_Value);
    my ($ConclusionValue)=shift;
    my %DefinedConclusion=&GetConclusionHash();
    foreach (keys %DefinedConclusion){
	if($ConclusionValue eq $_ ){
	    print "Conclusion: $DefinedConclusion{$_}\n";
	    print "There's more Information, Would You like to continue\n";
	    chomp ($entry_Value = <STDIN>);
	    if ($entry_Value =~ /yes/i){
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

    sleep 1;
    my @ArrayRules=&GetArrayRules();
    my $tmpConclusion= pop $ArrayRules[$NumRule];
    print "$tmpConclusion\n";
    print Dumper($actualRule[0][$NumRule])." ~~ ".Dumper($ArrayRules[$NumRule]);
    if ($actualRule[0][$NumRule] ~~ @{$ArrayRules[$NumRule]}){
	    &Conclusion($tmpConclusion);
    }
    push $ArrayRules[$NumRule],$tmpConclusion;
}
1;
