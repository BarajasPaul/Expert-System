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
my $result=ReadData();
print Dumper($result);

foreach my $atoms (sort keys %$result){
=true	if ($atoms =~ /(C|E|F)/){
		my $check=&validateRules(\@Assertion_array,\@Negation_array);
		if(!$check){
			push @Negation_array,$atoms;
		    next;
		}else{
		    print "$result->{$atoms}\n";
			&Conclusion($atoms);
		    push @Assertion_array,$atoms;
		    next;
		}
	}
=cut
    print "$atoms\n";
	print "Do you have a $result->{$atoms}";
	chomp ($entry_Value = <STDIN>);
	if ($entry_Value =~ /yes/i){
		push @Assertion_array,$atoms;
	}else{
		push @Negation_array,$atoms;
	}
}
