#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Github::Jobs::Api' ) || print "Bail out!\n";
}

diag( "Testing Github::Jobs::Api $Github::Jobs::Api::VERSION, Perl $], $^X" );
