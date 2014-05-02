# Postmortem - Perl data flow visualizing after the END { }

Patches the importing module's subs so that they print their names, the arguments they were
called with and their return value.

### SYNOPSIS
```perl
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

# Has to be placed after the function definitions so that
# the typeglobs would show up in the symbol table
use Postmortem;

# output:
I am foo and I return this string


Postmortem:

'I am foo and I return this string' <- main::foo()

    [1,2,3,4], [5,6,7,8,9] <- main::bar()

        {'b' => 2,'a' => 1} <- main::baz()

[1,2,3,4], [5,6,7,8,9] <- main::bar([0,1,2,3,4], {'b' => 2,'a' => 1})

    {'b' => 2,'a' => 1} <- main::baz()

{'b' => 2,'a' => 1} <- main::baz()

 <- main::i_return_nothing()


 # You can see how a recursive function recurses
fact(4);
sub fact { my ($n) = @_;
    $n > 1 ? $n * fact($n - 1) : 1;
}
use Postmortem;
# Output
24


Postmortem:

24 <- main::fact(4)

    6 <- main::fact(3)

        2 <- main::fact(2)

            1 <- main::fact(1)



# You can provide a list of sub names not to be patched
factors(64);
sub factors { my($n) = @_;
    grep { $n % $_ == 0 }(1 .. $n);
}

fib_rec(5);
sub fib_rec { my ($n) = @_;
    $n < 2 ? $n : fib_rec($n - 1) + fib_rec($n - 2);
}


use Postmortem ignore => qw|fib_rect|;
# output:


Postmortem:

1, 2, 4, 8, 16, 32, 64 <- main::factors(64)


```

### Caveats
- The placement of the 'use Postmortem;' must be after the sub declarations, so that the
typeglobs would show up in the symbol table
- The output is some-what hard to read/follow.

### Dependencies
- v5.10+
- Package::Stash
