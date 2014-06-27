package WebService::Raygun::Messenger;

use Mouse;

use LWP::UserAgent;
use URI;
use Mozilla::CA;
use JSON;

#use Smart::Comments;

=head1 NAME

WebService::Raygun::Messenger - Communicate with the Raygun.io endpoint.

=head1 SYNOPSIS

  use WebService::Raygun::Messenger;

  my $raygun = WebService::Raygun::Messenger->new(api_key => 'your key here');
  my $response = $raygun->fire_raygun($raygun_message);
  # $response->status == ?

=head1 DESCRIPTION

Send a request to raygun.io.

=head1 INTERFACE

=cut

has api_key => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

has api_endpoint => (
    is      => 'ro',
    isa     => 'URI',
    default => sub {
        return URI->new('https://api.raygun.io/entries');
    },
);

has user_agent => (
    is      => 'ro',
    isa     => 'LWP::UserAgent',
    default => sub {
        return LWP::UserAgent->new(
            ssl_opts => { SSL_ca_file => Mozilla::CA::SSL_ca_file() } );
    },
);

=head2 fire_raygun

Send data to api.raygun.io/entries via a POST request.

=cut

sub fire_raygun {
    my ( $self, $message ) = @_;
    my $uri     = $self->api_endpoint;
    my $ua      = $self->user_agent;
    my $api_key = $self->api_key;
    my $json = JSON->new->allow_nonref;
    my $jsoned =$json->pretty->encode($message);
    my $req = HTTP::Request->new(POST => $uri);
    $req->header('Content-Type' => 'application/json');
    $req->header('X-ApiKey' => $api_key);
    $req->content($jsoned);
    ### json message : $jsoned;
    my $response = $ua->request($req);

    #my $response =
      #$ua->post( $uri, 'X-ApiKey' => $api_key, Content => [ $jsoned ] );
    return $response;

}



1;

__END__