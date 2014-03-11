#!/bin/perl

=head Lincense
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

=cut
###########################################
#
#Rule-based systems can be used to perform lexical analysis to compile or interpret computer programs, or in natural language processing,
#So this module will have the task to process all rules and  make readable in RegExpert-System
#
#############################################

use warnings;

package Compiler;

use Conclusion;
use InferenceMotor;
use Data::Dumper;
use Tree_Builder;
use Common_definitions;

use base 'Exporter';
use feature 'switch';

our @EXPORT = qw(
		@ArrayRules
		@ArrayHypotesis
		%AntecedentValues
		%IntConclusionHash
		%FinalConclusions
		@contentRules
		ReadData
		CompileRules
		GetConclusionHash
		GetFinalConlusion
		GetArrayRules
		ModifyRules
		verifyIntermediateRules
		ValidatelastElementConclusion
);
our @ISA = qw(Exporter);

our @contentRules;
our @ArrayRules=[];
our @ArrayHypotesis;
my @AuxArrayHypo;
our %AntecedentValues;
our %IntConclusionHash;
our %FinalConclusions;
my @SymbolAssambly;
my $curlybrackets;
my $aux=undef;
my $nextrule=0;
my ($state)=1;
my ($state1)=1;
my $implication=undef;
my $equivalence=undef;
my $num=0;

sub ReadData(){
	open(FH, '< OrigKnowlegdeBase.txt');
	my (@content)=<FH>;
	foreach my $line (@content){
	    next if($line =~ m/(^\/\/|^\s)/);
	    $line =~ /\-/;
	    my ($id_element)=trim($`);
	    local $data=delete_new_line($');
	    if($id_element =~ /^\.(\w+)/){
		$IntConclusionHash{$1}=$data;
	    }elsif($id_element =~ /^\*(\w+)/ ){
		$FinalConclusions{$1}=$data;
	    }else{
		$AntecedentValues{$id_element}= $data;
	    }
	}
	close(FH);
	return (\%AntecedentValues,\%IntConclusionHash);
}
sub GetConclusionHash{
    return %IntConclusionHash;
}
sub GetFinalConlusion{
    return %FinalConclusions;
}


sub CompileRules(){
    print "\t***Verify that Inference rules****\n\n";
    my $FileHandle= do{if( defined shift){'NewRulesBase.txt'}else{'RulesBase.txt'} };
    open my $FH,  '<',  $FileHandle or die "Can't read old file: $!";
    @contentRules=<$FH>;
    &Build_tree(2,@contentRules);
    my $row=0;
    foreach my $line (@contentRules){
	my @test= $line =~ /./sg;
	my $cindex=0;
	#print Dumper(@ArrayRules);
	#sleep 2;
	foreach (@test){
	    print "$_";
	    given($_){
		when(/(\w)/){
		   if($test[$cindex-1] =~ /\w/){
			$cindex++;
			next;
		    }elsif($test[$cindex-1]=~ /\!/){
			my ($tmpValue)=$test[$cindex-1].$_;
			$cindex++;
			push @{$ArrayRules[$row]}, $tmpValue;
		    }elsif($test[$cindex+1]  =~ /([\(|\&|\||\(|\)|\-|\s])/){
			push @{$ArrayRules[$row]}, $_;
			 $cindex++;
		    }elsif($test[$cindex+1]  =~ /(\w)/){
			my ($tmpValue)=$_.$test[$cindex+1];
			#print "TEST: $tmpValue\n";
			$cindex++;
			push @{$ArrayRules[$row]}, $tmpValue;
		    }
		}
		$cindex++;
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
		}
		when( /(\(|\)|\&|\||\!|\s)/){
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
    $row++;
    if($curlybrackets ne 0){
	print "it's missing a curly brace ')' ";
	print "Please verify and fix it!!\n";
	exit -1;
    }
}
print Dumper(@ArrayRules);
print "\n\t***Inference Rules are correct***\n";
}
sub GetArrayRules (){
    return @ArrayRules;
}
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
	if (exists $IntConclusionHash{$Idtemp}){
	    #print "TEST 2 : ".Dumper($IntConclusionHash{$Idtemp});
	    &ValidatelastElementConclusion('AddRule',$Idtemp);
	    push @AuxArrayHypo,$Idtemp;
	}
    }
}
sub ValidatelastElementConclusion{
    my $FlagCondition=shift;
    my $ExpectedConsequent=shift;
    my $row=0;
    foreach(@ArrayRules){
	my $lastelement=do {if(defined($_)){pop $_}else{$row++ ;next;}};
	$aux=$lastelement;
	push $_,$lastelement;
	if ($aux eq $ExpectedConsequent){
	    given ($FlagCondition){
		when(/AddRule/){
		    &verifyIntermediateRules(\$ArrayRules[$row],$aux);
		    push @ArrayHypotesis,\$ArrayRules[$row];

		}when(/RemoveRule/){
		    delete $ArrayRules[$row];
		}
	    }
	}
	$row++;
    }
    return @ArrayAux if ($FlagCondition eq 'AddRule');
}
1;
