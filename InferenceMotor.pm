#!/bin/perlsfdsfdbsuybfhdsbhjfbdshjdfsbdfssdsds fdsf  de tal manera que todo lo que se mueve de esta manera tiene un alcansade de llegar hacer mas profuno cque todo loq ue se relaiaziona
#con el fodfds
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
		validateHypothesis
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
	#print "Actual Rule is: $CheckRule";
	foreach (@{$ref_Assertation}){
	    my ($atom_check)=$_;
	    given($atom_check){
		when($CheckRule =~ /\>\s${_}\w/){
		    print "";
		}
		when($CheckRule =~ /\>\s${_}/){
		    &AddConclusion($atom_check);
		    print "";
		}
	    }
	    if($CheckRule  =~ /\!${atom_check}\b/){
		next;
	    }elsif($CheckRule =~ /\b(${atom_check})\b/){
		push @{$AoA[$row]},$atom_check;
		&VerifyConclusion(\@AoA,$row);

	    }
	}
	foreach (@{$ref_Negation}){
	    my ($atom_check)=$_;
	    given($atom_check){
		when($CheckRule =~ /\>\s\!${_}\w/){
		    print "";
		}
		when($CheckRule =~ /\>\s\!${_}/){
		    &AddConclusion($atom_check);
		}
	    }
	    if($CheckRule =~ /\!${atom_check}\b/){
		push @{$AoA[$row]},"!".$atom_check;
		&VerifyConclusion(\@AoA,$row);
	    }elsif($CheckRule =~ /\b${atom_check}\b/){
		next;
	    }
	}
	$row++;
    }
    return $check;

}
sub validateHypothesis(){
    my $value=shift;
    my $index=0;
    my @tmpTrueArray;
    my @tmpFalseArray;
    my @arrayHypo=();

    foreach(@ArrayRules){
	my $CheckRule=$_;
	if ($CheckRule =~ /${value}/){
	    print "$CheckRule \n";
	    push @arrayHypo, $ArrayRules[$index];
	}
	$index++;
    }
    my @CorrectHypotesys=&verifyIntermediateRules(@arrayHypo);
    print "Test: ".Dumper(@CorrectHypotesys);
    foreach(@arrayHypo){
	pop $_;
	foreach(@{$_}){
	    print $AntecedentValues{$_};
	    chomp ($entry_Value = <STDIN>);
	    if ($entry_Value =~ /yes/i){
		push @tmpTrueArray,$_;
	    }else{
		push @tmpFalseArray,$_;
	    }
	    &validateRules(\@tmpTrueArray,\@tmpFalseArray);
	    pop @tmpTrueArray;
	    pop @tmpFalseArray;
	}
    }
}

1;  
