package Postmortem;
use strict;
use warnings FATAL => 'all';
use v5.10;
use Package::Stash;
use Data::Dumper;

my @postmortem_msgs;
END {
    say "\n\n", __PACKAGE__, ":\n";

    # use DDP; say p @postmortem_msgs;

    # say for @postmortem_msgs;
    say "$_\n" for @postmortem_msgs;
}

sub import {
    my $caller_pkg = caller;
    # use DDP; say p @_;

    # [0] ->  __PACKAGE__
    # [1] -> ignore
    # [2] -> name_of_sub_to_ignore
    my @ignored_sub_names = @_[2 .. $#_];
    # use DDP; say p @ignored_sub_names;
    __PACKAGE__->examine_package($caller_pkg, \@ignored_sub_names);
}

sub examine_package { my ($class, $pkg, $ignored_sub_names) = @_;
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

        $ignored_sub_names ||= [];
        # use DDP; say p $ignored_sub_names;
        my $ignored_sub_names_regex = join '|', @$ignored_sub_names;
        for my $sub_name (@sub_names) {
            next if $ignored_sub_names_regex && $sub_name =~ /$ignored_sub_names_regex/;
            # say $sub_name;
            my $sub = \&{"$pkg\::$sub_name"};
            $pkg_stash->add_symbol("&$sub_name", examine_sub($sub, "$pkg\::$sub_name"));
        }
    }
}

sub examine_sub { my ($sub, $sub_name) = @_;
    $sub_name ||= 'unknown_subname';
    sub {

        local $Data::Dumper::Indent;
        $Data::Dumper::Indent = 0;
        local $Data::Dumper::Terse;
        $Data::Dumper::Terse = 1;

        my $caller_number = 1;
        $caller_number++ while defined caller $caller_number;
        $caller_number = int $caller_number / 2;
        # say $caller_number;
        my $indent = ' ' x (4 * ($caller_number));

        my $postmortem_msg = join '',
            , " <- "
            , "$sub_name("
            , join(', ', Dumper(@_))
            ,  ')'
            ;

        push @postmortem_msgs, $postmortem_msg;

        my $current_msg_index  = $#postmortem_msgs;

        my $called_in_list_context   = wantarray;
        my $called_in_void_context   = !defined $called_in_list_context;
        my $called_in_scalar_context = !$called_in_void_context;

        if ($called_in_list_context || $called_in_void_context) {
            my @return = $sub->(@_);
            $postmortem_msgs[$current_msg_index] = join '',
                , $indent
                , join(', ', Dumper(@return))
                , $postmortem_msgs[$current_msg_index]
                ;
            return @return;
        } elsif ($called_in_scalar_context) {
            my $return = $sub->(@_);
            $postmortem_msgs[$current_msg_index] = join '',
                , $indent
                , Dumper($return)
                , $postmortem_msgs[$current_msg_index]
                ;
            return $return;
        }
        # } elsif ($called_in_void_context) {
        #     $sub->(@_);
        #     $postmortem_msgs[$current_msg_index] = join '',
        #         , $indent
        #         , '__NOTHING__'
        #         , $postmortem_msgs[$current_msg_index]
        #         ;
        #     return;
        # }
    }
}


sub examine_package_matching { my ($class, $regex) = @_;
    my @package_names = _find_packages();
    # use DDP; say p @package_names;
    my @matched_packages = grep { /$regex/ } @package_names;
    # use DDP; say p @matched_packages;
    __PACKAGE__->examine_package($_) for @matched_packages;
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