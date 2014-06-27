package Raygun4perl;


=head1 NAME

Raygun4perl - Connect to the Raygun.io API

=head1 SYNOPSIS

  use Raygun4perl::Message;
  use Raygun4perl::Messenger;

    my $message = Raygun4perl::Message->new(
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
    my $raygun = Raygun4perl::Messenger->new( api_key => '<your raygun.io api key>' );
    my $response = $raygun->fire_the_laser($message);

=head1 DESCRIPTION

Interface for the Raygun.io API.


=head1 DEPENDENCIES

You will need to have an API key from raygun.io. By default, this module
checks C<$ENV{RAYGUN_API_KEY}>.

=over 2

=item DateTime => 0,

=back

=over 2

=item DateTime::Format::Strptime => 0,

=back

=over 2

=item Filesys::DfPortable => 0,

=back

=over 2

=item HTTP::Request => 0,

=back

=over 2

=item JSON => 0,

=back

=over 2

=item LWP::UserAgent => 0,

=back


=over 2

=item Mouse => 0,

=back

=over 2

=item Mouse::Util::TypeConstraints => 0,

=back

=over 2

=item Mozilla::CA => 0,

=back

=over 2

=item POSIX => 0,

=back

=over 2

=item Sys::Info => 0,

=back

=over 2

=item Sys::Info::OS => 0,

=back

=over 2

=item URI => 0

=back

=over 2

=item Test::Class => 0,

=back

=over 2

=item Test::Deep => 0,

=back

=over 2

=item Test::Exception => 0,

=back

=over 2

=item Test::More => 0,

=back

=over 2

=item parent => 0,

=back

=over 2

=item strict => 0,

=back

=over 2

=item warnings => 0

=back


=head1 SEE ALSO

=over 2

=item L<Raygun4perl::Messenger|Raygun4perl::Messenger>

=back

=over 2

=item L<Raygun4perl::Message|Raygun4perl::Message>

=back

=over 2

=item L<Raygun4perl::Message::Request|Raygun4perl::Message::Request>

=back

=over 2

=item L<Raygun4perl::Message::Environment|Raygun4perl::Message::Environment>

=back

=over 2

=item L<Raygun4perl::Message::Error|Raygun4perl::Message::Error>

=back

=over 2

=item L<Raygun4perl::Message::Error::StackTrace|Raygun4perl::Message::Error::StackTrace>

=back

=cut

1;

__END__
