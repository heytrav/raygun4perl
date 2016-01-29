
[![Build Status](https://travis-ci.org/heytrav/raygun4perl.svg?branch=master)](https://travis-ci.org/heytrav/raygun4perl)

WebService::Raygun
===========

Perl interface to the (Raygun API)[https://raygun.io] 


Synopsis
======

```perl
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
```



Notes
=====


Although this module should install without an API key from raygun.io, you will need one for it to be of any use. By default, it uses whatever is in the RAYGUN_API_KEY environment variable, but this is mainly so that the tests can be run without any user interaction.

