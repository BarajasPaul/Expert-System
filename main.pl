#!/bin/perl

############################
##
##Interface
##
###########################

use warnings;
use strict;
use base 'Exporter';

use Data::Dumper;
use InferenceMotor;
use Conclusion;
use Compiler;

my $entry_Value;
our @Assertion_array;
our @Negation_array;
our %hash_Validate_info=(
    True => \@Assertion_array,
    False => \@Negation_array
);
print "Expert System \n\n\n";
&CompileRules;

print "";   
my ($Antecedents,@SortKeys)=ReadData();
#print Dumper($Antecedents);
#print Dumper($SortKeys);


foreach my $atoms (@SortKeys){
    print "$atoms\n";
	print "Do you have a $Antecedents->{$atoms}";
	chomp ($entry_Value = <STDIN>);
	if ($entry_Value =~ /yes/i){
		push @Assertion_array,$atoms;
	}else{
		push @Negation_array,$atoms;
	}
	if (&validateRules(\@Assertion_array,\@Negation_array)){
	    print "coool\n";
	}else{
	    pop @Assertion_array;
	    pop @Negation_array;
	}
}
