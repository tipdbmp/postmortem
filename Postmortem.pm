package Postmortem;
use strict;
use warnings FATAL => 'all';
use v5.10;
use Package::Stash;
use Data::Dumper;

my @postmortem_msgs;
END { say "\n\n", __PACKAGE__, ":\n"; say for @postmortem_msgs; }

sub import {
    my $caller_pkg = caller;
    # say $caller_pkg;
    examine_package(__PACKAGE__, $caller_pkg);
}

sub examine_package { my ($class, $pkg) = @_;
    # say "package: $pkg";
    my $pkg_stash = Package::Stash->new($pkg);
    my @sub_names = $pkg_stash->list_all_symbols('CODE');
    # use DDP; say p @sub_names;
    {
        no strict 'refs';

        # my $sub = \&{"$pkg\::foo"};
        # say $sub;
        # $sub->();

        # my $sub = \&{"$pkg\::foo"};
        # $pkg_stash->add_symbol('&foo', sub {
        #     my @return = $sub->(@_);
        #     use DDP; say p @return;
        #     return @return;
        # });

        for my $sub_name (@sub_names) {
            my $sub = \&{"$pkg\::$sub_name"};
            $pkg_stash->add_symbol("&$sub_name", examine_sub($sub, "$pkg\::$sub_name"));
        }
    }
}

sub examine_sub { my ($sub, $sub_name) = @_;
    $sub_name ||= 'unknown_subname';
    sub {
        my @return = $sub->(@_);

        local $Data::Dumper::Indent;
        $Data::Dumper::Indent = 0;
        local $Data::Dumper::Terse;
        $Data::Dumper::Terse = 1;

        # say "$sub_name(", join(', ', Dumper(@_)),  ") -> ", join(', ', Dumper(@return));
        push @postmortem_msgs, "$sub_name(" . join(', ', Dumper(@_)) .  ') -> ' . join(', ', Dumper(@return));

        return if @return == 0;
        return $return[0] if @return == 1;
        return @return;
    }
}


sub examine_package_matching { my ($class, $regex) = @_;
    my @package_names = _find_packages();
    # use DDP; say p @package_names;
    my @matched_packages = grep { /$regex/ } @package_names;
    # use DDP; say p @matched_packages;
    examine_package(__PACKAGE__, $_) for @matched_packages;
}

sub _find_packages {
    my $current_package = shift || 'main';
    my $found_packages  = shift || {};

    {
        no strict 'refs';

        my @package_symbols    = keys %{"$current_package\::"};
        # use DDP; say p @package_symbols;
        my @sub_package_names  = map { substr $_, 0, -2 } grep { /::$/ } @package_symbols;
        @sub_package_names = _filter_packages(@sub_package_names);
        # use DDP; say p @sub_package_names;

        my @full_package_names;
        if ($current_package eq 'main') {
            @full_package_names = @sub_package_names;
        }
        else {
            @full_package_names = map { "${current_package}::$_" } @sub_package_names;
        }
        @{$found_packages}{@full_package_names} = (1) x (0+@full_package_names);

        for my $package_name (@full_package_names) {
            _find_packages($package_name, $found_packages);
        }
    }

    return keys %$found_packages;
}

sub _filter_packages { my (@packages) = @_;
    state $ignored_packages = [qw|
        Postmortem Params
        MRO overloading Win32 DynaLoader XSLoader CORE Carp Regexp IO DDP Try File
        POSIX Scalar Tie B DB UNIVERSAL Mac Fcntl Exporter ExtUtils Internals Package
        Sub Term Cwd FakeLocale Config
    |];
    state $ignored_packages_regex = join '|', @$ignored_packages;

    @packages = grep { /^[A-Z]/} @packages;
    @packages = grep { !/_/} @packages;
    @packages = grep { !/^$ignored_packages_regex$/o } @packages;

    @packages;
}

1;