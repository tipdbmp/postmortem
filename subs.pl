use strict;
use warnings FATAL => 'all';
use v5.10;

my $str = foo();
say $str;


sub foo {
    'I am foo and I return this string';
}

bar([0 .. 4], { a => 1, b => 2});
sub bar {
    [ 1.. 4], [ 5 .. 9];
}

baz();
sub baz {
    +{ a => 1, b => 2};
}

dt_now();
sub dt_now {
    use DateTime;
    DateTime->now;
}

# Has to be placed after the function definitions so that
# the typeglobs would show up in the symbol table
use Postmortem;

# The output of the above:
# I am foo and I return this string


# Postmortem:

# main::foo() -> 'I am foo and I return this string'
# main::bar([0,1,2,3,4], {'b' => 2,'a' => 1}) -> [1,2,3,4], [5,6,7,8,9]
# main::baz() -> {'b' => 2,'a' => 1}
# main::dt_now() -> bless( {'local_c' => {'day' => 30,'hour' => 13,'quarter' => 2,'day_of_quarter' => 30,'month' => 4,'minute' => 11,'second' => 52,'year' => 2014,'day_of_week' => 3,'day_of_year' => 120},'locale' => bless( {'native_complete_name' => 'English United States','en_complete_name' => 'English United States','native_territory' => 'United States','default_time_format_length' => 'medium','default_date_format_length' => 'medium','id' => 'en_US','en_language' => 'English','en_territory' => 'United States','native_language' => 'English'}, 'DateTime::Locale::en_US' ),'utc_rd_secs' => 47512,'tz' => bless( {'name' => 'UTC'}, 'DateTime::TimeZone::UTC' ),'local_rd_secs' => 47512,'rd_nanosecs' => 0,'offset_modifier' => 0,'formatter' => undef,'local_rd_days' => 735353,'utc_rd_days' => 735353,'utc_year' => 2015}, 'DateTime' )



# Postmortem->examine_package_matching('DateTime');
# Postmortem->examine_package('DateTime');
# my $dt = DateTime->now(time_zone => 'floating');
# say $dt->year;








