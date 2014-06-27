package WebService::Raygun;


=head1 NAME

WebService::Raygun - Connect to the Raygun.io API

=head1 SYNOPSIS

  use WebService::Raygun::Message;
  use WebService::Raygun::Messenger;

    my $message = WebService::Raygun::Message->new(
        user => 'null@null.com',
        client => {
            name      => 'something',
            version   => 2,
            clientUrl => 'www.null.com'
        },
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

    my $message = $message->arm_the_laser;
    my $raygun = WebService::Raygun::Messenger->new( api_key => '<your raygun.io api key>' );
    my $response = $raygun->fire_raygun($message);

=head1 DESCRIPTION

Interface for the Raygun.io API.


=head1 DEPENDENCIES

You will need to have an API key from raygun.io. By default, this module
checks C<$ENV{RAYGUN_API_KEY}>.

=over 2

=item DateTime

=back

=over 2

=item DateTime::Format::Strptime

=back

=over 2

=item Filesys::DfPortable 

=back

=over 2

=item HTTP::Request 

=back

=over 2

=item JSON 

=back

=over 2

=item LWP::UserAgent 

=back


=over 2

=item Mouse 

=back

=over 2

=item Mouse::Util::TypeConstraints 

=back

=over 2

=item Mozilla::CA 

=back

=over 2

=item POSIX 

=back

=over 2

=item Sys::Info 

=back

=over 2

=item Sys::Info::OS 

=back

=over 2

=item URI

=back

=over 2

=item Test::Class 

=back

=over 2

=item Test::Deep 

=back

=over 2

=item Test::Exception 

=back

=over 2

=item Test::More 

=back

=over 2

=item parent 

=back

=over 2

=item strict 

=back

=over 2

=item warnings

=back


=head1 SEE ALSO

=over 2

=item L<WebService::Raygun::Messenger|WebService::Raygun::Messenger>

=back

=over 2

=item L<WebService::Raygun::Message|WebService::Raygun::Message>

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
