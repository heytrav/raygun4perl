package WebService::Raygun;

=head1 NAME

WebService::Raygun - Connect to the Raygun.io API

=head1 SYNOPSIS

  use WebService::Raygun::Messenger;

    sub some_post_action {
        my ( $self, $request ) = @_;
        eval {
            # do something with request
            # ...
        };
        if ( my $exception = $@ ) {

            # see WebService::Raygun::Message for details
            # of request object.
            my $message = {
                error   => $exception,
                request => $request
                user  => 'null@null.com',
                client => {
                    name      => 'something',
                    version   => 2,
                    clientUrl => 'www.null.com'
                },
            };

            # initialise raygun.io messenger
            my $raygun = WebService::Raygun::Messenger->new(
                api_key => '<your raygun.io api key>',
                message => $message
            );
            # send message to raygun.io
            my $response = $raygun->fire_raygun;
        }
    }


=head1 DESCRIPTION

Interface for the Raygun.io API.


=head1 SEE ALSO

=over 2

=item L<WebService::Raygun::Messenger|WebService::Raygun::Messenger>

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

1;

__END__
