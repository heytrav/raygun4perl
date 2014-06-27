package Messenger;

use strict;
use warnings;

use parent qw(Test::Class);

use Test::More;
use Test::Deep;    # (); # uncomment to stop prototype errors
use Test::Exception;

use HTTP::Request;
use Smart::Comments;

sub prep001_messenger_available : Test(startup => 2) {
    my $self = shift;
    use_ok('Raygun4perl::Messenger')
      or $self->FAIL_ALL('Messenger class not available.');
    use_ok('Raygun4perl::Message')
      or $self->FAIL_ALL('Message class not available.');

}

sub t0010_raygun_http_403_response : Test(3) {
    my $self = shift;
    my $messenger = Raygun4perl::Messenger->new( api_key => '' );
    my $result;
    lives_ok {
        $result = $messenger->raygun_attack( {} );
    }
    'Called Raygun.io';
    ### result : $result
    cmp_ok( $result->code, '==', 403, 'Expect a "Bad Request" error.' );
}

sub t0020_raygun_http_400_response : Test(2) {
    my $self    = shift;
    my $api_key = $ENV{RAYGUN_API_KEY};
    if ( not defined $api_key ) {
        $self->SKIP_ALL('No API key for Raygun.io. No point in continuing.');
    }
    $self->{api_key} = $api_key;
    my $messenger = Raygun4perl::Messenger->new( api_key => $self->{api_key} );
    my $result;
    lives_ok {
        $result = $messenger->raygun_attack( {} );
    }
    'Called Raygun.io';

    cmp_ok( $result->code, '==', 400, 'Expect a "Bad Request" error.' );

}

sub t0030_raygun_http_ok : Test(2) {
    my $self    = shift;
    my $api_key = $self->{api_key};
    my $message = Raygun4perl::Message->new(
        client => {
            name      => 'something',
            version   => 2,
            clientUrl => 'www.null.com'
        },
        occurred_on => '2014-06-27T03:15:10+1300',
        error       => {
            stack_trace => [ { line_number => 34 } ]
        },
        environment => {
            processor_count       => 2,
            cpu                   => 34,
            architecture          => 'x84',
            total_physical_memory => 3
        },
        request => HTTP::Request->new(
            POST => 'https://www.null.com',
            [ 'Content-Type' => 'text/html', ]
        ),

    );

    my $ready_weapons = $message->prepare_for_api;
    my $messenger = Raygun4perl::Messenger->new( api_key => $self->{api_key} );
    my $response;
    lives_ok {
        $response = $messenger->raygun_attack($ready_weapons);
    }
    'Request worked ok';
    cmp_ok( $response->code, '<', 400, 'Expect OK response.' );

    ### response : $response

}

1;

__END__
