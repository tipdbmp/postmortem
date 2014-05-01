use strict;
use warnings FATAL => 'all';
use v5.10;


# my $str = foo();
# # $str = foo();
# say $str;

# foo();
# sub foo {
#     bar();
#     baz();
#     'I am foo and I return this string';
# }

# # bar([0 .. 4], { a => 1, b => 2});
# sub bar {
#     baz();
#     i_return_nothing();
#     [ 1.. 4], [ 5 .. 9];
# }

# # baz();
# sub baz {
#     +{ a => 1, b => 2};
# }

# # i_return_nothing();
# sub i_return_nothing {

# }

# dt_now();
# sub dt_now {
#     use DateTime;
#     DateTime->now;
# }


say fact(4);
sub fact { my ($n) = @_;
    $n > 1 ? $n * fact($n - 1) : 1;
}


# factors(64);
# sub factors { my($n) = @_;
#     grep { $n % $_ == 0 }(1 .. $n);
# }


# fib_rec(5);
# sub fib_rec {
#     my $n = shift;
#     $n < 2 ? $n : fib_rec($n - 1) + fib_rec($n - 2);
# }


# for my $i (1..100) {
#     fizbuzz($i);
# }

# sub fizbuzz { my ($n) = @_;
#     $n % 15 == 0 ? "FizzBuzz"
#   : $n %  3 == 0 ? "Fizz"
#   : $n %  5 == 0 ? "Buzz"
#   :                $n
#   ;
# }


# sub halve { int((shift) / 2); }
# sub double { (shift) * 2; }
# sub iseven { ((shift) & 1) == 0; }

# sub ethiopicmult
# {
#     my ($plier, $plicand, $tutor) = @_;
#     print "ethiopic multiplication of $plier and $plicand\n" if $tutor;
#     my $r = 0;
#     while ($plier >= 1)
#     {
#     $r += $plicand unless iseven($plier);
#     if ($tutor) {
#         print "$plier, $plicand ", (iseven($plier) ? " struck" : " kept"), "\n";
#     }
#     $plier = halve($plier);
#     $plicand = double($plicand);
#     }
#     return $r;
# }

# print ethiopicmult(17,34, 1), "\n";


# Has to be placed after the function definitions so that
# the typeglobs would show up in the symbol table
use Postmortem;



# use DateTime;
# Postmortem->examine_package_matching('DateTime');
# Postmortem->examine_package('DateTime');
# my $dt = DateTime->now(time_zone => 'floating');
# say $dt->year;








