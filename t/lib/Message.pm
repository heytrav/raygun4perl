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
        $message = Raygun4perl::Message->new(
            occurred_on => '2014-06-27T03:15:10+1300',
        );
    }
    'Instantiated Message object.';
    my $occurred_on = $message->occurred_on;
    isa_ok( $occurred_on, 'DateTime', 'Occurred on argument' );

    throws_ok {
        $message = Raygun4perl::Message->new(
            occurred_on => '2014-06-27T03:15:10+200',
        );
    }
    qr{yyyy-mm-ddTHH:MM:SS\+HH}, 'Timestamp in incorrect format throws an error.';
}

1;

__END__
