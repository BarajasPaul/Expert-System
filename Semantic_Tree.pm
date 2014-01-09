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
my @sub_tree=([[],[]],[[],[]]);
my %Semantic_Rule;
my $tree=(\@sub_tree,\@Tree_list);
my $sibling_position;
my $first_child=0;
my $left_tree_finished=0;
my $num=0;

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
		my $id_sibling;
		while( @rule_in_process ){

			my $rule = shift @rule_in_process;
			my ($conector);
	        my @groups = $rule =~ m/$regex/g;

			next if scalar @groups eq 0;
			foreach(@groups){
				$Semantic_Rule{$id}=$_;
				$id++
			}


			print "********************************\n";
		    print "Groups: ".(Dumper(@groups));
			#print "WHAT: ".Dumper(%Semantic_Rule)."\n";
			print "********************************\n";

			if(defined($`) and $` ne "" and  $` ne " "){
				print "conec: '$`'\n";
				$` =~ /([\!|\&|\||\-\>])(\s)?$/;
				$conector= "->" if($1 eq '>');

				if (!$root){
						print "test1 - $conector -\n";
						$root = Tree::Simple->new([$conector,$idtree,$Semantic_Rule{$idtree}], Tree::Simple->ROOT);
						$idtree++;
						undef $conector;
				}else{
						print "test2: $conector ".scalar(@groups)."----> position : $position\n";

						if( $num eq 0 and defined ($conector) ){
							print "--------->0\n";
							$sub_tree[$position]=Tree::Simple->new([$conector,$idtree,$Semantic_Rule{$idtree}],$root);
							$first_child=$position;
							$position++;
							$idtree++;
						}elsif($conector ne "" and !$left_tree_finished	){
							print "--------->1\n";
							$sub_tree[$first_child][$num]=Tree::Simple->new([$conector,$idtree,$Semantic_Rule{$idtree}],$sub_tree[$first_child]);
							$idtree++;

						}elsif($left_tree_finished and $num eq 1){
							 $sub_tree[$sibling_position]->setNodeValue([$conector,$id_sibling,$Semantic_Rule{$id_sibling}]);

						}else{
							print "---------->2\n";
							$sub_tree[$position]=Tree::Simple->new([$idtree,$Semantic_Rule{$idtree}],$sub_tree[$position-1]);
							$idtree++;
						}

						if(scalar(@groups) gt 0){
							given($num){
								when ($_ eq 0){
									$sub_tree[$position]=Tree::Simple->new([$idtree,$Semantic_Rule{$idtree}],$root);
									$sibling_position=$position;
									$id_sibling=$idtree;
									$position=0;
									$num++;
									$idtree++;
								}
							}
							if($left_tree_finished){
								$tree[$sibling_position]->[$position] =Tree::Simple->new([$idtree,$Semantic_Rule{$idtree}],$sub_tree[$sibling_position]);
								$idtree++;
								$position++;
								$tree[$sibling_position]->[$position] =Tree::Simple->new([$idtree,$Semantic_Rule{$idtree}],$sub_tree[$sibling_position]);
								$idtree++;
								$position++;
								}
							print Dumper($root);
							print "/////////////////////////////////////////\n";
							sleep 1;

						}
				}
			}
			print "'$''\n";
			if(defined($') and $' =~ /^(\s)?.(.)?(\s)?(\w)/ ){
				 print "---------------------------> '$''\n";
				if(!$left_tree_finished){
                	$tree[$first_child]->[$position]=Tree::Simple->new([$2],$sub_tree[$first_child]);
                	$position++;
            	}else{
                	$tree[$sibling_position]->[$position]=Tree::Simple->new([$4],$sub_tree[$sibling_position]);
                	$position++;
					print Dumper($root);
                	print "/////////////TEST INVALID////////////\n";
					sleep 9;
					}

				}

			if(defined($`) and $` =~ /^((\s)?(\w))/ ){
				if(!$left_tree_finished){
				 	$tree[$first_child]->[$position]=Tree::Simple->new([$1],$sub_tree[$first_child]);
					$position++;
				}else{
					$tree[$sibling_position]->[$position]=Tree::Simple->new([$1],$sub_tree[$sibling_position-2]);
					$position++;

					print "/////////////TEST INVALID////////////\n";
				}
			}
			my $last_rule=$groups[0] if defined($groups[0]);
			 print "'$last_rule'\n";
			if ($last_rule =~ /^\((\s)?(\w)(\s)?.(.)?(\s)?(\w)(\s)?\)$/){
				$last_rule =~ /(\w).*(\w)/;
				if(!$left_tree_finished){
					$tree[$first_child]->[$position]=Tree::Simple->new([$conector,$idtree,$last_rule],$sub_tree[$first_child]);
					$position++;
					$tree[$first_child]->[$position]=Tree::Simple->new([$1],$tree[$first_child]->[$position-1]);
					$tree[$first_child]->[$position]->addSibling(Tree::Simple->new([$2]));
					#print Dumper($root);
					#$position=$sibling_position;
					$left_tree_finished=1;
					$idtree++;
				}else{
					$tree[$sibling_position]->[$position]=Tree::Simple->new([$1],$tree[$sibling_position]->[$position-2]);
					$tree[$sibling_position]->[$position]->addSibling(Tree::Simple->new([$2]));
					print Dumper(@sub_tree);
					sleep 2;

				}
			}
			print "--------------------------------\n";
			#print Dumper(@groups);
			#print "Found:\n\t@groups\n\n" if @groups;
			sleep 1;
	        unshift @rule_in_process, map { s/^\(//; s/\)$//; $_ } @groups;
	   }
	}
}

sub evaluate_tree( ) {
	my ($left,$right,$symbol)=@_;
	given($symbol){
		when($_ eq '&'){
			return 1 if($left and $right);
		}when($_ eq '|'){
			return 1 if($left or $right);
		}when($_ eq '!'){
			return 1 if(!$left or !$right);
		}when($_ eq '->'){
			return 1 if(!$left or $right);
		}
	}
}
1;
