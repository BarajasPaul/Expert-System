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

=head1 NAME

main.pl - Main menu interface

=head1 VERSION

VERSION 0.001

=head1 DESCRIPTION

RegExper-system based In propositional logic, modus ponendo ponens,
It attendant to process,analyze and verified each Inference rule to get correctly its conclusion and obtain a successful result.
In this case, you will be able to select a method to conclude that are:
-Forward Chaing.
-Backward Chaining.

Addition Fuction:
It also provide a table of logical equivalences to validate inferences rules.
to enable this functionality, you will have to pass a argument "1" in the command line as the first parameter, at this moment it should  be able to see the the table of logical from each inference rule.

=cut

use warnings;
use strict;
no warnings 'experimental::smartmatch';
use Exporter;
use feature 'switch';

use Data::Dumper;
use InferenceMotor;
use Conclusion;
use Compiler;
use Common_definitions;
our @ISA = qw(Exporter);

$ENV{SHOW_TABLES}=0;
my $choose_method;
my ($get_true_table)= @ARGV;
$ENV{SHOW_TABLES}=1 if ($get_true_table);
print "------------------------------------>RegExpert-System<-------------------------------------\n\n\n";

my $Antecedents=&ReadData();
&CompileRules;
#print Dumper($Antecedents);
#print Dumper($SortKeys);
#print Dumper($IntConclusions);
print "What method would you like to use to process the inference rules?\n";
print "A-> Forward Chaining\n";
print "B-> Backward Chaining\n";
chomp ($choose_method = <STDIN>);
given ($choose_method){
    when($_ =~ /a/i){
        foreach my $atoms (@ArrayRules){
            my $count=0;
            foreach my $antecedent_value (@$atoms){
                next if (scalar(@$atoms)-1 eq $count);
                if(ref($antecedent_value) eq "ARRAY"){
                    map{&Interface_rule($_,$Antecedents)}@{$antecedent_value};
                }else{
                     &Interface_rule($antecedent_value,$Antecedents);
                }
                $count++;
            }
        }
    }when($_ =~ /b/i){
        $ENV{INFERENCE}=1;
        my ($entry_Value);
        print "Select a hypothesis that you want to conclude: \n";
        my $conclusion=&Common_definitions::get_conclusions();
        foreach (keys %$conclusion){
            print "$_ -> $conclusion->{$_}\n";
        }
        chomp ($entry_Value = <STDIN>);
        &validateHypothesis($entry_Value,$Antecedents);
    }
    default { print "Nothing to do here\n";};
}
