package WebService::Raygun::Message::Error;

use Mouse;

use Mouse::Util::TypeConstraints;

use WebService::Raygun::Message::Error::StackTrace;

=head1 NAME

WebService::Raygun::Message::Error - Encapsulate the error part of the raygion.io request.

=head1 SYNOPSIS

  use WebService::Raygun::Message::Error;

=head1 DESCRIPTION

You shouldn't need to instantiate this class directly.

=head1 INTERFACE

=cut

subtype 'StackTrace' => as 'Object' =>
  where { $_->isa('WebService::Raygun::Message::Error::StackTrace') };

subtype 'ArrayOfStackTraces' => as 'ArrayRef[StackTrace]' => where {
    scalar @{$_} >= 1 and defined $_->[0]->line_number;
} => message {
    return 'At least one stack trace element is required.';
};

coerce 'StackTrace' => from 'HashRef' => via {
    return WebService::Raygun::Message::Error::StackTrace->new( %{$_} );
};
coerce 'ArrayOfStackTraces' => from 'ArrayRef[HashRef]' => via {
    my $array_of_hashes = $_;
    return [ map { WebService::Raygun::Message::Error::StackTrace->new( %{$_} ) }
          @{$array_of_hashes} ];
};

has inner_error => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return '';
    },
);

has data => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        return {};
    },
);

has class_name => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return '';
    },
);

has message => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return '';
    },
);

has stack_trace => (
    is      => 'rw',
    isa     => 'ArrayOfStackTraces',
    coerce  => 1,
    default => sub {
        return [];
    },

    # other attributes
);

=head2 prepare_raygun

Prepare the error structure to be converted to JSON and sent to raygun.io.

=cut

sub prepare_raygun {
    my $self = shift;
    return {
        innerError => $self->inner_error,
        data       => $self->data,
        className  => $self->class_name,
        message    => $self->message,
        stackTrace => [ map { $_->prepare_raygun } @{ $self->stack_trace } ]
    };
}

=head1 DEPENDENCIES


=head1 SEE ALSO

=cut

1;

__END__
