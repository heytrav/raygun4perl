package WebService::Raygun::Message::Request;

use Mouse;
use Mouse::Util::TypeConstraints;

=head1 NAME

WebService::Raygun::Message::Request - Encapsulate the data in a typical HTTP request.

=head1 SYNOPSIS

  use WebService::Raygun::Message::Request;

  # synopsis...

=head1 DESCRIPTION

# longer description...


=head1 INTERFACE

=cut

subtype 'RawData' => as 'Str';    # => where {};

subtype 'Request' => as 'Object' => where {
    $_->isa('WebService::Raygun::Message::Request');
};

subtype 'HttpRequest' => as 'Object' => where {
    $_->isa('HTTP::Request');
};

subtype 'MojoliciousRequest' => as 'Object' => where {
    $_->isa('Mojo::Message::Request');
};

subtype 'CatalystRequest' => as 'Object' => where {
    $_->isa('Catalyst::Request');
};

coerce 'Request' => from 'HttpRequest' => via {
    my @header_names = $_->headers->header_field_names;
    my $headers;
    foreach my $header (@header_names) {
        my $value = $_->header($header);
        $headers->{$header} = $value;
    }
    my $query_string = $_->uri->query || '';

    return WebService::Raygun::Message::Request->new(
        url          => $_->uri->as_string,
        raw_data     => $_->as_string,
        headers      => $headers,
        http_method  => $_->method,
        query_string => $query_string,
    );
} => from 'MojoliciousRequest' => via {
    my $headers      = $_->headers->to_hash;
    my $query_params = $_->query_params;
    my $query_string = '';
    if (defined $query_params and $query_params->isa('Mojo::Parameters')) {
        $query_string = $query_params->to_string;
    }
    return WebService::Raygun::Message::Request->new(
        url          => $_->url->to_abs->path,
        http_method  => $_->method,
        raw_data     => $_->get_body_chunk,
        headers      => $headers,
        query_string => $query_string
    );
} => from 'CatalystRequest' => via {

    my @header_names = $_->headers->header_field_names;
    my $headers;
    foreach my $header (@header_names) {
        my $value = $_->header($header);
        $headers->{$header} = $value;
    }
    my $chunk;
    $_->read_chunk(\$chunk, 4096);
    my $query_string = $_->uri->query || '';
    return WebService::Raygun::Message::Request->new(
        ip_address   => $_->address,
        headers      => $headers,
        http_method  => $_->method,
        host_name    => $_->hostname,
        raw_data     => $chunk,
        query_string => $query_string,
    );
} => from 'HashRef' => via {
    return WebService::Raygun::Message::Request->new(%{$_});
};

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
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return '127.0.0.1';
    }
);

has query_string => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return '';
    }
);

has raw_data => (
    is     => 'rw',
    isa    => 'RawData|Undef',
    coerce => 1
);

has headers => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        return {};
    },
);

=head2 prepare_raygun

Return the data structure that will be sent to raygun.io.

=cut

sub prepare_raygun {
    my $self = shift;
    return {
        ipAddress   => $self->ip_address,
        hostName    => $self->host_name,
        url         => $self->url,
        httpMethod  => $self->http_method,
        queryString => $self->query_string,
        headers     => $self->headers,
        rawData     => $self->raw_data,
    };
}

=head1 DEPENDENCIES


=head1 SEE ALSO

=cut

1;

__END__
