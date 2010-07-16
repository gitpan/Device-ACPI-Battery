use Test::More tests => 2;
use Carp;

BEGIN { use_ok('Device::ACPI::Battery') };

my $battery = Device::ACPI::Battery->new;

ok( $battery, "Battery object created ok...");

open $fh, '/proc/modules';

while (<$fh>) {
    if ($_ =~ /battery/) {
        $f = 1;
    }
}

carp 'Warning: battery acpi module not found in /proc/modules, please install before attempting to use Device::ACPI::Battery'
unless $f;

