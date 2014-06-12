#!/bin/perl

=head1 Lincense
/* -*- Mode: Perl */
/*
 * InferenceMotor.pm
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

InferenceEngine.pm

=head1 VERSION

VERSION 0.001

=head1 DESCRIPTION

The inference engine applied logical rules to the knowledge base and deduced new knowledge. This process would iterate as each new fact in the knowledge base could trigger additional rules in the inference engine.

=cut

use warnings;
no warnings 'experimental::smartmatch';
package InferenceMotor;

use Conclusion;
use Data::Dumper;
use Compiler;
use Common_definitions;

require Exporter;
use feature qw/switch/;
our @EXPORT = qw(
            Interface_rule
            antecedent_analyse
            validateRules
            validateHypothesis
            ValidatelastElementConclusion
            get_AoA
        );
our @ISA = qw(Exporter);

our $ConlusionBC;
our @AoA=[];

=head1 FUNCTION

Interface_rule

=head1 DESCRIPTION

Interface Rule is used to validate user decisions.

=head1 BUGS

Not found

=cut

sub Interface_rule(){
    ($atom,$Antecedents)=@_;
    my ($value_to_process,$entry_value);
    $atom=~ s/\!//g if ($atom =~ /\!/);
    if(&Concluded($atom)){
        next;
    }
    ($cpatoms)=$atom;
    push @AntecendentsBased, $cpatoms;
    print "$atom --> \n$Antecedents->{$atom}";
    chomp ($entry_Value = <STDIN>);
    if($entry_Value =~ /[yes|y|ye]/i){
        $value_to_process=$atom;
    }else{
        $value_to_process="!".$atom;
    }
    &validateRules($value_to_process);
}


=head1 FUNCTION

validateRules

=head1 DESCRIPTION

validateRules used method of reasoning called "forward chaining"
Forward chaining starts with the available data and uses inference rules to extract more data (from Interface_rule fuction) until a goal is reached (Conclusion.pm). An inferenceEngine.pm using forward chaining searches the inference rules until it finds one where the antecedent (If clause) is known to be true. When such a rule is found, the engine can conclude, or infer, the consequent (Then clause), resulting in the addition of new information to its data.

=head1 BUGS

varible $+<negation>, in some case avoid to match the negation '!'.

=cut

sub validateRules(){
    ($atom_check)=shift;
    print "hola $atom_check\n";
    my $row=0;
    my $status=IMPLICATION_ATOM;
    my $conjuntion_arg=0;
    foreach my $check_rule (@contentRules){
    #print "------------------------------------------>$check_rule\n";
    $status=IMPLICATION_ATOM;
    #print "###################$row\n";
        if($check_rule =~ /(${atom_match})\s?\)$/){
            if ($1 eq $atom_check){
                ($inc)=&AddConclusion($atom_check);
                #print "---------------------$atom_check\n";
                $row++ and next unless $inc ne 1;
            }
        }
        while(my ($opt,$pattern)= each %implication_atom){
            local $count=0;
            if($check_rule =~ /$pattern(${atom_check})|(?<negation>(?:\!|))(${atom_check})$pattern/){
                if(defined($+{negation}) and ($+{negation} eq "!")){
                    next;
                }
                foreach my $preposition (&get_groups_matching($check_rule)){
                    if(&exact_match_atom($atom_check,$preposition)){
                        $conjuntion_arg=$count;
                    }
                    $count++;
                }
                push @{$AoA[$row]->[$conjuntion_arg]},$atom_check;
                &VerifyConclusion(\@AoA,$row);
                $status=CONJUNTION_ATOM;
                $row++;
            }
        }
        next if $status eq CONJUNTION_ATOM;
        if(&exact_match_atom($atom_check,$check_rule)){
            push @{$AoA[$row]},$atom_check;
            &VerifyConclusion(\@AoA,$row);
        }
        $row++;
        $status=IMPLICATION_ATOM;
    }
}

=head1 FUNCTION

validateHypothesis

=head1 DESCRIPTION

validateHypothesis used method of reasoning called "backward chaining"
Backward chaining starts with a list of goals ($IntConclusionHash and $FinalConclusions) and works backwards from the  consequent to the antecedent to see if there is data available that will support any of these consequents. An inference engine using backward chaining would search the inference rules until it finds one which has a consequent (Then clause) that matches a desired goal. If the antecedent (If clause) of that rule is not known to be true, then it is added to the list of goals (in order for one's goal to be confirmed one must also provide data that confirms this new rule).

=head1 BUGS

Not found

=cut

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
sub get_AoA{return \@AoA;}
1;
