package Raygun4perl::Message::Environment;

use Mouse;

=head1 NAME

Raygun4perl::Message::Environment - Represent the I<Environment> data in a raygun request.

=head1 SYNOPSIS

  use Raygun4perl::Message::Environment;

  # synopsis...

=head1 DESCRIPTION

# longer description...


=head1 INTERFACE

=cut

has processor_count =>
  ( is => 'rw', isa => 'Int', default => sub { return 1; } );
has os_version => ( is => 'rw', isa => 'Str', default => sub { return ''; } );
has window_bounds_width =>
  ( is => 'rw', isa => 'Int', default => sub { return 0; } );
has window_bounds_height =>
  ( is => 'rw', isa => 'Int', default => sub { return 0; } );
has resolution_scale =>
  ( is => 'rw', isa => 'Str', default => sub { return ''; } );
has current_orientation =>
  ( is => 'rw', isa => 'Str', default => sub { return ''; } );
has cpu => ( is => 'rw', isa => 'Str', default => sub { return ''; } );
has package_version =>
  ( is => 'rw', isa => 'Str', default => sub { return ''; } );
has architecture => ( is => 'rw', isa => 'Str', default => sub { return ''; } );
has total_physical_memory =>
  ( is => 'rw', isa => 'Int', default => sub { return 1; } );
has available_physical_memory =>
  ( is => 'rw', isa => 'Int', default => sub { return 0; } );
has total_virtual_memory =>
  ( is => 'rw', isa => 'Int', default => sub { return 0; } );
has available_virtual_memory =>
  ( is => 'rw', isa => 'Int', default => sub { return 0; } );
has disk_space_free =>
  ( is => 'rw', isa => 'ArrayRef', default => sub { return [] }, );
has device_name => ( is => 'rw', isa => 'Str', default => sub { return ''; } );
has locale      => ( is => 'rw', isa => 'Str', default => sub { return '' }, );

=head2 prepare_for_api

Return the data structure that will be sent to raygun.io

=cut

sub prepare_for_api {
    my $self = shift;
    return {
        processorCount          => $self->processor_count,
        osVersion               => $self->os_version,
        windowBoundsWidth       => $self->window_bounds_width,
        windowBoundsHeight      => $self->window_bounds_height,
        resolutionScale         => $self->resolution_scale,
        currentOrientation      => $self->current_orientation,
        cpu                     => $self->cpu,
        packageVersion          => $self->package_version,
        architecture            => $self->architecture,
        totalPhysicalMemory     => $self->total_physical_memory,
        availablePhysicalMemory => $self->available_physical_memory,
        totalVirtualMemory      => $self->total_virtual_memory,
        availableVirtualMemory  => $self->available_virtual_memory,
        diskSpaceFree           => $self->disk_space_free,
        deviceName              => $self->device_name,
        locale                  => $self->locale,
    };

}

=head1 DEPENDENCIES


=head1 SEE ALSO

=cut

1;

__END__
