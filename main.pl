#!/bin/perl

############################
##
###Interface
##
###########################

use warnings;
use strict;
use base 'Exporter';
use feature 'switch';

use Data::Dumper;
use InferenceMotor;
use Conclusion;
use Compiler;

$ENV{INFERENCE}=0;
my $entry_Value;
our @Assertion_array;
our @Negation_array;
my $choose_method;
our %hash_Validate_info=(
    True => \@Assertion_array,
    False => \@Negation_array
);
print "Expert System \n\n\n";
&CompileRules;

my ($Antecedents,$IntConclusions,@SortKeys)=ReadData();
#print Dumper($Antecedents);
#print Dumper($SortKeys);
#print Dumper($IntConclusions);

print "What method would you like to use to process the inference rules?\n";
print "A-> Forward Chaining\n";
print "B-> Backward Chaining\n";
chomp ($choose_method = <STDIN>);
given ($choose_method){
    when($_ =~ /a/i){
	foreach my $atoms (@SortKeys){
	    if(!&CheckConcluded($atoms)){                 
		next;
	    }
	    print "\n$atoms\n";
	    my $cpatoms=$atoms;
	    push @AntecendentsBased, $cpatoms;
	    print "$Antecedents->{$atoms}";
	    chomp ($entry_Value = <STDIN>);
	    if($entry_Value =~ /[yes|y|ye]/i){
		push @Assertion_array,$atoms;
	    }else{
		push @Negation_array,$atoms;
	    }
	    if(&validateRules(\@Assertion_array,\@Negation_array)){
		print "coool\n";
	    }else{
	    }
	    pop @Assertion_array;
	    pop @Assertion_array;
	}
    }when($_ =~ /b/i){
	$ENV{INFERENCE}=1;
	my ($entry_Value);
	print "Select a hypothesis that you want to conclude: \n";
	foreach (keys %{$IntConclusions}){
	    print "$_ -> $IntConclusions->{$_}\n";
	} 
	chomp ($entry_Value = <STDIN>);
	&validateHypothesis($entry_Value);
    }
    default { print "Nothing to do here\n";};

}
