#!/bin/perl


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
		ConlusionBC
		validateRules
		validateHypothesis
		ValidatelastElementConclusion
		GetRule
	    );
our @ISA = qw(Exporter);

our $ConlusionBC;
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
    $ConlusionBC=$value;
    &AddFinalConclusion($ConlusionBC);

    my $index=0;
    my @tmpTrueArray;
    my @tmpFalseArray;
    my @ArrayConsequents;
    &ValidatelastElementConclusion('AddRule',$value);
    print "Test: ".Dumper(@ArrayHypotesis);
    #print "Test: ".Dumper(@CorrectHypotesys);
    foreach(@ArrayHypotesis){
	print "test: ".Dumper($_);
	my $array=$$_;
	my @data=@$array;
	pop @data;
	foreach(@data){
	    my $aux=$_;
	    my $aux2=$aux;
	    my $aux3=$aux;
	    next if ($aux ~~ @ArrayConsequents);
	    next if (exists $IntConclusionHash{$aux});
	    push @ArrayConsequents,$aux2;
	    print $AntecedentValues{$aux};
	    push @AntecendentsBased,$aux3;
	    chomp ($entry_Value = <STDIN>);
	    if ($entry_Value =~ /[yes|y]/i){
		push @tmpTrueArray,$aux;
	    }else{
		push @tmpFalseArray,$aux;
	    }
	    &validateRules(\@tmpTrueArray,\@tmpFalseArray);
	    pop @tmpTrueArray;
	    pop @tmpFalseArray;
	}
    }
}

1;  
