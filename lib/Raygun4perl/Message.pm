package Raygun4perl::Message;

use Mouse;

use DateTime;
use DateTime::Format::Strptime;

use Mouse::Util::TypeConstraints;

=head1 NAME

Raygun4perl::Message - A message to be sent to raygun.io

=head1 SYNOPSIS

  use Raygun4perl::Message;


  # The Raygun.io API expects something like this:
  my $data = {
        'occurredOn' => string,
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

# longer description...


=head1 INTERFACE

=cut

subtype 'MessageError' => as 'HashRef' => where {
    my $stack_trace  = $_->{stackTrace};
    my $stack_trace_type = ref $stack_trace;
    return unless defined $stack_trace_type and $stack_trace_type eq 'ARRAY';
    return unless @{$stack_trace};
} => message { "Error should have at least one stack trace." };

subtype 'OccurredOnDateTime' => as 'Object' =>  where {
    $_->isa('DateTime');
};

coerce 'OccurredOnDateTime' => from 'Str' => via {
    my $parser = DateTime::Format::Strptime->new( 
        pattern => '%FT%T%z' ,
        time_zone => 'UTC',
        on_error => sub {
           confess 'Expect time in the following format: yyyy-mm-ddTHH:MM:SS+HHMM';
        }
        
    );
    return $parser->parse_datetime($_);
};

has occurred_on => (
    is      => 'rw',
    isa     => 'OccurredOnDateTime',
    coerce  => 1,
    default => sub {
        return DateTime->now( time_zone => 'UTC' );
    },
);


has error => (
    is      => 'rw',
    isa     => 'MessageError',
);

=head2 _generate_message

Internal method which converts a Perl hash to JSON.

=cut

sub _generate_message {
    my ( $self, $raw ) = @_;
}

=head1 DEPENDENCIES


=head1 SEE ALSO


=cut

1;

__END__
