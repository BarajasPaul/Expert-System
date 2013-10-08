#!/bin/perl a
###########################################
#
#Information will be process here
#
#############################################

use warnings;

package InferenceMotor;

use Conclusion;
use Data::Dumper;
use Compiler;
use feature qw/switch/;
our @EXPORT = qw(
		validateRules
		GetRule
	    );
our @ISA = qw(Exporter);

my $nextrule=0;

sub GetRule(){
	    return $contentRules[$nextrule];
}

sub validateRules(){
    my $ref_Assertation=shift;
    my $ref_Negation=shift;
    my $check;
    my $validatepremise;

    #print Dumper(\@$ref_Assertation);
    #print Dumper(\@$ref_Negation);
    my $CheckRule=&GetRule();

    print "Actual Rule is: $CheckRule";

    foreach (@{$ref_Assertation}){
		my ($atom_check)=$_;
		if($CheckRule  =~ /(\!.*${atom_check})/){
			print "This $atom_check atom it's not part of this rule!!!\n";
			$check=0;
		}elsif($CheckRule =~ /(${atom_check})/){
			&Conclusion($atom_check);
			$premise=$1;
			$check=1;
		}
		else{
	    	$check=&VerifyConclusion($atom_check);
		}
    }
    foreach (@{$ref_Negation}){
		my ($atom_check)=$_;
		if ( $CheckRule =~ /(\!.*${atom_check})/){
			&Conclusion($atom_check);
			$premise=$1;
			$check=1;
	    	next;
		}elsif($CheckRule =~ /(${atom_check})/){
			print "This $atom_check atom it's not part of this rule!!!\n";
			$check=0;
		}
		else{
	    	$check=&VerifyConclusion($atom_check);
		}
    }
    #IntermediateConclusion($CheckRule,$premise);
    if(!$check){
	}
    return $check;
}
sub IntermediateConclusion(){
    my $ActualRule=shift;
    my $value=shift;
}

1;  
