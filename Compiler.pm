#!/bin/perl 
###########################################
#
#Information will be process here
#
#############################################

use warnings;

package Compiler;

use Conclusion;
use InferenceMotor;
use Data::Dumper;
use feature qw/switch/;
our @EXPORT = qw(
		%Data
		@contentRules
		ReadData
		CompileRules
		GetContentRules
		ModifyRules
);
our @ISA = qw(Exporter);

our @contentRules;
my %Data;
my $id='A';
my @SymbolAssambly;
my $curlybrackets;
my @ValuesAssambly;
my $aux=undef;
my $nextrule=0;
my ($state)=1;
my ($state1)=1;
my $implication=undef;
my $equivalence=undef;
my $num=0;

sub ReadData(){
	open(FH, '< KnowlegdeBase.txt');
	my (@content)=<FH>;
	foreach my $line (@content){
	    if($line =~ m/\/\//){
		next;
	    }elsif($line =~ /^\s/ ){
		 next;
	    }
		$Data{$id}= $line;
		print "$id -> $Data{$id}"; 
		$id++;
		$num++;
	}
	print "$num\n";
	return \%Data;
}

sub CompileRules(){
    print "\t***Verify that Inference rules****\n\n";
    my $FileHandle= do{if( defined shift){'NewRulesBase.txt'}else{'RulesBase.txt'} };
    open my $FH,  '<',  $FileHandle or die "Can't read old file: $!";
    @contentRules=<$FH>;
    foreach my $line (@contentRules){
	my @test= $line =~ /./sg;
	foreach (@test){
	    given($_){
		print "$_";
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
    if($curlybrackets ne 0){
	print "it's missing a curly brace ')' ";
	print "Please verify and fix it!!\n";
	exit -1;
    }
}
print "\n\t***Inference Rules are correct***\n";
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
1;
