#!/bin/perl

############################
##
##Interface
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

my ($Antecedents,@SortKeys)=ReadData();
#print Dumper($Antecedents);
#print Dumper($SortKeys);

print "What method would you like to use to process the inference rules?\n";
print "A-> Forward Chaining\n";
print "B-> Backward Chaining\n";
chomp ($choose_method = <STDIN>);
given ($choose_method){
    when($_ =~ /a/i){
	foreach my $atoms (@SortKeys){
	    print "$atoms\n";
	    print "$Antecedents->{$atoms}";
	    chomp ($entry_Value = <STDIN>);
	    if ($entry_Value =~ /yes/i){
		push @Assertion_array,$atoms;
	    }else{
		push @Negation_array,$atoms;
	    }
	    if (&validateRules(\@Assertion_array,\@Negation_array)){
		print "coool\n";
	    }else{
	    }
	    pop @Assertion_array;
	    pop @Assertion_array;
	}
    }when($_ =~ /'b'/i){
	print "Nothing to do here";
    }
    default { print "Nothing to do here\n";};

}
