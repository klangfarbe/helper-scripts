#!/usr/bin/perl
use 5.008;
use strict;
use Memoize;

# by Aristotle Pagaltzis <http://stackoverflow.com/users/9410/aristotle-pagaltzis>
# taken from thread http://stackoverflow.com/questions/223678/git-which-commit-has-this-blob
# on 6 june 2010

my $usage =
"usage: git-find-blob <blob> [<git-log arguments ...>]

pass the blob SHA1 as the first parameter
and then any number of arguments to git log

";
die $usage unless @ARGV;

my $obj_name = shift;

sub check_tree {
    my ( $tree ) = @_;
    my @subtree;

    {
        open my $ls_tree, '-|', git => 'ls-tree' => $tree->[0]
            or die "Couldn't open pipe to git-ls-tree: $!\n";

        while ( <$ls_tree> ) {
            /\A[0-7]{6} (\S+) (\S+)\s+(\S+)/
                or die "unexpected git-ls-tree output";
            my $path = "$tree->[1]/$3";
            return $path if $2 eq $obj_name;
            push @subtree, [$2, $path] if $1 eq 'tree';
        }
    }

    for (@subtree) {
      my $path = check_tree($_);
      return $path if $path;
    }

    return;
}

memoize 'check_tree';

open my $log, '-|', git => log => @ARGV, '--pretty=format:%T %h %s'
    or die "Couldn't open pipe to git-log: $!\n";

while ( <$log> ) {
    chomp;
    my ( $tree, $commit, $subject ) = split " ", $_, 3;
    my $path = check_tree([$tree, '/']);
    print "$commit $subject >> $path\n" if $path;
}
