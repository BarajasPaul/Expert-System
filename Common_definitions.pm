#!/bin/perl

=head Lincense
/* -*- Mode: Perl */
/*
 * Common_definitions.pm
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
### Common_definitions Modules
###---------------------------------------------------------------------------------
### -It has the purpose to define all common variables that can use in different    |
### implementations and not repeat definitions,it will provide a good performance.								    |
### -Provide a error handling to identified what kind of errors found		    |
### at the moment of compiling and Data collection				    |
###----------------------------------------------------------------------------------
###
###############################################

use warnings;
no warnings 'experimental::smartmatch';
package Common_definitions;
use Exporter;

use Compiler;
use Data::Dumper;

our @EXPORT = qw(
    @ArrayRules
    @Array_of_Stacks
    $operator_regex
    $atom_match
    %implication_atom
    %conclusion
    new_knowledge_base
    delete_new_line
    trim
    check_data
    %hash_reference_conjunction
    analyze_balanced_parenthesis
    get_groups_matching
    exact_match_atom
    new_stack
    get_atoms_rule
    get_conclusions
    CONJUNTION_ATOM
    IMPLICATION_ATOM
    REMOVE_RULE
    ADD_RULE
);
our @ISA = qw(Exporter);

our %hash_reference_conjunction;
our %conclusion;
our @ArrayRules=[];
our @Array_of_Stacks=[];
our $operator_regex= qr/([\&|\||\-\>|\=])/;
our $atom_match=qr/[\w+\d+]+/;
my $inc=0;

our %mistakes_rules= (
        missing_operator => qr/\w+(?!\s?${operator_regex}\s?\w+)/,
        bad_implication => qr/\-(?=\>)|(?>=\-)\>/,
        missing_close_brackets => qr/\w+\s?(\))/,
);

our %implication_atom=(
    test_atom => qr/(?<=\|\s)/,
    test_atom2 => qr/(?<=\|)/,
    test_atom3 => qr/(?=\s\|)/,
    test_atom4 => qr/(?=\|)/,
);


sub new_knowledge_base{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub delete_new_line{
    local ($info)=shift;
    trim(chomp($info));
    return $info;
}
sub trim($) {
    my $string = shift;
    $string =~ s/^\s+|\s+$//g;
    return $string
}
sub check_data{
    local ($conection,$tree_postion,$actual_element)=@_;
    if ($conection eq "|"){
        ($alternitive_atom)=pop  @{$ArrayRules[$tree_postion]};
        $hash_reference_conjunction{$inc}=[$alternitive_atom,$actual_element];
        push @{$ArrayRules[$tree_postion]},$hash_reference_conjunction{$inc};
        $inc++;
    }else{
        push @{$ArrayRules[$tree_postion]},$actual_element;
    }
    if($conection =~ /\-\>/){
        my $hash_element=&Compiler::get_antecedents();
        $conclusion{$actual_element}=$hash_element->{$actual_element};
    }
}
sub analyze_balanced_parenthesis{
    qr/^(
        (?<not_parenthesis>[^()]*+)
        \(
            (?>
                [^()]++
                |
                (?1)
            )*
        \)
        \g{not_parenthesis}
        )$
   /x;
}
sub get_groups_matching{
    ($line)=shift;
    my @array=$line=~/(\(\s?\!?${atom_match}\s?..?\s?\!?${atom_match}\s?\))/g;
    return @array;
}
sub exact_match_atom{
    ($atom,$rule)=@_;
    #print "------'$atom'----'$rule'";
     if($rule =~ /(?<validate>(?:\!?\w+|\!|\d+|)?${atom}(?:\w+|\d+)?)/g){
        if($+{validate} eq $atom){
            return 1;
        }else{
            return 0;
        }
    }
}
sub new_stack{
    my %stack=( first_stack_pointer => $_[0],
                second_stack_pointer => $_[1]);
    return \%stack;
}
sub get_atoms_rule{
    local $array=shift;
    local $ref_a=$$array;
    my @aux_array;
    foreach my $atoms(@$ref_a){
        if(ref($atoms) eq "ARRAY"){
            foreach my $sub_atom(@$atoms){
                push @aux_array,$sub_atom;
            }
        }else{
            push @aux_array,$atoms;
        }
    }
    return @aux_array;
}
sub get_conclusions{
    return \%conclusion;
}

sub CONJUNTION_ATOM{1;}
sub IMPLICATION_ATOM{0;}
sub REMOVE_RULE{"RemoveRule";}
sub ADD_RULE{"AddRule";}
1;
