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

use WebService::Raygun::Message::Error;
use WebService::Raygun::Message::Request;
use WebService::Raygun::Message::Environment;
use WebService::Raygun::Message::User

use Mouse::Util::TypeConstraints;

subtype 'RaygunMessage' => as 'Object' => where {
    $_->isa('WebService::Raygun::Message');
};

coerce 'RaygunMessage' => from 'HashRef' => via {
    return WebService::Raygun::Message->new(%{$_});
};

subtype 'OccurredOnDateTime' => as 'Object' => where {
    $_->isa('DateTime');
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

subtype 'RaygunUser' => as 'HashRef' => where {
    my $ref = ref $_;
    $ref eq 'HASH';
};

no Mouse::Util::TypeConstraints;

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

Some data from the user.

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

=head2 grouping_key 

=cut

has grouping_key => (
    is	    => 'rw',
    isa 	=> 'Str',
    default => '',
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
    my $data = {
        occurredOn => $occurred_on,
        details    => {
            groupingKey => $self->grouping_key,
            userCustomData => $self->user_custom_data,
            machineName    => $self->machine_name,
            error          => $self->error->prepare_raygun,
            version        => $self->version,
            client         => $self->client,
            request        => $self->request->prepare_raygun,
            environment    => $self->environment->prepare_raygun,
            tags           => $self->tags,
            user           => {
                identifier => $self->user
            },
            context => {
                identifier => undef
            },
            response => {
                statusCode => $self->response_status_code,
            }
        }
    };
    return $data;
}


=head1 DEPENDENCIES


=head1 SEE ALSO


=cut

1;

__END__
