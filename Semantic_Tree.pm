#!/bin/perl
############################################
##
##Information will be process here
##
##############################################

use warnings;

package Semantic_Tree;

use Compiler;
use InferenceMotor;
use Data::Dumper;
use Tree::Binary;
use Tree::Simple;

use feature 'switch';
our @EXPORT = qw(
    analyze_Semantic_tree
);

our @ISA = qw(Exporter);
my @Tree_list=[];
my $id='A';
my $idtree='A';
my $position=0;
my $root;
my @sub_tree;
my %Semantic_Rule;
my $sibling_position;
my $left_tree_finished=0;

sub analyze_Semantic_tree () {
    my @compile_rules=@_;
    my $regex = qr/
    (                   # start of bracket 1
    \(                  # match an opening angle bracket
	(?:
            [^()]++     # one or more non angle brackets, non backtracking
            |
            (?1)        # recurse to bracket 1
        )*
    \)                  # match a closing angle bracket
    )                   # end of bracket 1
    /x;
    $" = "\n\t";

	foreach(@compile_rules){
		my (@rule_in_process)=shift;
		my $num=0;
		while( @rule_in_process ){
        	my $rule = shift @rule_in_process;
			my ($conector);
	        my @groups = $rule =~ m/$regex/g;
			#print "- $`- \n" if defined($`);
			print "********************************\n";
		    print "Groups: ".(Dumper(@groups));
			#print "WHAT: ".Dumper(%Semantic_Rule)."\n";
			print "********************************\n";
			next if scalar @groups eq 0;
			if(defined($`) and $` ne "" ){
				print "conec:$`\n";
				$` =~ /([\!|\&|\||\-\>])(\s)?$/;
				$conector= "->" if($1 eq '>');
				if (!$root){
						print "test1 - $conector -\n";
						$root = Tree::Simple->new([$conector,$idtree,$Semantic_Rule{$idtree}], Tree::Simple->ROOT);
	#					$root->setContent($Semantic_Rule{$idtree});
#						print Dumper($root);
						$idtree++;
						undef $conector;
				}else{
						print "test2:   $conector ".scalar(@groups)."---->position : $position\n";
						if( $position < 1 and defined ($conector) and not $left_tree_finished){
							print "--------->0\n";
							$sub_tree[$position]=Tree::Simple->new([$conector,$idtree,$Semantic_Rule{$idtree}],$root);
						}elsif($conector ne "" and !$left_tree_finished	){
							print "--------->1\n";
							$sub_tree[$position]=Tree::Simple->new([$conector,$idtree,$Semantic_Rule{$idtree}],$sub_tree[$position-1]);
						}elsif($left_tree_finished){
						    print "cool bro\n";
							 $sub_tree[$position]->insertSibling(Tree::Simple->new("pooooooooooooolllllllllllllll"));
							     print "OKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK\n";
							     sleep 8;
						}else{
							print "---------->2\n";
							$sub_tree[$position]=Tree::Simple->new([$idtree,$Semantic_Rule{$idtree}],$sub_tree[$position-1]);
						}
						$idtree++;
						if(scalar @groups gt 0){
							$sub_tree[$position]->addSibling(Tree::Simple->new([$idtree,$Semantic_Rule{$idtree}]));
							$idtree++;
							$sibling_position=$position;
							print "Sibling : $sibling_position";
							$position++;
							print Dumper($root);
							sleep 2;
						}
				}
			}
			if(defined($`) and $` =~ /^((\s)?(\w))/ ){
				$sub_tree[$position]=Tree::Simple->new([$1],$sub_tree[$position-1]);
				#print Dumper($root);
			}
			print "pass here";
			my $last_rule=$groups[0] if defined($groups[0]);
			print "pass here $last_rule\n" if defined($groups[0]);
			if ($last_rule =~ /^\((\s)?(\w)(\s)?.(.)?(\s)?(\w)(\s)?\)$/){
				$sub_tree[$position]=Tree::Simple->new([$conector,$idtree,$last_rule],$sub_tree[$position-1]);
				$position++;
				$last_rule =~ /(\w).*(\w)/;
				$sub_tree[$position]=Tree::Simple->new([$1],$sub_tree[$position-1]);
				$sub_tree[$position]->addSibling(Tree::Simple->new([$2]));
				#print Dumper($root);
				$position=$sibling_position;
				$left_tree_finished=1;
				sleep 2;
			}
			foreach(@groups){
				$Semantic_Rule{$id}=$_;
				$id++
			}
			print "--------------------------------\n";
			#print Dumper(@groups);
			#print "Found:\n\t@groups\n\n" if @groups;
			sleep 1;
	        unshift @rule_in_process, map { s/^\(//; s/\)$//; $_ } @groups;
	   }
	}
}
1;
