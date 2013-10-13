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
my @AoA=[];
sub GetRule(){
	    return $contentRules[$nextrule];
}

sub validateRules(){
    my $ref_Assertation=shift;
    my $ref_Negation=shift;
    my $check;
    my $validatepremise;
    my $row=0;
    foreach(@contentRules){
	my $CheckRule=$_;
	print "Actual Rule is: $CheckRule";
	foreach (@{$ref_Assertation}){
	    my ($atom_check)=$_;
	    print $atom_check."\n";
	    given($atom_check){
		when($CheckRule =~ /\>\s${_}\w/){
		    print "";
		}
		when($CheckRule =~ /\>\s${atom_check}/){
		    &Conclusion();   	    
		}
	    }
	    
	    if($CheckRule  =~ /\!.*${atom_check}/){
		next;
	    }elsif($CheckRule =~ /\b(${atom_check})\b/){
		push @{$AoA[$row]},$atom_check;
		&VerifyConclusion(\@AoA,$row);
	    }
	}
	foreach (@{$ref_Negation}){
	    my ($atom_check)=$_;
	    sleep 5;
	    if($CheckRule =~ /\b(\>\s\!${atom_check})\b/){
		&Conclusion();
	    }elsif($CheckRule =~ /(\!.*${atom_check}\b)/){
		push @{$AoA[$row]},$1;
		&VerifyConclusion(@AoA,$row);
	    }elsif($CheckRule =~ /(${atom_check}\b)/){
		push @{$AoA[$row]},[];
	    }
	}
	$row++;
	print $row."\n";
    }
    return $check;

}
sub IntermediateConclusion(){
    my $ActualRule=shift;
    my $value=shift;
}

1;  
