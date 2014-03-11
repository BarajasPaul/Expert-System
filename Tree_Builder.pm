#!/bin/perl

=head Lincense
/* -*- Mode: Perl */
/*
 * Tree_Builder.pm
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

############################################
##
##Information will be process here
##
##############################################

use warnings;

package Tree_Builder;

use Compiler;
use InferenceMotor;
use Data::Dumper;
use Tree::Simple;
use Tree_Logical;
use Common_definitions;

use feature 'switch';
use base 'Exporter';

our @EXPORT = qw(
    Build_tree
    check_root
    validate_operator_symbol
    Search_Node
    validate_tautologic
    trim
    verifiy_tautology
    delete_tree
    reset
);

our @ISA = qw(Exporter);

my @propsitional_variables;
my $id='A';
my $idtree='A';
my $position=1;
my $root;
my @subtree_position;
my %Semantic_Rule;
my $init_root=0;
my $Sastifactible=0;
my $new=0;
my $operator_regex= qr/([\&|\||\-\>|\=])/;


sub Build_tree () {
    my ($status,@compile_rules)=@_;
    if ($status eq 1){
	$init_root=0;
	$id='A';
	$idtree='A';
	$new=1;
	$position=1;
	undef(%Semantic_Rule);
    }
    my $regex = qr/
    ((?:\!)?            # start of bracket 1
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
    foreach (@compile_rules){
	my @rule_in_process=$_;
	while( @rule_in_process ){
	    my $rule = shift @rule_in_process;
	    my (@test_groups)= $rule =~ m/$regex/g;
	    my @groups=&Tree_Logical::check_logical_equivalence($rule,@test_groups);
	    #print "******************Groups: \n".(Dumper(@groups));
	    #print $rule."\n";
	    #print "**********************************************\n";
	    foreach(@groups){
		$Semantic_Rule{$id}=$_;
		$id++
	    }
	    given(@groups){
		when(scalar(@groups) eq 0){
		    my $last_rule="($rule)";
		    if($last_rule =~ /^\((\s)?((\!)?(\w)(\w)?)(\s)?.(.)?(\s)?((\!)?(\w)(\w)?)(\s)?\)$/){
			$rule =~ /(\s)?${operator_regex}(\s)?/g;
			my $first=trim($`);
			my $second=trim($');
			if($second =~ /\>(\s)?(\w(\w)?)/){
				$second=$2;
			}
			my ($branch_to_process , $actualid)=&Search_Node($last_rule);
			&validate_operator_symbol($rule,$branch_to_process,1,1);
			$subtree_position[$position]=Tree::Simple->new([$first],$branch_to_process);
			$subtree_position[$position]->addSibling(Tree::Simple->new([$second]));
			$position++;
			push @propsitional_variables, $first if($first !~ @propsitional_variables);
			push @propsitional_variables, $second if($second !~ @propsitional_variables);
		    }else{
			$rule="($rule)";
			my ($node_value)=$rule=~ /(\w(\w)?)/;
			my ($first_branch_to_process , $actual_id)=&Search_Node($rule);
			&validate_operator_symbol($last_rule,$first_branch_to_process,$actualid,1);
			my (@array);
			my (@node)=pop($first_branch_to_process->getNodeValue());
			$node_value=trim($node_value);
			push @array,$node_value;
			if ($rule=~/!/){
				push @array,'!';
			}
			delete $Semantic_Rule{$actual_id};
			$first_branch_to_process->setNodeValue([@array]);
			push @propsitional_variables, $node_value  if($node_value !~ @propsitional_variables);
		    }
		}when(scalar(@groups) eq 1){
		    if(!$init_root){
			$Semantic_Rule{$idtree}=$groups[0];
			$root = Tree::Simple->new($idtree, Tree::Simple->ROOT);
			$init_root++;
			$idtree++;
		    }else{
			$rule="($rule)";
			if($init_root eq 1){
			    my ($aux_node)=$';
			    my ($second_aux_node)=$`;
			    $subtree_position[$position]=Tree::Simple->new([$idtree],$root);
			    $init_root++;
			    $idtree++;
			    $position++;
			    if ($second_aux_node =~ /^((\s)?(\!)?(\w(\w)?))/){
				my $node_value=trim($1);
				&validate_operator_symbol($rule,$idtree,$root,$groups[0],0);
				$subtree_position[$position]=Tree::Simple->new([$node_value],$root);
				$position++;
				push @propsitional_variables, $node_value  if($node_value !~ @propsitional_variables);
				continue;
			    }
			    if($aux_node =~ /(\s)?([\!|\&|\||\-\>])((\s)?(\!)?(\w(\w)?))(\s)?/){
				#print "right\n";
				my ($node_value)=trim($3);
				&validate_operator_symbol($rule,$idtree,$root,$groups[0],1);
				$subtree_position[$position]=Tree::Simple->new([$node_value],$root);
				$position++;
				push @propsitional_variables, $node_value  if($node_value !~ @propsitional_variables);
				continue;
			    }
			}
			my ($first_branch_to_process , $actual_id)=&Search_Node($rule);
			if($` =~ /^((\s)?(\!)?(\w(\w)?))/ ){
			    my $node_value=$1;
			    $node_value=trim($node_value);
			    &validate_operator_symbol($rule,$actual_id,$first_branch_to_process,$groups[0],0);
			    $subtree_position[$position]=Tree::Simple->new([$node_value],$first_branch_to_process);
			    $position++;
			    $subtree_position[$position]=Tree::Simple->new([$idtree],$first_branch_to_process);
			    $idtree++;
			    $position++;
			    push @propsitional_variables, $node_value  if($node_value !~ @propsitional_variables);
			}
			if($' =~ /^(\s)?${operator_regex}((\s)?(\!)?(\w(\w)?))(\s)?$/){
			    my ($node_value)=$3;
			    $node_value=$4 if($node_value eq '');
			    &validate_operator_symbol($rule,$actual_id,$first_branch_to_process,$groups[0],1);
			    $node_value=trim($node_value);
			    $subtree_position[$position]=Tree::Simple->new([$node_value],$first_branch_to_process);
			    $position++;
			    $subtree_position[$position]=Tree::Simple->new([$idtree],$first_branch_to_process);
			    $idtree++;
			    $position++;
			    push @propsitional_variables, $node_value  if($node_value !~ @propsitional_variables);
			}
		    }
		}when(scalar(@groups) eq 2){
		    #print "$rule\n";
		    &check_root();
		    if($init_root eq 1){
			&validate_operator_symbol($rule,@test_groups);
			$subtree_position[$position]=Tree::Simple->new([$idtree],$root);
			$idtree++;
			$position++;
			$subtree_position[$position]=Tree::Simple->new([$idtree],$root);
			$init_root++;
			$idtree++;
			$position++;
		    }else{
			$rule="($rule)";
			my ($branch_to_process ,$actualid)=&Search_Node($rule);
			&validate_operator_symbol($Semantic_Rule{$actualid},@test_groups,$branch_to_process);
			$subtree_position[$position]=Tree::Simple->new([$idtree],$branch_to_process);
			$idtree++;
			$position++;
			$subtree_position[$position]=Tree::Simple->new([$idtree],$branch_to_process);
			$position++;
			$idtree++;
		    }
		}
	    }
	    unshift @rule_in_process, map { s/^\(//; s/\)$//; $_ } @groups;
	}
	 if($new){
	   return $root;
	}
	&validate_tautologic(%Semantic_Rule) if($ENV{SHOW_TABLES});
	&reset();
    }
}

sub check_root{
    if(!$init_root){
	print "There's a mistake with your rule!!!\n";
        exit -1;
    }
}
sub validate_operator_symbol{
    my ($check_rule,@matches_rules)=@_;
    if(defined ($matches_rules[3]) and $matches_rules[3] eq '0'){
	my ($id_search,$content_tree,$left)=@matches_rules;
	my ($leftsz)=length($left);
	my ($shortrule)=substr $check_rule,0,-$leftsz-2;
	$shortrule =~ /${operator_regex}(\s)?$/;
	$conector=$1;
	$conector= "->" if($1 eq '>');
	$conector= "->" if($1 eq '-');
	my (@NodeValue)=$content_tree->getNodeValue();
	push @NodeValue, $conector;
	$content_tree->setNodeValue([@NodeValue]);
    }elsif(defined ($matches_rules[3]) and $matches_rules[3] eq '1'){
	my ($id_search,$content_tree,$right)=@matches_rules;
	my ($rightsz)=length($right);
	my ($shortrule)=substr $check_rule,$rightsz+2;
	$shortrule =~ /${operator_regex}/;
	$conector=$1 if($1 ne "");
	$conector= "->" if($1 eq '>');
	$conector= "->" if($1 eq '-');
	my (@NodeValue)=$content_tree->getNodeValue();
	push @NodeValue, $conector;
	$content_tree->setNodeValue([@NodeValue]);
    }elsif(defined ($matches_rules[2]) and $matches_rules[2] eq '1'){
		my ($content_tree,$id)=@matches_rules;
		$check_rule=~ /${operator_regex}/;
		$conector=$1;
		$conector= "->" if($1 eq '>');
		$conector= "->" if($1 eq '-');
		my (@NodeValue)=$content_tree->getNodeValue();
		push @NodeValue, $conector;
		$content_tree->setNodeValue([@NodeValue]);
    }else{
		my ($left,$right,$content_tree)=@matches_rules;
		my $leftsz=length($left);
		my $rightsz=length($right);
		if($rightsz =~ /\!\(/g)
		{
		    $rightsz=$rightsz-2;
		}else{
		    $rightsz=$rightsz+2;
		}

		my $shortrule=substr $check_rule,$leftsz+2;
		$conector=substr $shortrule,0,-$rightsz;
		$conector=trim($conector);
		if($init_root eq 1){
		   my (@root_NodeValue)=$root->getNodeValue();
		   push @root_NodeValue, $conector;
		   $root->setNodeValue([@root_NodeValue]);
	}else{
	    my (@NodeValue)=$content_tree->getNodeValue();
	    push @NodeValue, $conector;
	    $content_tree->setNodeValue([@NodeValue]);
	}
    }
}
sub Search_Node{
	my ($rule)=shift;
	foreach my $id_rule (reverse sort keys(%Semantic_Rule)){
		if($rule eq $Semantic_Rule{$id_rule} or $rule eq $id_rule){
			if($rule eq 'A' or $Semantic_Rule{'A'} eq $rule){
				return ($root,'A');
			}
			my ($check_position)=$position-1;
			while($check_position){
			    my ($node)=$subtree_position[$check_position]->getNodeValue();
			    while(ref($node) eq 'ARRAY' ){
		   		$node=@{$node}[0];
			    }
			    unless($node){
				$node=1;
			    }
			    if($id_rule eq $node){
			    	return ($subtree_position[$check_position],$id_rule);
			    }
			$check_position--;
			}
		}
	}

}
sub validate_tautologic(){
    my ($array_position)=0;
    my (%prepositions);
    my (@result_tautologic);
    foreach (@propsitional_variables){
	my ($variable)=$_;
	if($variable =~ /\!(\w(\w)?)/g){
	    $variable=$1;
	}
	if ($array_position eq 0){
	    $prepositions{$variable}=0;
	    $array_position++;
	}else{
	    if(exists $prepositions{$variable}){
		next;
	    }else{
		$prepositions{$variable}=0;
		$array_position++;
	    }
	}
    }
    my (@array_bit)=&Logical_table($array_position);
    foreach $array_column (@array_bit){
	foreach (sort keys(%prepositions)){
	    $prepositions{$_}=shift(@$array_column);
	}
	my $result_tree=&verifiy_tautology(\%prepositions);
	push @result_tautologic,$result_tree;
	&delete_tree();
    }
    &Tautologic_Conclusion($Semantic_Rule{'A'},$Sastifactible,\%prepositions,@result_tautologic);
}

sub verifiy_tautology(){
    my $pre=shift;
    my (@new_node);
    my ($number);
    my ($check_left,$check_right,$symbol);
    foreach(reverse sort keys(%Semantic_Rule)){
	my ($branch_to_process)=&Search_Node($_);
	my (@check)=$branch_to_process->getNodeValue();
	foreach(@check){
	    $symbol=pop(trim($_));
	}
	my @child=$branch_to_process->getAllChildren();
	my @leftinfo=$child[0]->getNodeValue();
	my @rightinfo=$child[1]->getNodeValue();
	if(1 ~~ @leftinfo){
	    $check_left=1;
	}elsif(0 ~~ @leftinfo){
	    $check_left=0;
	}else{
	    my ($data)=shift(@leftinfo);
	    while(ref($data) eq 'ARRAY' ){
		$data=@{$data}[0];
	    }
	    $data=trim($data);
	    if($data=~/\!/){
		$data=~/(\w(\w)?)/;
		$check_left=&evaluate_tree($pre->{$1},0,'!');
	    }else{
		$check_left=$pre->{$data};
		$child[0]->setNodeValue($data);
	    }
	}
	if(1 ~~ @rightinfo){
	    $check_right=1;
	}
	elsif(0 ~~ @rightinfo){
	    $check_right=0;
	}else{
	    my ($data)=shift(@rightinfo);
	    while(ref($data) eq 'ARRAY' ){
		$data=@{$data}[0];
	    }
	    $data=trim($data);
	    if($data=~/\!/){
		$data=~/(\w(\w)?)/;
		$check_right=&evaluate_tree($pre->{$1},0,'!');
	    }else{
		$check_right=$pre->{$data};
		$child[1]->setNodeValue($data);
	    }
	}
	$number=&evaluate_tree($check_left,$check_right,$symbol);
	if ($_ eq 'A'){
	    if (!$check_left and $check_right or $check_left and !$check_right){
		if ($number){
		    $Sastifactible=1;
		}
	    }
	}
	push @new_node,$number;
	push @new_node,$symbol;
	push @new_node,$_;
	$branch_to_process->setNodeValue([@new_node]);
	undef (@new_node);
    }
    return $number;
}
sub delete_tree(){
	undef($root);
	undef($subtree_position);
	&clone_tree(2,$Semantic_Rule{'A'});
}
sub reset(){
	undef($root);
	undef($subtree_position);
	$init_root=0;
        $id='A';
        $idtree='A';
        $new=0;
	$position=1;
        undef(%Semantic_Rule);
	undef(%prepositions);
	@propsitional_variables=();
}
1;
