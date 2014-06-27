package WebService::Raygun::Message::Error::StackTrace;

use Mouse;

=head1 NAME

WebService::Raygun::Message::Error::StackTrace - Encapsule the stacktrace in error details

=head1 SYNOPSIS

  use WebService::Raygun::Message::Error::StackTrace;




=head1 DESCRIPTION

# longer description...


=head1 INTERFACE

=cut

has line_number => (
    is      => 'rw',
    isa     => 'Int',
    default => sub {
        return 0;
    },
);

has class_name => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return '';
    },
);

has file_name => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return '';
    },
);

has method_name => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return '';
    },
);

=head2 prepare_raygun

Prepare the data for conversion to JSON.

=cut

sub prepare_raygun {
    my $self = shift;
    return {
        lineNumber => $self->line_number,
        className  => $self->class_name,
        fileName   => $self->file_name,
        methodName => $self->method_name,
    };
}

=head1 DEPENDENCIES


=head1 SEE ALSO


=cut

1;

__END__
