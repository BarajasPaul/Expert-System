#!/bin/perl

=head1 License
/* -*- Mode: Perl */
/*
 * Conclusion.pm
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

Conclusion.pm

=head1 VERSION

VERSION 0.001

=head1 DESCRIPTION

Conclusion.pm explain to a user the chain of reasoning used to arrive at a particular conclusion by tracing back over the firing of rules that resulted in the assertion.

=cut

use warnings;
use strict;
no warnings 'experimental::smartmatch';
package Conclusion;

use Data::Dumper;

use InferenceMotor qw/ConlusionBC/;
use Compiler;
use Common_definitions;

use base 'Exporter';

use feature qw/switch/;
our @EXPORT = qw(
    AddConclusion
    AddFinalConclusion
    Conclusion
    VerifyConclusion
    CheckConcluded
    @AntecendentsBased
    Concluded
    validate_conjuction
);
our @ISA = qw(Exporter);

my @Consecuents;
my @Concluded;
my $RuleTest=1;
our @AntecendentsBased;

=head1 FUNCTION

AddConclusion

=head1 DESCRIPTION

Add Conclusion check if actual consequent is part of conclusion elements, else just skip this element.

=head1 BUGS

Not found

=cut

sub AddConclusion(){
    print "Test add Conclusion\n";
    if (exists $IntConclusionHash{$_}){
        return 1;
    }else{
        $IntConclusionHash{$_}=$AntecedentValues{$_};
        return 1;
    }
}

=head1 FUNCTION

AddFinalConclusion

=head1 DESCRIPTION

AddFinalConclusion is used by function &validateHypothesis from InferenceMotor module,hence it will assign and validate the inference rule that will be part of the hypothesis to conclude.

=head1 BUGS

Not found

=cut

sub AddFinalConclusion(){
    my $self=shift;
    print "Test add Final Conclusion\n";
    if (exists $FinalConclusions{$self}){
        last;
    }else{
        $FinalConclusions{$self}=$IntConclusionHash{$self};
    }
}


=head1 FUNCTION

Conclusion

=head1 DESCRIPTION

Conclusion method provide justification and explanation to the conclusion obtained if 
latter could be.

=head1 BUGS

Not found

=cut

sub Conclusion(){
    my $atom;
    my $i=0;
    my ($ConclusionValue,$rule)=@_;

   # print Dumper(@AntecendentsBased);
    print "--------$ConclusionValue\n";
    my @atoms_rule=&get_atoms_rule($rule);
    if(exists $FinalConclusions{$ConclusionValue}){
        print "Conclusion obtanied by the following knowledge: \n ";
        foreach (@AntecendentsBased){
            sleep 1;
        if (exists $IntConclusionHash{$_}){
                print  " -> | ".$IntConclusionHash{$_}." -> ";
                next;
            }elsif($_ =~ /(?:\!)(?<element>${atom_match})/){
                print  "| not ".$AntecedentValues{$+{element}}." -> ";
                sleep 1;
            }else{
                print  "| ".$AntecedentValues{$_}." -> ";
            }
        }
        print "\nConclusion: $FinalConclusions{$ConclusionValue}\n";
        print "Actually, obtained a Final Conclusion\n";
        exit -1;
    }elsif(exists $IntConclusionHash{$ConclusionValue}){
        print "Conclusion obtanied by the following knowledge: \n ";
        foreach(@atoms_rule){
            if($_ =~ /(?:\!)(?<element>${atom_match})/){
                print  "| not ".$AntecedentValues{$+{element}}." -> ";
            }else{
                print  " -> | ".$AntecedentValues{$_}." -> ";
            }
        }
        push @Concluded,$ConclusionValue;
        print "\nConclusion: $IntConclusionHash{$ConclusionValue}\n";
        print "There's more Information, Would You like to continue (y/n)\n";
        chomp (my $entry_Value = <STDIN>);
        if ($entry_Value =~ /y*/i){
            return 0;
            next;
        }else{
            exit -1;
        }
    }else{
        return 1;
    }

}

=head1 FUNCTION

VerifyConclusion

=head1 DESCRIPTION

VerifyConclusion evaluate @ArrayRules and @actualRule to looks at possible conclusions and works backward to see if they might be true.

=head1 BUGS

Not found

=cut

sub VerifyConclusion(){
    my @actualRule=shift;
    my $NumRule=shift;
    my $flag=0;
    my $validation_conclusion=0;
    my $elements_array_rule=0;
    my @stack=undef;
    my $tmpConclusion= do {if (defined $ArrayRules[$NumRule]){pop $ArrayRules[$NumRule]}else{next}};
    #print "----------------------------->$tmpConclusion\n";
    print Dumper($actualRule[0]->[$NumRule])." ~~ ".Dumper($ArrayRules[$NumRule]);
    foreach my $values_to_concluded (@{$ArrayRules[$NumRule]}){
        my $atom_concluded=0;
        #print "_------------>$values_to_concluded\n";
        if(ref($values_to_concluded) eq "ARRAY"){
             if(defined(@{$Array_of_Stacks[$NumRule]})){
                $atom_concluded=&validate_conjuction($NumRule,$values_to_concluded,$actualRule[0][$NumRule]);
                print "--------------------------------------------------_>$atom_concluded\n";
                sleep 1;
                $validation_conclusion++ if($atom_concluded eq 2);
            }
            unless($atom_concluded){
                $stack[$elements_array_rule]=&new_stack($values_to_concluded->[0],$values_to_concluded->[1]);
                push @{$Array_of_Stacks[$NumRule]},@stack;
                $validation_conclusion++;
            }
        }elsif($values_to_concluded ~~ $actualRule[0]->[$NumRule]){
            $validation_conclusion++;
        }
        $elements_array_rule++;
       # print "Stack size --> ".Dumper(@Array_of_Stacks);
        #sleep 1;
        print "----------------'".scalar(@{$ArrayRules[$NumRule]})."'-------------'$validation_conclusion'---------\n";
        #sleep 1;
        $flag=1 if (scalar(@{$ArrayRules[$NumRule]}) eq $validation_conclusion);
    }
    if($flag){
        $RuleTest=&Conclusion($tmpConclusion,\$actualRule[0]->[$NumRule]);
        $flag=0;
    }
    my $auxConclusion=$tmpConclusion;
    push $ArrayRules[$NumRule],$auxConclusion;
    unless($RuleTest){
        $RuleTest=1;
        print "here2\n";
        &ValidatelastElementConclusion(REMOVE_RULE,$tmpConclusion,\$NumRule);
    }
}

=head1 FUNCTION

CheckConcluded

=head1 DESCRIPTION

CheckConcluded check if actual atom was concluded in the knowledge base.

=head1 BUGS

not found

=cut

sub CheckConcluded(){
    my ($Validate_Atom)=shift;
    foreach (&InferenceMotor::get_AoA){
        grep {
            foreach my $consecuent (@{$_}){
                next unless(defined($consecuent));
                map {
                    my $tmp=$_;
                    if (ref($tmp) eq "ARRAY"){
                        map {if($_ =~ /\b${Validate_Atom}\b/){return 1;}}$tmp;
                    }else{
                        if($tmp =~ /\b${Validate_Atom}\b/){
                            return 1;
                        }
                    }
                }@${consecuent};
            }
        } $_;
    }
    print "no match\n";
    return 0;
}


=head1 FUNCTION

Concluded

=head1 DESCRIPTION

Concluded check if actual atom was concluded in the knowledge base.

=head1 BUGS

not found

=cut


sub Concluded{
    return 1 if($_[0] ~~ @AntecendentsBased);
    return 0;
}


=head1 FUNCTION

validate_conjuction

=head1 DESCRIPTION

validate_conjuction just verify stack from the actual rule.

=head1 BUGS

not found

=cut

sub validate_conjuction{
    my $numrule=shift;
    my $conjuction_element=shift;
    my $rule_inference=shift;
    #print "$conjuction_element->[0] or $conjuction_element->[1] ~~ ".Dumper($rule_inference);
    if(($conjuction_element->[0]  ~~ $rule_inference) or ($conjuction_element->[1] ~~ $rule_inference)){
        foreach my $stack_element(@{$Array_of_Stacks[$numrule]}){
             return 2 if($stack_element->{first_stack_pointer} eq ($conjuction_element->[0] or $conjuction_element->[1]));
             return 2 if($stack_element->{second_stack_pointer} eq ($conjuction_element->[0] or $conjuction_element->[1]));
        }
        return 0;
    }
    return 1;
}

1;
