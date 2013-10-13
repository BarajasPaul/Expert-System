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
	my ($Value)=shift;
	push @Consecuents,$Value;
	print "HOLLLLLLLLLLLLLLLLLLLLLLA!!!\n"
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
	    &Conclusion();
    }
    push $ArrayRules[$NumRule],$tmpConclusion;
}
1;
