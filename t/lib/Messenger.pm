package Messenger;

use strict;
use warnings;

use parent qw(Test::Class);

use Test::More;
use Test::Deep;    # (); # uncomment to stop prototype errors
use Test::Exception;

use Smart::Comments;

#__PACKAGE__->SKIP_CLASS(1);

sub prep001_api_key_check : Test(startup) {
    my $self = shift;

    my $api_key = $ENV{RAYGUN_API_KEY};
    if ( not defined $api_key ) {
        $self->SKIP_ALL('No API key for Raygun.io. No point in continuing.');
    }
    $self->{api_key} = $api_key;
}

sub t0010_raygun_http_response : Test(3) {
    my $self = shift;
    use_ok('Raygun4perl::Messenger');
    my $messenger = Raygun4perl::Messenger->new( api_key => $self->{api_key} );
    my $result;
    lives_ok {
        $result = $messenger->post_to_raygun( {} );
    }
    'Called Raygun.io';

    ### result : $result
    cmp_ok( $result->code, '==', 400, 'Expect a "Bad Request" error.' );

}

sub t0020_form_raygun_message : Test(3) {
    my $self = shift;
    use_ok('Raygun4perl::Message');
    my $message;
    lives_ok {
        $message =
          Raygun4perl::Message->new( occurred_on => '2014-06-27T03:15:10' );
    }
    'Instantiated Message object.';
    my $occurred_on = $message->occurred_on;
    isa_ok( $occurred_on, 'DateTime', 'Correct object' );

}

1;

__END__
