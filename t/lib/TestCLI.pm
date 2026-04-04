use v5.38;
use utf8;

package TestCLI;
use FindBin qw($Bin);
use lib ("$Bin/../../lib");
use parent qw(eBird::CLI);


sub exit ($self, $n) { return $n }



__PACKAGE__;
