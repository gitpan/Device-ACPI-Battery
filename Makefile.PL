use ExtUtils::MakeMaker;

WriteMakefile(
    NAME           => 'Device::ACPI::Battery',
    AUTHOR         => 'Aesop',
    VERSION_FROM   => 'lib/Device/ACPI/Battery.pm',
    PREREQ_PM      => {
	'Moose' => 0,
    },
    );
