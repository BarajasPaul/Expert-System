#!/bin/perl

=head Lincense
/* -*- Mode: Perl */
/*
 * Tree_Logical.pm
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

#############################################
###
###Information will be process here
###
###############################################

use warnings;

package Tree_Logical;

use Compiler;
use InferenceMotor;
use Data::Dumper;
use Tree::Simple;
use Tree_Builder;

use feature 'switch';
use base 'Exporter';

our @EXPORT = qw(
	evaluate_tree
	Tautologic_Conclusion
	Logical_table
	clone_tree
	check_logical_equivalence
);

our @ISA = qw(Exporter);
my @binary_table=[];
my @backup_binary_table=[];
our $inc=0;
my $get_atom=qr/(\w(\w)?)/;

sub check_logical_equivalence(){
    my ($actual_rule,@rule_groups)=@_;
    my (@True_array_rules);
    my $negation_equivalence=0;
    my $changed_equivalence=1;
    while(@rule_groups){
	my $rule_to_modife=shift(@rule_groups);
	next if not $rule_to_modife;
	if($rule_to_modife =~ /^\!/){
	    while($changed_equivalence){
		my ($get_symbol)=$rule_to_modife;
		    if ($rule_to_modife =~ /((\!)?${get_atom}(\s)?)(\&|\||\=|\-\>)((\s)?(\!)?${get_atom})/){
			my ($left)=trim($1);
			my ($symbol)=trim($5);
			my ($right)=trim($6);
			my ($new_rule)=&change_symbol($symbol,$left,$right);
			push @True_array_rules,$new_rule;
			$negation_equivalence=0;
			$changed_equivalence=0;
		    }else{
			print "Cannot get symbol, check your syntax please\n";
			exit 1;
		    }
	    }
	    $negation_equivalence=1;
	    $changed_equivalence=1;
	}
	if($rule_to_modife =~ /^\(.*\)/g){
	    push @True_array_rules,$rule_to_modife;
	}
    }
    return @True_array_rules;
}



sub evaluate_tree( ) {
    my ($left,$right,$symbol)=@_;
    given($symbol){
        when('&'){
            return ($left and $right);
        }when('|'){
            return ($left or $right);
        }when('!'){
	    if ($left){
		return 0;
	    }else{
		return 1;
	    }
        }when('->'){
            return (!$left or $right);
        }when('='){
	    if ($left eq $right){
		return 1;
	    }else{
		return 0;
	    }
	}
    }
}

sub Logical_table{
    my ($arraySz)=shift;
    $inc=0;
    show_combinations($arraySz);
    sub show_combinations {
	my($n,@prefix)=@_;
	if($n > 0) {
	    show_combinations( $n-1, @prefix, 0);
	    show_combinations( $n-1, @prefix, 1);
	} else {
	    push @{$binary_table[$inc++]},@prefix;
	}
    }
    @backup_binary_table=map { [@$_] }@binary_table;
    return @binary_table;
}


sub clone_tree(){
    my $task=shift;
    my $root_rule=shift;
    if($task eq 2){
       my @array;
       push @array, $root_rule;
       &Tree_Builder::Build_tree(1,@array);
    }
}

sub Tautologic_Conclusion(){
	my ($root_rule)=shift;
	my ($result_satisfaction)=shift;
	my ($preposition)=shift;
	my (@array_tautologic)=@_;
	my $n=0;
	if ($ENV{SHOW_TABLES}){
	    print "------------------------------------------------------------------------------------\n ";
	    foreach(sort keys %$preposition){
	    print "$_   ";
	    }
	    print "\n";
	    print "------------------------------------------------------------------------------------\n";
	    foreach(@backup_binary_table){
		my (@array)=@$_;
		my $bit_combination=join('   ',@array);
		print "|$bit_combination| -> ".$array_tautologic[$n++]."\n";
	    }
	    if($result_satisfaction){
		print "$root_rule -> is satifaction\n";
	    }else{
		print "$root_rule -> is NOT satifaction\n";
	    }
	foreach(@array_tautologic){
	    if($_ eq 0){
		$n=0;
	    }
	}
	if(not $n){
	    print "$root_rule -> is NOT a Tautologic\n";
	}else{
	    print "$root_rule -> is a Tautologic\n";
	}
	sleep 1;
    }
    foreach $index (0 .. $#binary_table) {
	      delete $binary_table[$index];
    }
    foreach $index (0 .. $#backup_binary_table) {
	delete $backup_binary_table[$index];
    }
    @backup_binary_table=[];
    @binary_table=[];
}
sub change_symbol(){
    my ($symbol,$left_element,$right_element)=@_;
    given($symbol){
        when('&'){
		$symbol='|';
		if($left_element =~ /\!/){
		    $left_element =~ /${get_atom}/;
		    $left_element=$1;
		}else{
		    $left_element='!'.$left_element;
		}
		if($right_element =~ /\!/){
		    $right_element=~ /${get_atom}/;
		    $right_element=$1;
		}else{
		    $right_element='!'.$right_element;
		}
	    return "( $left_element $symbol $right_element )";

        }when('|'){
	    $symbol='&';
	     if($left_element =~ /\!/){
		 $left_element =~ /${get_atom}/;
		 $left_element=$1;
	     }else{
		 $left_element='!'.$left_element;
	     }
	     if($right_element =~ /\!/){
		 $right_element=~ /${get_atom}/;
		 $right_element=$1;
	     }else{
		 $right_element='!'.$right_element;
	     }
	     return "( $left_element $symbol $right_element )";
        }when('->'){
	    $symbol='&';
	     if($right_element =~ /\!/){
		 $right_element=~ /${get_atom}/;
		 $right_element=$1;
	     }else{
		 $right_element='!'.$right_element;
	     }
	     return "( $left_element $symbol $right_element )";
        }
    }
}
1;
