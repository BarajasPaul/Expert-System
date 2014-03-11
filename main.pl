#!/bin/perl

=head Lincense
/* -*- Mode: Perl */
/*
 * main.pl
 * Copyright (C) 2014 Barajas D. Paul <barajasmoon@gmail.com>
 * 
 * RegExpert-System is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * RegExpert-System is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.";
 */
=cut
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

$ENV{SHOW_TABLES}=0;
my $entry_Value;
our @Assertion_array;
our @Negation_array;
my $choose_method;
our %hash_Validate_info=(
    True => \@Assertion_array,
    False => \@Negation_array
);
my ($get_true_table)= @ARGV;
$ENV{SHOW_TABLES}=1 if ($get_true_table);
print "------------------------------------>RegExpert-System<-------------------------------------\n\n\n";
&CompileRules;

my ($Antecedents,$IntConclusions)=ReadData();
#print Dumper($Antecedents);
#print Dumper($SortKeys);
#print Dumper($IntConclusions);

print "What method would you like to use to process the inference rules?\n";
print "A-> Forward Chaining\n";
print "B-> Backward Chaining\n";
chomp ($choose_method = <STDIN>);
given ($choose_method){
    when($_ =~ /a/i){
	foreach my $atoms (sort(keys %{$Antecedents})){
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
