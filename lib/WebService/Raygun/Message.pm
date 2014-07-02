package WebService::Raygun::Message;

use Mouse;

=head1 NAME

WebService::Raygun::Message - A message to be sent to raygun.io

=head1 SYNOPSIS

  use WebService::Raygun::Message;


  # The Raygun.io API expects something like this:
  my $data = {
        'occurredOn' => string, # ISO 8601
        'details'    => {
            'machineName' => string,
            'version'     => string,
            'client'      => {
                'name'      => string,
                'version'   => string,
                'clientUrl' => string
            },
            'error' => {
                'innerError' => string,
                'data'       => object,
                'className'  => string,
                'message'    => string,
                'stackTrace' => [
                    {
                        'lineNumber' => number,
                        'className'  => string,
                        'fileName'   => string,
                        'methodName' => string,
                    }
                ]
            },
            'environment' => {
                'processorCount'          => number,
                'osVersion'               => string,
                'windowBoundsWidth'       => number,
                'windowBoundsHeight'      => number,
                'resolutionScale'         => string,
                'currentOrientation'      => string,
                'cpu'                     => string,
                'packageVersion'          => string,
                'architecture'            => string,
                'totalPhysicalMemory'     => number,
                'availablePhysicalMemory' => number,
                'totalVirtualMemory'      => number,
                'availableVirtualMemory'  => number,
                'diskSpaceFree'           => array,
                'deviceName'              => string,
                'locale'                  => string,
            },
            'tags'           => array,
            'userCustomData' => object,
            'request'        => {
                'hostName'    => string,
                'url'         => string,
                'httpMethod'  => string,
                'iPAddress'   => string,
                'queryString' => object,
                'form'        => object,
                'headers'     => object,
                'rawData'     => object,
            },
            'response' => {
                'statusCode' => number
            },
            'user' => {
                'identifier' => string
            },
            'context' => {
                'identifier' => string
            }
        }
    };

=head1 DESCRIPTION

This module assembles a request for raygun.io.


=head1 INTERFACE

=cut

use DateTime;
use DateTime::Format::Strptime;
use POSIX ();

use Mouse::Util::TypeConstraints;
use WebService::Raygun::Message::Error;
use WebService::Raygun::Message::Request;
use WebService::Raygun::Message::Environment;

subtype 'MessageError' => as 'Object' => where {
    $_->isa('WebService::Raygun::Message::Error');
};

subtype 'OccurredOnDateTime' => as 'Object' => where {
    $_->isa('DateTime');
};

subtype 'Request' => as 'Object' => where {
    $_->isa('WebService::Raygun::Message::Request');
};

subtype 'Environment' => as 'Object' => where {
    $_->isa('WebService::Raygun::Message::Environment');
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

subtype 'MooseException' => as 'Object' => where {
    $_->isa('Moose::Exception');
};

subtype 'MojoException' => as 'Object' => where {
    $_->isa('Mojo::Exception');
};

subtype 'DevelStacktrace' => as 'Object' => where {
    $_->isa('Devel::StackTrace');
};

coerce 'OccurredOnDateTime' => from 'Str' => via {
    my $parser = DateTime::Format::Strptime->new(
        pattern   => '%FT%T%z',
        time_zone => 'UTC',
        on_error  => sub {
            confess
                'Expect time in the following format: yyyy-mm-ddTHH:MM:SS+HHMM';
        });
    return $parser->parse_datetime($_);
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

coerce 'Environment' => from 'HashRef' => via {
    return WebService::Raygun::Message::Environment->new(%{$_});
};

coerce 'MessageError' => from 'HashRef' => via {
    return WebService::Raygun::Message::Error->new(%{$_});
} => from 'DevelStacktrace' => via {
    my $stack_trace = __PACKAGE__->_iterate_stack_trace_frames($_);
    return WebService::Raygun::Message::Error->new(
        class_name  => (ref $_),
        stack_trace => $stack_trace,
    );
} => from 'MooseException' => via {
    my $trace       = $_->trace;
    my $stack_trace = __PACKAGE__->_iterate_stack_trace_frames($trace);

    return WebService::Raygun::Message::Error->new(
        class_name  => (ref $_),
        message     => $_->message,
        stack_trace => $stack_trace,
    );
} => from 'MojoException' => via {

    # Very basic for now since I can't find docs on what the frames look like
    # in Mojo::Exception.
    my $stack_trace = [ { line_number => $_->line, } ];
    return WebService::Raygun::Message::Error->new(
        class_name  => (ref $_),
        message     => $_->message,
        stack_trace => $stack_trace,
    );
} => from 'ArrayRef[Str]' => via {
    my $error_text = join "\n" => @{$_};
    my ($message, $stack_trace) = @{__PACKAGE__->_parse_exception_line($error_text)};

    return WebService::Raygun::Message::Error->new(
        stack_trace => $stack_trace,
        message     => $message,
    );

} => from 'Str' => via {
    my $error_text      = $_;
    my ($message, $stack_trace) = @{__PACKAGE__->_parse_exception_line($error_text)};

    return WebService::Raygun::Message::Error->new(
        stack_trace => $stack_trace,
        message     => $message,
    );
};

=head2 _parse_exception_line

Parse a text line into bits for a typical error.

=cut

sub _parse_exception_line {
    my ($self, $error_text) = @_;
    my $exception_regex = qr{
        ^\s*(?<message> (?: (?! \sat\s [^\s]+ \s line).)*)
        \sat\s(?<filename> (?: (?! \sline\s\d+).)* )
        \sline\s(?<line>\d+)[^\d]*$
    }xsm;
    my ($message, $stack_trace);
    while ($error_text =~ /$exception_regex/g) {
        $message = $+{message} unless $message;
        push @{$stack_trace}, {
            line_number => $+{line},
            file_name   => $+{filename} };
    }
    $message = $error_text unless $message;
    if (not $stack_trace) {
        $stack_trace = [ { line_number => 1 } ];
    }
    return [$message, $stack_trace];
}

=head2 occurred_on

Must be a valid datetime with timezone offset; eg 2014-06-30T04:30:30+100. Defaults to current time.

=cut

has occurred_on => (
    is      => 'rw',
    isa     => 'OccurredOnDateTime',
    coerce  => 1,
    default => sub {
        return DateTime->now(time_zone => 'UTC');
    },
);

=head2 error


An instance of
L<WebService::Raygun::Message::Error|WebService::Raygun::Message::Error>. The
module uses L<Mouse type constraints|Mouse::Util::TypeConstraints> to coerce
the argument into a L<stacktrace|WebService::Raygun::Message::Error> object.
This is a bit experimental and currently L<Moose::Exception|Moose::Exception>,
L<Mojo::Exception|Mojo::Exception> are supported.

=cut

has error => (
    is     => 'rw',
    isa    => 'MessageError',
    coerce => 1,
);

=head2 user

Can be an email address or some other identifier. Note that if an email address is used, raygun.io will try to find a suitable Gravatar to display in the results.

=cut

has user => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return $ENV{'RAYGUN_API_USER'} // '';
    });

=head2 request

See L<WebService::Raygun::Message::Request|WebService::Raygun::Message::Request>.


=cut

has request => (
    is     => 'rw',
    isa    => 'Request',
    coerce => 1,
);

=head2 environment


See L<WebService::Raygun::Message::Environment|WebService::Raygun::Message::Environment>.


=cut

has environment => (
    is      => 'rw',
    isa     => 'Environment',
    coerce  => 1,
    default => sub {
        return {};
    });

=head2 user_custom_data



=cut

has user_custom_data => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        return {};
    },
);

=head2 tags


=cut

has tags => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub {
        return [];
    },
);

=head2 client


=cut

has client => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        return {};
    },
);

=head2 version


=cut

has version => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return '0.1';
    },
);

=head2 machine_name


=cut

has machine_name => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return (POSIX::uname)[1];
    },
);

=head2 response_status_code

Default is 200.

=cut

has response_status_code => (
    is      => 'rw',
    isa     => 'Int',
    default => sub {
        return 200;
    },
);

=head2 prepare_raygun

Converts a Perl hash to JSON.

=cut

sub prepare_raygun {
    my $self      = shift;
    my $formatter = DateTime::Format::Strptime->new(
        pattern   => '%FT%TZ',
        time_zone => 'UTC',
    );
    my $occurred_on = $formatter->format_datetime($self->occurred_on);
    my $data        = {
        occurredOn => $occurred_on,
        details    => {
            userCustomData => $self->user_custom_data,
            machineName    => $self->machine_name,
            error          => $self->error->prepare_raygun,
            version        => $self->version,
            client         => $self->client,
            request        => $self->request->prepare_raygun,
            environment    => $self->environment->prepare_raygun,
            user           => {
                identifier => $self->user
            },
            context => {
                identifier => undef
            },
            response => {
                statusCode => $self->response_status_code,
            } } };
    return $data;
}

=head2 _iterate_stack_trace_frames

Iterate over frames in a L<Devel::StackTrace|Devel::StackTrace> like object.

=cut

sub _iterate_stack_trace_frames {
    my ($self, $trace) = @_;
    my $stack_trace = [];

    while (my $frame = $trace->next_frame) {
        push @{$stack_trace}, {
            line_number => $frame->line,
            class_name  => $frame->package,
            file_name   => $frame->filename,
            method_name => $frame->subroutine,
            };
    }
    return $stack_trace;
}

=head1 DEPENDENCIES


=head1 SEE ALSO


=cut

1;

__END__
