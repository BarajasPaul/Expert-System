#!/bin/perl

=head1 Lincense
/* -*- Mode: Perl */
/*
 * Compiler.pl
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

Compiler.pm - Kernel Inference

=head1 VERSION

VERSION 0.001

=head1 DESCRIPTION

Rule-based systems can be used to perform lexical analysis to compile or interpret computer programs, or in natural language processing,
So this module will have the task to process all rules and  make readable in RegExpert-System

=cut

use warnings;
no warnings 'experimental::smartmatch';
package Compiler;
use Exporter;

use Conclusion;
use InferenceMotor;
use Data::Dumper;
use Tree_Builder;
use Common_definitions;
use feature 'switch';

our @EXPORT = qw(
            @ArrayHypotesis
            @contentRules
            %AntecedentValues
            ReadData
            CompileRules
            verifyIntermediateRules
            ValidatelastElementConclusion
            get_antecedents
            get_conclusion
);
our @ISA = qw(Exporter);

our @contentRules;
my $aux_regex="skip";
our @ArrayHypotesis;
my @AuxArrayHypo;
our %AntecedentValues;
my $aux=undef;
my $nextrule=0;
my ($state)=1;
my ($state1)=1;
my $implication=undef;
my $equivalence=undef;

=head1 FUNCTION

ReadData

=head1 DESCRIPTION

ReadData is parsing of the knowledge base to convert in a data structure which is suitable for processing in Reg-Expert System.

=head1 BUGS

Not found

=cut

sub ReadData(){
    open(FH, '< OrigKnowlegdeBase.txt');
    my (@content)=<FH>;
    foreach my $line (@content){
        next if($line =~ m/(^\/\/|^\s)/);
        $line =~ /\-/;
        ($id_element)=trim($`);
        local $data=delete_new_line($');
        $AntecedentValues{$id_element}= $data;
    }
    close(FH);
    return (\%AntecedentValues);
}

=head1 FUNCTION

CompileRules

=head1 DESCRIPTION

CompileRules is  used as a way to store and manipulate knowledge to interpret information in a useful way.where @ArrayRules saves all atoms in each tree by calling Tree_Builder and in a Dynamic likening Array that is using by the inference engine.

=head1 BUGS

Not found

=cut

sub CompileRules(){
    print "\t***Verify that Inference rules****\n\n";

    my @SymbolAssambly;
    my $curlybrackets;
    my $FileHandle= do{if( defined shift){'NewRulesBase.txt'}else{'RulesBase.txt'} };
    open my $FH,  '<',  $FileHandle or die "Can't read old file: $!";
    @contentRules=<$FH>;
    &Build_tree(2,@contentRules);
    my $row=0;

    foreach my $line (@contentRules){
        if($line =~ &analyze_balanced_parenthesis()){
            print "$& is a balanced parenthesis\n";
        }else{
            print "$line Does not match, check your rules,please.\n";
        }
        $line =~
            /(?(DEFINE)
                (?<atom> \!?[\w+\d+]+)
                (?<not_atom> \W[^\w\d!]+)
                (?<conclusion> \-\>.?(?&atom))
            )
            (?<rule>
                (?<antecendent>(?&atom))
                    #(?{print " $aux_regex---->'$+{antecendent}'\n"})
                    (?{ &check_data(trim($aux_regex),$row,$+{antecendent})})
                (?<structure>(?&not_atom))
                    (?{ $aux_regex=$+{structure} if defined($+{structure})})
                (?<rule> (?R)?)
            )/x;
        $row++;
        my @test= $line =~ /./sg;
	foreach (@test){
	    given($_){
		when(/\-/ or /\>/){
		    if ($_ =~ /\-/){
			if(defined $aux){
			    $aux=$aux.$_;
			    $state=0;
			}else{
			    $aux=$_;
			    $state=0;
			}
		    }elsif($state and /\>/){
			print "\n\nThere is a mistake, with your Inference Rule, maybe you're missing the follwing operator '-'\n ";
			print "Please verify and fix it!!\n";
			exit -1;
		    }else{
			$implication=$aux.$_;
			push @SymbolAssambly,$implication;
			$state=1;
			$aux="";
		    }
		}
		when(/\</){
		    $aux=$_;
		}when( /(\(|\)|\&|\!|\s)/){
		if (!$state){
		    print "\n\nThere is a mistake with your Inference Rule, maybe you were checking for a \"equivalence\" or \"implication\" and you missing the following operator '>'\n ";
		    print "Please verify and fix it!!\n";
		    exit -1;
		}
		if($_ =~ /\(/){
		    $curlybrackets++;
		}
		if($_ =~ /\)/){
		    if(!$curlybrackets){
			print "it's missing a curly brace '(' ";
			print "Please verify and fix it!!\n";
			exit -1;
		    }
		    $curlybrackets--;
		}
		push @SymbolAssambly,$_;
	    }
	}
	close FH;
    }
    if($curlybrackets ne 0){
	print "it's missing a curly brace ')' ";
	print "Please verify and fix it!!\n";
	exit -1;
    }
}
print "\n\t***Inference Rules are correct***\n";
}

=head1 FUNCTION

ModifyRules

=head1 DESCRIPTION

ModifyRules has purpose to ask to the user if it want to modify the expected rule from the Rule Base.

=head1 BUGS

It's not using cause is not the purpose of this project.

=cut

sub ModifyRules(){
	print "Would you like modify the rule?";
	chomp ($answer = <STDIN>);
	if ($answer=~ /yes/i){
	    my $file="RulesBase.txt";
	    my $newfile="NewRulesBase.txt";
	    print "Write the new Rule\n";
	    my ($rulechange)=undef;
	    chomp ($rulechange = <STDIN>);
	    my $rule=$contentRules[$nextrule];
	    print "ACTUAL: $rule";

	    open my $in,  '<',  $file or die "Can't read old file: $!";
	    open my $out, '>', $newfile or die "Can't write new file: $!";

	    while(<$in>){
		if($_ eq $contentRules[$nextrule] ){
		    print $out $rulechange."\n";
		}else{
		    print $out $_;
		}
	    }
	    close $out;
	    @ContentRules= map {
				if($_ eq $contentRules[$nextrule] ){
				    $_=$rulechange;
				}else{
				    $_;
				}
				}@contentRules;
	    print Dumper(\@ContentRules);
	    &CompileRules($newfile);

	}else{
		return 0;
	}
}

=head1 FUNCTION

verifyIntermediateRules

=head1 DESCRIPTION

verifyIntermediateRules is using by &validateHypothesis method to check intermediate rules that can be added to the actual hypothesis.

=head1 BUGS

Not Found

=cut

sub verifyIntermediateRules(){
    my (@AuxArray)=@{$_};
    my ($AuxConsequent)=$_[1];
    #print "TEST 1 : ".Dumper($AuxConsequent);
    #print "TEST ARRAY : ".Dumper(@AuxArray);
    #sleep 2;
    foreach(@AuxArray){
	my $Idtemp=$_;
	#print "-$_-\n";
	next if undef $_;
	next if ($Idtemp eq $AuxConsequent);
	next if ($Idtemp ~~ @AuxArrayHypo);
	if (exists $conclusion{$Idtemp}){
	    #print "TEST 2 : ".Dumper($conclusion{$Idtemp});
	    &ValidatelastElementConclusion(ADD_RULE,$Idtemp);
	    push @AuxArrayHypo,$Idtemp;
	}
    }
}

=head1 FUNCTION

ValidatelastElementConclusion

=head1 DESCRIPTION

ValidatelastElementConclusion just check last element that was concluded.

=head1 BUGS

Not Found

=cut

sub ValidatelastElementConclusion{
    ($FlagCondition,$ExpectedConsequent,$numrule)=@_;
        given ($FlagCondition){
            when(/AddRule/){
                $numrule=0;
                foreach(@ArrayRules){
                    my $lastelement=do {if(defined($_)){pop $_}else{$row++ ;next;}};
                    my $aux=$lastelement;
                    push $_,$lastelement;
                    if ($aux eq $ExpectedConsequent){
                        &verifyIntermediateRules($ArrayRules[$numrule],$aux);
                        push @ArrayHypotesis,\$ArrayRules[$numrule];
                    }
                    $numrule++;
                }
            }when(/RemoveRule/){
                delete $ArrayRules[$numrule];
            }
        }
    return @ArrayAux if ($FlagCondition eq ADD_RULE);
}
sub get_antecedents{
    return \%AntecedentValues;
}

1;
