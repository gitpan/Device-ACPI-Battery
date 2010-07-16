package Device::ACPI::Battery;

use Moose;
use Carp;

our $VERSION = '0.03';

has 'path' => (
    is => 'rw',
    isa => 'Str',
    default => '/proc/acpi/battery/BAT0/'
    );

before 'path' => sub {
    my ($self, $path) = @_;
    if ($path) {
    carp 'Warning: path to device is invalid, set correct path with $self->path($path)' unless (-e $path);
    }
};

before [ qw(charging charge voltage rate capacity model oem) ] => sub {
    my $self = shift;
    croak 'Invalid path to device, set correct path with $self->path($path)' unless (-e $self->path);
};

sub charging {
    my $self = shift;
    my $state;
    open my $fh, $self->path.'state' or croak 'No device state info file found';
    while (<$fh>) {
        if ($_ =~ /^charging/) {
            $state = $_;
            $state =~ s/^charging state:\s*//;
            $state =~ s/\s*//g;
        }
    }
    close $fh;
    return unless $state eq 'charging' or $state eq 'charged';
    return 1;
}

sub charge {
    my $self = shift;
    my $charge;
    open my $fh, $self->path.'state' or croak 'No device state info file found';
    while (<$fh>) {
        if ($_ =~ /^remaining/ ) {
            $charge = $_;
            $charge =~ s/\D*//g;
        }
    }
    close $fh;
    return $charge;
}

sub voltage {
    my $self = shift;
    my $voltage;
    open my $fh, $self->path.'state' or croak 'No device state info file found';
    while (<$fh>) {
        if ($_ =~ /voltage/) {
            $voltage = $_;
            $voltage =~ s/\D*//g;
        }
    }
    close $fh;
    return $voltage;
}

sub rate {
    my $self = shift;
    my $rate;
    open my $fh, $self->path.'state' or croak 'No device state info found';
    while (<$fh>) {
        if ($_ =~ /rate/) {
            $rate = $_;
            $rate =~ s/\D*//g;
        }
    }
    close $fh;
    return $rate;
}

sub capacity {
    my $self = shift;
    my $capacity;
    open my $fh, $self->path.'info' or croak 'No device info file found';
    while (<$fh>) {
        if ($_ =~ /last/) {
            $capacity = $_;
            $capacity =~ s/\D*//g;
        }
    }
    close $fh;
    return $capacity;
}

sub model {
    my $self = shift;
    my $model;
    open my $fh, $self->path.'info' or croak 'No device info file found';
    while (<$fh>) {
        if ($_ =~ /model/) {
            $model = $_;
            $model =~ s/^model number:\s*//;
            $model =~ s/\s*//g;
        }
    }
    close $fh;
    return $model;
}

sub oem {
    my $self = shift;
    my $oem;
    open my $fh, $self->path.'info' or croak 'No device info file found';
    while (<$fh>) {
        if ($_ =~ /OEM/) {
            $oem = $_;
            $oem =~ s/^OEM info:\s*//;
            $oem =~ s/\s*//g;
        }
    }
    close $fh;
    return $oem;
}

sub charge_percent {
    my $self = shift;
    my $remaining = int( ( $self->charge / $self->capacity ) * 100 );
    return $remaining;
}

sub charge_time {
    my $self = shift;
    return if $self->charging;
    my $time = int( $self->charge / ( $self->rate / 60 ) );
    return $time;
}

=head1 NAME

Device::ACPI::Battery - Retrieve information about your ACPI managed battery on linux.

=head1 SYNOPSIS

    use Device::ACPI::Battery;
    
    # default path is '/proc/acpi/battery/BAT0', changeable on construction or with $self->path

    my $battery = Device::ACPI::Battery->new( path => '/proc/acpi/battery/BAT1');
    
    print 'Battery is charging' if $battery->charging;

    print 'Battery has '.$battery->charge.' mWh charge left';

    print 'Battery voltage: '.$battery->voltage.' mV';

    $battery->path('/proc/acpi/battery/BAT2');

    print 'Current discharge rate: '.$battery->rate.' mWh';
        #returns 0 if battery is connected to power supply and fully charged
    print 'Capacity at full charge: '.$battery->capacity.'mWh';

    print 'Model number: '.$battery->model;

    print 'Manufacturer: '.$battery->oem;

    print 'Percent of charge remaining: '.$battery->charge_percent;

    print 'Time on charge remaining: '.$battery->charge_time;
        # in minutes, estimated time. returns undef if rate = 0;
    
=head1 DESCRIPTION

This module is used to collect information about batteries managed by ACPI on Linux, by scraping the files found under /proc/acpi/battery/. Useful for tasks such as displaying battery status in terminal (what I use it for). Proper use of this module requires that your kernel has ACPI installed and is used to manage your battery, so please check your list of installed kernel modules (/proc/modules, look for 'battery') before attempting to use. An easy way to find out is by checking if /proc/acpi/battery exists and if it has any subdirectories named similar to the default path specified above. If so, set $self->path to that full path.

=head1 AUTHORS

aesop <aesop@cpan.org>

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

no Moose;

__PACKAGE__->meta->make_immutable;

1;
