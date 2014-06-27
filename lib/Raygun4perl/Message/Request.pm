package Raygun4perl::Message::Request;

use Mouse;
use Mouse::Util::TypeConstraints;

=head1 NAME

Raygun4perl::Message::Request - Encapsulate the data in a typical HTTP request.

=head1 SYNOPSIS

  use Raygun4perl::Message::Request;

  # synopsis...

=head1 DESCRIPTION

# longer description...


=head1 INTERFACE

=cut

subtype 'RawData' => as 'Str';    # => where {};

coerce 'RawData' => from 'Str' => via {
    my $rawData = $_;
    open my $fh, '<:bytes', \$rawData;
    read $fh, my $truncated, 4096;
    return $truncated;
};

has host_name => (
    is  => 'rw',
    isa => 'Str',
);

has url => (
    is  => 'rw',
    isa => 'Str',
);

has http_method => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return 'GET';
    }
);

has ip_address => (
    is  => 'rw',
    isa => 'Str',
    default => sub {
        return '127.0.0.1';
    }
);

has query_string => (
    is  => 'rw',
    isa => 'Str',
    default => sub {
        return '';
    }
);

has raw_data => (
    is     => 'rw',
    isa    => 'RawData',
    coerce => 1
);

has headers => (
    is	    => 'rw',
    isa 	=> 'HashRef',
    default => sub {
        return {};
    },
);



=head2 prepare_for_api

Return the data structure that will be sent to raygun.io.

=cut

sub prepare_for_api {
    my $self = shift;
    return {
        #ipAddress => undef,
        #hostName => undef,
        url => $self->url,
        httpMethod => $self->http_method,
        queryString => $self->query_string,
        headers => $self->headers,
        rawData => $self->raw_data,
    };
}

=head1 DEPENDENCIES


=head1 SEE ALSO

=cut

1;

__END__
