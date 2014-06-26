package Messenger;

use strict;
use warnings;

use parent qw(Test::Class);

use Test::More;
use Test::Deep;    # (); # uncomment to stop prototype errors
use Test::Exception;

use Smart::Comments;


sub prep001_messenger_available : Test(startup => 1) {
    my $self = shift;
    use_ok('Raygun4perl::Messenger') 
        or $self->FAIL_ALL('Messenger class not available.');

}

sub t0010_raygun_http_403_response :Test(3) {
    my $self = shift;
    my $messenger = Raygun4perl::Messenger->new(api_key => '');
    my $result;
    lives_ok {
        $result = $messenger->post_to_raygun( {} );
    }
    'Called Raygun.io';
    ### result : $result
    cmp_ok( $result->code, '==', 403, 'Expect a "Bad Request" error.' );
}


sub t0020_raygun_http_400_response : Test(2) {
    my $self = shift;
    my $api_key = $ENV{RAYGUN_API_KEY};
    if ( not defined $api_key ) {
        $self->SKIP_ALL('No API key for Raygun.io. No point in continuing.');
    }
    $self->{api_key} = $api_key;
    my $messenger = Raygun4perl::Messenger->new( api_key => $self->{api_key} );
    my $result;
    lives_ok {
        $result = $messenger->post_to_raygun( {} );
    }
    'Called Raygun.io';

    ### result : $result
    cmp_ok( $result->code, '==', 400, 'Expect a "Bad Request" error.' );

}


1;

__END__
