#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 25;
use Test::Exception;

use Scalar::Util 'isweak';

BEGIN {
    use_ok('Moose');           
}

{
    package BinaryTree;
    use strict;
    use warnings;
    use Moose;

    has 'parent' => (
		is        => 'rw',
		isa       => 'BinaryTree',	
        predicate => 'has_parent',
		weak_ref  => 1,
    );

    has 'left' => (
		is        => 'rw',	
		isa       => 'BinaryTree',		
        predicate => 'has_left',  
        lazy      => 1,
        default   => sub { BinaryTree->new(parent => $_[0]) },       
    );

    has 'right' => (
		is        => 'rw',	
		isa       => 'BinaryTree',		
        predicate => 'has_right',   
        lazy      => 1,       
        default   => sub { BinaryTree->new(parent => $_[0]) },       
    );

    before 'right', 'left' => sub {
        my ($self, $tree) = @_;
	    $tree->parent($self) if defined $tree;   
	};
}

my $root = BinaryTree->new();
isa_ok($root, 'BinaryTree');

ok(!$root->has_left, '... no left node yet');
ok(!$root->has_right, '... no right node yet');

ok(!$root->has_parent, '... no parent for root node');

# make a left node

my $left = $root->left;
isa_ok($left, 'BinaryTree');

is($root->left, $left, '... got the same node (and it is $left)');
ok($root->has_left, '... we have a left node now');

ok($left->has_parent, '... lefts has a parent');
is($left->parent, $root, '... lefts parent is the root');

ok(isweak($left->{parent}), '... parent is a weakened ref');

ok(!$left->has_left, '... $left no left node yet');
ok(!$left->has_right, '... $left no right node yet');

# make a right node

my $right = $root->right;
isa_ok($right, 'BinaryTree');

is($root->right, $right, '... got the same node (and it is $right)');
ok($root->has_right, '... we have a right node now');

ok($right->has_parent, '... rights has a parent');
is($right->parent, $root, '... rights parent is the root');

ok(isweak($right->{parent}), '... parent is a weakened ref');

my $left_left = $left->left;
isa_ok($left_left, 'BinaryTree');

ok($left_left->has_parent, '... left does have a parent');

is($left_left->parent, $left, '... got a parent node (and it is $left)');
ok($left->has_left, '... we have a left node now');
is($left->left, $left_left, '... got a left node (and it is $left_left)');

ok(isweak($left_left->{parent}), '... parent is a weakened ref');

