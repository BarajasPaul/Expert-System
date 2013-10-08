#!/bin/perl a
###########################################
#
#In particular, we would like to know, given some sentences,
#whether other sentences are or are not logical conclusions.
#
#############################################

use warnings;
use strict;
use InferenceMotor;
use Compiler;

package Conclusion;

use Data::Dumper;
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
}

sub VerifyConclusion(){
	my ($Value)=shift;
	foreach(@Consecuents)
	{
		if($_ eq $Value){
			return 1;
		}else{
			return 0;
		}
	}
}

1;
