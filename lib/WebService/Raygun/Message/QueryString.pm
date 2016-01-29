package WebService::Raygun::Message::QueryString;

use Mouse;
use Data::GUID 'guid_string';

=head1 NAME

WebService::Raygun::Message::QueryString - Represent the I<QueryString> data in a raygun request.

=head1 SYNOPSIS

    use WebService::Raygun::Message::QueryString;
    my $user = WebService::Raygun::QueryString->new(
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

subtype 'RaygunQueryString' => as 'Object' => where {
    $_->isa('WebService::Raygun::Message::QueryString');
};

coerce 'RaygunQueryString' => from 'Str' => via {
    my $params = {};
    my @pairs = split/&/, $_;
    foreach my $pair (@pairs) {
        my ($key, $value) = split/=/, $pair;
        $params->{$key} = $value;
    }
    return WebService::Raygun::Message::QueryString->new(params => $params);
} =>  from 'HashRef' => via {
    return WebService::Raygun::Message::QueryString->new(params => $_);
};
no Mouse::Util::TypeConstraints;

has params => (
    is	    => 'rw',
    isa 	=> 'HashRef',
    default => sub {
        return {};
    },
);



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
