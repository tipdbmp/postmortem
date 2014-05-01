use strict;
use warnings FATAL => 'all';
use v5.10;


my $str = foo();
say $str;

sub foo {
    bar();
    'I am foo and I return this string';
}

bar([0 .. 4], { a => 1, b => 2});
sub bar {
    baz();
    [ 1.. 4], [ 5 .. 9];
}

baz();
sub baz {
    +{ a => 1, b => 2};
}

i_return_nothing();
sub i_return_nothing {

}

# dt_now();
sub dt_now {
    use DateTime;
    DateTime->now;
}

# Has to be placed after the function definitions so that
# the typeglobs would show up in the symbol table
use Postmortem;


# Postmortem->examine_package_matching('DateTime');
# Postmortem->examine_package('DateTime');
# my $dt = DateTime->now(time_zone => 'floating');
# say $dt->year;








