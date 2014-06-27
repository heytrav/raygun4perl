package Message;

use strict;
use warnings;

use parent qw(Test::Class);

use Test::More;
use Test::Deep;    # (); # uncomment to stop prototype errors
use Test::Exception;

use Smart::Comments;

sub prep001_message_available : Test(startup => 1) {
    my $self = shift;
    use_ok('Raygun4perl::Message')
      or $self->FAIL_ALL("Message class not available.");
}

sub t0010_validate_raygun_occurred_on : Test(3) {
    my $self = shift;
    my $message;
    lives_ok {
        $message =
          Raygun4perl::Message->new( occurred_on => '2014-06-27T03:15:10+1300',
          );
    }
    'Instantiated Message object.';
    my $occurred_on = $message->occurred_on;
    isa_ok( $occurred_on, 'DateTime', 'Occurred on argument' );

    throws_ok {
        $message =
          Raygun4perl::Message->new( occurred_on => '2014-06-27T03:15:10+200',
          );
    }
    qr{yyyy-mm-ddTHH:MM:SS\+HH},
      'Timestamp in incorrect format throws an error.';
}

sub t0020_validate_line_number : Test(4) {
    my $self = shift;
    my $message ;
    lives_ok {
        $message = Raygun4perl::Message->new(
            error => {
                stack_trace => [ { line_number => 34 } ]
            }
        );
    }
    'Instantiated Message object.';
    my $error = $message->error;
    isa_ok($error, 'Raygun4perl::Message::Error', 'Error is an error type');
    isa_ok($error->stack_trace->[0], 'Raygun4perl::Message::Error::StackTrace', 
    'Stack trace is the correct type.');
    throws_ok {
        Raygun4perl::Message->new(
            error => {
                stackTrace => [ {} ]
            }
        );
    }
    qr{one\sstack\strace}, 'Error thrown as expected.';
}

sub t0030_validate_environment : Test(3) {
    my $self    = shift;
    my $message = Raygun4perl::Message->new();
    lives_ok {
        $message->environment(
            {
                processor_count       => 2,
                cpu                   => 34,
                architecture          => 'x84',
                total_physical_memory => 3
            }
        );
    }
    'Set some environment fields';
    my $environment = $message->environment;
    isa_ok(
        $environment,
        'Raygun4perl::Message::Environment',
        'HashRef intantiated correct environment'
    );
    my $api_data = $environment->prepare_for_api;
    cmp_deeply(
        $api_data,
        superhashof(
            {
                processorCount      => 2,
                cpu                 => 34,
                architecture        => 'x84',
                totalPhysicalMemory => 3
            }
        ),
        'Received expected data for API'
    );

}

1;

__END__
