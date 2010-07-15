use Test::More tests => 2;
use warnings;
use strict;

BEGIN { use_ok('Device::ACPI::Battery') };

my $battery = Device::ACPI::Battery->new;

ok( $battery, "Battery object created ok...");