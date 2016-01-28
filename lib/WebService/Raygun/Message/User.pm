package WebService::Raygun::Message::User;

use Mouse;
use Data::GUID 'guid_string';

=head1 NAME

WebService::Raygun::Message::User - Represent the I<User> data in a raygun request.

=head1 SYNOPSIS

    use WebService::Raygun::Message::User;
    my $user = WebService::Raygun::User->new(
        identifier   => 123456,
        email        => 'test@test.com',
        is_anonymous => undef,
        full_name    => 'Firstname Lastname',
        first_name   => 'Firstname',
        uuid         => '783491e1-d4a9-46bc-9fde-9b1dd9ef6c6e'
    );


=head1 DESCRIPTION

The user data is all optional and may be left blank. This class just
initialises them with empty strings or 1s or 0s depending on the context. The
L<prepare_raygun> method may be called to retreive the structure in a form
that can be converted directly to JSON.


=head1 INTERFACE

=cut


use Mouse::Util::TypeConstraints;
subtype 'User' => as 'Object' => where {
    $_->isa('WebService::Raygun::Message::User');
};

coerce 'User' => from 'HashRef' => via {
    return WebService::Raygun::Message::User->new(%{$_});
};
no Mouse::Util::TypeConstraints;

has identifier => (
    is      => 'rw',
    isa     => 'Str',
    default => '',
);

has email => (
    is      => 'rw',
    isa     => 'Str',
    default => '',
);

has is_anonymous =>
  ( is => 'rw', isa => 'Bool', default => sub { return; } );

has full_name => (
    is      => 'rw',
    isa     => 'Str',
    default => ''
);
has first_name => (
    is      => 'rw',
    isa     => 'Str',
    default => '',
);

has uuid =>
  ( is => 'rw', isa => 'Str', default => sub { return guid_string; } );

=head2 prepare_raygun

Return the data structure that will be sent to raygun.io

=cut

sub prepare_raygun {
    my $self = shift;
    return {
        identifier => $self->identifier,
        isAnonymous => $self->is_anonymous,
        email => $self->email,
        fullName => $self->full_name,
        firstName => $self->first_name,
        uuid => $self->uuid,
    };

}

=head1 DEPENDENCIES


=head1 SEE ALSO

=cut

1;

__END__
