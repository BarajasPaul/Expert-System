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
###------------------------------------------------------------------------------
### -It has the purpose to define all common variables that can use in different|
### modules and not repeat definitions with this will have a good performance.	|
###										|
### -Provide a error handling to identified what kind of errors found		|
### at the moment of compiling and Data collection				|
###------------------------------------------------------------------------------
###
###############################################

use warnings;

package Common_definitions;
use base 'Exporter';
our @EXPORT = qw(
	new_knowledge_base
	delete_new_line
	trim
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

1;



