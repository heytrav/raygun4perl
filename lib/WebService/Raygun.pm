package WebService::Raygun;

# VERSION

=head1 NAME

=for HTML <a href="https://travis-ci.org/heytrav/raygun4perl"><img src="https://travis-ci.org/heytrav/raygun4perl.svg?branch=master"></a>

WebService::Raygun - Connect to the Raygun.io API

=head1 SYNOPSIS

  use Try::Tiny;
  use WebService::Raygun::Messenger;

    sub some_code {
        my ( $self, $request ) = @_;
        try {
            # do something with request
            # ...
        }
        catch {
            my $exception = $_;

            # see WebService::Raygun::Message for details
            # of request object.
            my $message = {
                error   => $exception,
                request => $request
                user  => 'null@null.com',
            };

            # initialise raygun.io messenger
            my $raygun = WebService::Raygun::Messenger->new(
                api_key => '<your raygun.io api key>',
                message => $message
            );
            # send message to raygun.io
            my $response = $raygun->fire_raygun;
            
        };
    }



=head1 DESCRIPTION

Send error data to L<Raygun.io|https://raygun.io>

=head1 SEE ALSO

=over 2

=item L<WebService::Raygun::Messenger|WebService::Raygun::Messenger>

The entry point to actually I<use> this.

=back

=over 2

=item L<WebService::Raygun::Message|WebService::Raygun::Message>

Constructs the actual message. See this class for a better description of the fields available or required for the raygun.io API.

=back

=over 2

=item L<WebService::Raygun::Message::Request|WebService::Raygun::Message::Request>

=back

=over 2

=item L<WebService::Raygun::Message::Environment|WebService::Raygun::Message::Environment>

=back

=over 2

=item L<WebService::Raygun::Message::Error|WebService::Raygun::Message::Error>

=back

=over 2

=item L<WebService::Raygun::Message::Error::StackTrace|WebService::Raygun::Message::Error::StackTrace>

=back

=cut

use strict;
use warnings;

1;

__END__
