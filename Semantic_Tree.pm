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
use Tree::Simple;
use Tree_Logical;
use Common_definitions;

use feature 'switch';

our @EXPORT = qw(
    Build_tree
    check_root
    validate_operator_symbol
    Search_Node
    validate_tautologic
    trim
    verifiy_tautology
	clone_tree
	delete_tree
	check_logical_equivalence
);

our @ISA = qw(Exporter);
my $leftRule=0;
my $RightRule=1;

my @propsitional_variables;
my @Tree_list;
my $id='A';
my $idtree='A';
my $position=1;
my $root;
my @sub_tree;
my @subtree_position;
my %Semantic_Rule;
my @tree=(\$sub_tree[0],\$sub_tree[1]);
my $sibling_position;
my $first_child=0;
my $left_tree_finished=0;
my $init_root=0;
my $Sastifactible=0;

#////clone
my $clone_root;
my @clone_sub_tree;
my @clone_subtree_position;
my $new=0;
my $dat=0;
my $structure_regex_rule= qr/^\((\s)?((\!)?(\w))(\s)?.(.)?(\s)?((\!)?(\w))(\s)?\)$/;


sub Build_tree () {
    my ($status,@compile_rules)=@_;
    if ($status eq 1){
	$init_root=0;
	$id='A';
	$idtree='A';
	$new=1;
	undef(%Semantic_Rule);
    }
    my $regex = qr/
    ((?:\!)?               # start of bracket 1
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
	my (@rule_in_process)=$_;
	while( @rule_in_process ){
	    my $rule = shift @rule_in_process;
	    my @test_groups = $rule =~ m/$regex/g;
	    my @groups=&Tree_Logical::check_logical_equivalence($rule,@test_groups);
	    print "******************Groups: \n".(Dumper(@groups));
	    print $rule."\n";
	    print "**********************************************\n";
	    foreach(@groups){
		$Semantic_Rule{$id}=$_;
		$id++
	    }
	    given(@groups){
		my $position_Tree_test;
		my $tree_id;
		#print "ooo:".scalar(@groups)."pol\n";
		when(scalar(@groups) eq 0){
		    my $last_rule="($rule)";
		    #print "'$last_rule'\n";
		    if($last_rule =~ /^\((\s)?((\!)?(\w))(\s)?.(.)?(\s)?((\!)?(\w))(\s)?\)$/){
			$rule =~ /(\s)?([\&|\||\-\>])(\s)?/g;
			#  print "'$1' -- '$2' -- '$'' ----- '$`'---- $last_rule\n";
			my $first=trim($`);
			my $second=trim($');
			if($second =~ /\>(\s)?(\w)/){
				$second=$2;
			}
			my ($branch_to_process , $actualid)=&Search_Node($last_rule,0);
			&validate_operator_symbol($rule,$branch_to_process,1,1);
			$subtree_position[$position]=Tree::Simple->new([$first],$branch_to_process);
			$subtree_position[$position]->addSibling(Tree::Simple->new([$second]));
			$position++;
			push @propsitional_variables, $first if($first !~ @propsitional_variables);
			push @propsitional_variables, $second if($second !~ @propsitional_variables);
		    }else{
			$rule="($rule)";
#			print "$rule\n";
			my ($node_value)=$rule=~ /(\w)/;
			my ($first_branch_to_process , $actual_id)=&Search_Node($rule,$1);
			&validate_operator_symbol($last_rule,$first_branch_to_process,$actualid,1);
			#		sleep 3;
			my @array;
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
			    print "first: ---$rule----'$'' ---- '$`' ---- '$&' ---- \n";
			    my ($aux_node)=$';
			    my ($second_aux_node)=$`;
			    $subtree_position[$position]=Tree::Simple->new([$idtree],$root);
			    $init_root++;
			    $idtree++;
			    $position++;
			    #print Dumper($root);
			    #print "first: -------'$second_aux_node' ---- '$aux_node' -------- \n";
			    #sleep 3;
			    if ($second_aux_node =~ /^((\s)?(\!)?(\w))/){
				#print "left\n";
				my $node_value=trim($1);
				&validate_operator_symbol($rule,$idtree,$root,$groups[0],0);
				$subtree_position[$position]=Tree::Simple->new([$node_value],$root);
				$position++;
				push @propsitional_variables, $node_value  if($node_value !~ @propsitional_variables);
				continue;
			    }
			    if($aux_node =~ /(\s)?([\!|\&|\||\-\>])((\s)?(\!)?(\w))(\s)?/){
				#print "right\n";
				my ($node_value)=trim($3);
				&validate_operator_symbol($rule,$idtree,$root,$groups[0],1);
				$subtree_position[$position]=Tree::Simple->new([$node_value],$root);
				$position++;
				push @propsitional_variables, $node_value  if($node_value !~ @propsitional_variables);
				continue;
			    }
			}
			#print "--------------$rule-------------\n";
			my ($first_branch_to_process , $actual_id)=&Search_Node($rule,1);
			#print "$actual_id\n";
			#aftera
			#	print "--- *'$`'*  *'$''* ---\n";
			#sleep 3;
			if($` =~ /^((\s)?(\!)?(\w))/ ){
			    my $node_value=$1;
			    #   print "leff-side $node_value\n";
			   # sleep 3;
			    $node_value=trim($node_value);
			    &validate_operator_symbol($rule,$actual_id,$first_branch_to_process,$groups[0],0);
			    $subtree_position[$position]=Tree::Simple->new([$node_value],$first_branch_to_process);
			    $position++;
			    $subtree_position[$position]=Tree::Simple->new([$idtree],$first_branch_to_process);
			    $idtree++;
			    $position++;
			    push @propsitional_variables, $node_value  if($node_value !~ @propsitional_variables);
			}
			if($' =~ /^(\s)?([\!|\&|\||\-\>])((\s)?(\!)?(\w))(\s)?$/){
			    my ($node_value)=$3;
			    $node_value=$4 if($node_value eq '');
			    # print "cooooooooooool--- '$3' --- '$4' --- $node_value   \n";
			    # #sleep 1;
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
			my ($branch_to_process ,$actualid)=&Search_Node($rule,1);
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
	    #print "-----------------------------------------------------------------------------------\n";
	    #print "TREE: \n".(Dumper($root));
	    #print "--------------------------------------------------------\n";
	    #sleep 2;
	    #  print " $id eq $idtree\n";
	    #print "********************************\n";
	    #print "Groups: ".(Dumper(@groups));
	    #print "********************************\n";
	    #print "HASH: \n".Dumper(%Semantic_Rule);
	    #exit if ($id ne $idtree);
	    unshift @rule_in_process, map { s/^\(//; s/\)$//; $_ } @groups;
	}
	 if($new){
	   return $root;
	}
	#print Dumper($root);
	#exit;
	&validate_tautologic(%Semantic_Rule);
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
    print "$check_rule, \n";
    if(defined ($matches_rules[3]) and $matches_rules[3] eq '0'){
	my ($id_search,$content_tree,$left)=@matches_rules;
	my ($leftsz)=length($left);
	my ($shortrule)=substr $check_rule,0,-$leftsz-2;
	#print "test: $shortrule\n";
	$shortrule =~ /([\&|\||\-\>])(\s)?$/;
	$conector=$1;
	$conector= "->" if($1 eq '>');
	$conector= "->" if($1 eq '-');
#	print "1- '$1'\n";
#	sleep 2;
	my (@NodeValue)=$content_tree->getNodeValue();
	push @NodeValue, $conector;
	$content_tree->setNodeValue([@NodeValue]);
    }elsif(defined ($matches_rules[3]) and $matches_rules[3] eq '1'){
	my ($id_search,$content_tree,$right)=@matches_rules;
#	print "$id_search-------$content_tree\n";
	my ($rightsz)=length($right);
	my ($shortrule)=substr $check_rule,$rightsz+2;
#	print "test: $shortrule\n";
	$shortrule =~ /([|\&|\||\-\>])/;
	$conector=$1 if($1 ne "");
	$conector= "->" if($1 eq '>');
	$conector= "->" if($1 eq '-');
#	print "1- '$1' '$2' '$3'\n";
	#sleep 3;
	my (@NodeValue)=$content_tree->getNodeValue();
	push @NodeValue, $conector;
	$content_tree->setNodeValue([@NodeValue]);
    }elsif(defined ($matches_rules[2]) and $matches_rules[2] eq '1'){
		my ($content_tree,$id)=@matches_rules;
		$check_rule=~ /([\&|\||\-\>])/;
		$conector=$1;
		$conector= "->" if($1 eq '>');
		$conector= "->" if($1 eq '-');
	#	print "------- $1\n";
		#print Dumper($content_tree);
		my (@NodeValue)=$content_tree->getNodeValue();
		#print Dumper(@NodeValue);
		push @NodeValue, $conector;
		$content_tree->setNodeValue([@NodeValue]);
	#	print Dumper($root);
    }else{
		my ($left,$right,$content_tree)=@matches_rules;
		print " '$left' , '$right' , '$check_rule' \n";
		my $leftsz=length($left);
		my $rightsz=length($right);
		if($rightsz =~ /\!\(/g)
		{
		    $rightsz=$rightsz-2;
		}else{
		    print "else\n";
		    $rightsz=$rightsz+2;
		}

		my $shortrule=substr $check_rule,$leftsz+2;
		$conector=substr $shortrule,0,-$rightsz;
		$conector=trim($conector);
		#return 1 if ($conector =~/!/);
		#print "1- '$conector'--- \n";
		if($init_root eq 1){
		   my (@root_NodeValue)=$root->getNodeValue();
		   push @root_NodeValue, $conector;
		   $root->setNodeValue([@root_NodeValue]);
	}else{
#	    print "-------\n";
	    my (@NodeValue)=$content_tree->getNodeValue();
	    push @NodeValue, $conector;
	    $content_tree->setNodeValue([@NodeValue]);
	}
    }
}
sub Search_Node{
	my ($rule,$content_tree)=@_;
	my ($tree_test);
	my $position_Tree_test;
	foreach( reverse sort keys(%Semantic_Rule)){
		my ($id_rule)=$_;
#		print "$_ <-> '$Semantic_Rule{$id_rule}' <-> '$rule'\n";
		if($rule eq $Semantic_Rule{$id_rule} or $rule eq $id_rule){
			if($rule eq 'A' or $Semantic_Rule{'A'} eq $rule){
				#print "------> $rule\n";
				return ($root,'A');
			}
#			print "check elements $position\n";
			my $check_position=$position-1;
			    while($check_position){
					my ($node)=$subtree_position[$check_position]->getNodeValue();
#				    print "$node ---\n";
#					 print "real:\n".Dumper($node);
					if (ref($node) eq 'ARRAY' ){
#						print "here2\n";
		   				$node=@{$node}[0];
					}
					if (ref($node) eq 'ARRAY' ){
#						print "here1\n";
				    	$node=@{$node}[0];
				    }
					if (ref($node) eq 'ARRAY' ){
#						print "here0\n";
						 $node=@{$node}[0];
					}
#					print "$node ---> $id_rule \n";
					if($id_rule eq $node){
#				    	print "GOOOOOD:  ---> $id_rule \n";
				    	$tree_test=$subtree_position[$check_position];
				    	$position_Tree_test=$id_rule;
				    	return ($tree_test,$position_Tree_test);
				}
			    $check_position--;
			    }

		}
	}

}
sub validate_tautologic(){
    my ($array_position)=0;
    my %prepositions;
    my @result_tautologic;
    foreach (@propsitional_variables){
	my $variable=$_;
	#print "------- $variable ---\n";
	if($variable =~ /\!(\w)/g){
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
    #print Dumper(%prepositions);
    #print "position: $array_position\n";
    my (@array_bit)=&Logical_table($array_position);
    foreach $array_column (@array_bit){
	foreach (keys(%prepositions)){
	    $prepositions{$_}=shift(@$array_column);
	}
	print "Rules: ".Dumper(%prepositions);
	my $result_tree=&verifiy_tautology(\%prepositions);
	push @result_tautologic,$result_tree;
	&delete_tree();
    }
    &Tautologic_Conclusion($Semantic_Rule{'A'},$Sastifactible,@result_tautologic);
}

sub verifiy_tautology(){
    my $pre=shift;
    my @new_node;
    my $number;
    my ($check_left,$check_right,$symbol);
    foreach( reverse sort keys(%Semantic_Rule)){
	print "varible: $_\n";
	my ($branch_to_process)=&Search_Node($_);
	my (@check)=$branch_to_process->getNodeValue();
	print "Actual node:".Dumper(@check);
	foreach(@check){
	    $symbol=pop $_;
	    $symbol=trim($symbol);
	}
	
	my @child=$branch_to_process->getAllChildren();
	#print "$child[0], $child[1]\n";
	my @leftinfo=$child[0]->getNodeValue();
	my @rightinfo=$child[1]->getNodeValue();
	print "Verify Left: ".Dumper(@leftinfo);
	#sleep 1;
	if(1 ~~ @leftinfo){
	    $check_left=1;
	}elsif(0 ~~ @leftinfo){
	    $check_left=0;
	}else{
	    my ($data)=shift(shift(@leftinfo));
	    if(ref($data) eq 'ARRAY' ){
		$data=@{$data}[0];
	    }
	    if (ref($data) eq 'ARRAY' ){
		$data=@{$data}[0];
	    }
	    $data=trim($data);
	    #print "'$data'\n";
	    if($data=~/\!/){
		$data=~/(\w)/;
		#print "------------->minus: $pre->{$1}\n";
		$check_left=&evaluate_tree($pre->{$1},0,'!');
	    }else{
		$check_left=$pre->{$data};
		$child[0]->setNodeValue($data);
	    }
	}
	print "Verify Right: ".Dumper(@rightinfo);
	#sleep 1;
	if(1 ~~ @rightinfo){
	    $check_right=1;
	}elsif(0 ~~ @rightinfo){
	    $check_right=0;
	}else{
	    my ($data)=(shift(@rightinfo));
	    if (ref($data) eq 'ARRAY' ){
		$data=@{$data}[0];
	    }
	    if (ref($data) eq 'ARRAY' ){
	        $data=@{$data}[0];
	    }
	    #print "'$data'\n";
	    $data=trim($data);
	    #print Dumper($data);
	    if($data=~/\!/){
		$data=~/(\w)/;
		# print "----------------->minus: $pre->{$1}\n";
		$check_right=&evaluate_tree($pre->{$1},0,'!');
	    }else{
		$check_right=$pre->{$data};
		$child[1]->setNodeValue($data);
	    }
	}
	print "left: $check_left\n";
	print "right: $check_right\n";
	print "symbol: $symbol\n";
	$number=&evaluate_tree($check_left,$check_right,$symbol);
	print "number: $number\n";
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
	#print Dumper(@new_node);
	$branch_to_process->setNodeValue([@new_node]);
	#print Dumper($branch_to_process);
	undef (@new_node);
    }
    return $number;
}
sub trim($){
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}
sub delete_tree(){
		undef($sub_tree);
		undef($root);
		undef($subtree_position);
		&clone_tree(2,$Semantic_Rule{'A'});
}
1;
