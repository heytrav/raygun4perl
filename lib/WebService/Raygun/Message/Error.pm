package WebService::Raygun::Message::Error;

use Mouse;


=head1 NAME

WebService::Raygun::Message::Error - Encapsulate the error part of the raygion.io request.

=head1 SYNOPSIS

  use WebService::Raygun::Message::Error;

=head1 DESCRIPTION

You shouldn't need to instantiate this class directly.

=head1 INTERFACE

=cut

use WebService::Raygun::Message::Error::StackTrace;

use Mouse::Util::TypeConstraints;
subtype 'MooseException' => as 'Object' => where {
    $_->isa('Moose::Exception');
};

subtype 'MojoException' => as 'Object' => where {
    $_->isa('Mojo::Exception');
};

subtype 'DevelStacktrace' => as 'Object' => where {
    $_->isa('Devel::StackTrace');
};
subtype 'MessageError' => as 'Object' => where {
    $_->isa('WebService::Raygun::Message::Error');
};

coerce 'MessageError' => from 'HashRef' => via {
    return WebService::Raygun::Message::Error->new(%{$_});
} => from 'DevelStacktrace' => via {
    my $stack_trace = __PACKAGE__->_iterate_stack_trace_frames($_);
    return WebService::Raygun::Message::Error->new(
        class_name  => (ref $_),
        stack_trace => $stack_trace,
    );
} => from 'MooseException' => via {
    my $trace       = $_->trace;
    my $stack_trace = __PACKAGE__->_iterate_stack_trace_frames($trace);

    return WebService::Raygun::Message::Error->new(
        class_name  => (ref $_),
        message     => $_->message,
        stack_trace => $stack_trace,
    );
} => from 'MojoException' => via {

    # Very basic for now since I can't find docs on what the frames look like
    # in Mojo::Exception.
    my $stack_trace = [ { line_number => $_->line, } ];
    return WebService::Raygun::Message::Error->new(
        class_name  => (ref $_),
        message     => $_->message,
        stack_trace => $stack_trace,
    );
} => from 'ArrayRef[Str]' => via {
    my $error_text = join "\n" => @{$_};
    my ($message, $stack_trace) = @{__PACKAGE__->_parse_exception_line($error_text)};

    return WebService::Raygun::Message::Error->new(
        stack_trace => $stack_trace,
        message     => $message,
    );

} => from 'Str' => via {
    my $error_text      = $_;
    my ($message, $stack_trace) = @{__PACKAGE__->_parse_exception_line($error_text)};

    return WebService::Raygun::Message::Error->new(
        stack_trace => $stack_trace,
        message     => $message,
    );
};

no Mouse::Util::TypeConstraints;

=head2 _parse_exception_line

Parse a text line into bits for a typical error.

=cut

sub _parse_exception_line {
    my ($self, $error_text) = @_;
    my $exception_regex = qr{
        ^\s*(?<message> (?: (?! \sat\s [^\s]+ \s line).)*)
        \sat\s(?<filename> (?: (?! \sline\s\d+).)* )
        \sline\s(?<line>\d+)[^\d]*$
    }xsm;
    my ($message, $stack_trace);
    while ($error_text =~ /$exception_regex/g) {
        $message = $+{message} unless $message;
        push @{$stack_trace}, {
            line_number => $+{line},
            file_name   => $+{filename} };
    }
    $message = $error_text unless $message;
    if (not $stack_trace) {
        $stack_trace = [ { line_number => 1 } ];
    }
    return [$message, $stack_trace];
}

has inner_error => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return '';
    },
);

has data => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        return {};
    },
);

has class_name => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return '';
    },
);

has message => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return '';
    },
);

has stack_trace => (
    is      => 'rw',
    isa     => 'ArrayOfStackTraces',
    coerce  => 1,
    default => sub {
        return [];
    },

    # other attributes
);

=head2 prepare_raygun

Prepare the error structure to be converted to JSON and sent to raygun.io.

=cut

sub prepare_raygun {
    my $self = shift;
    return {
        innerError => $self->inner_error,
        data       => $self->data,
        className  => $self->class_name,
        message    => $self->message,
        stackTrace => [ map { $_->prepare_raygun } @{ $self->stack_trace } ]
    };
}

=head2 _iterate_stack_trace_frames

Iterate over frames in a L<Devel::StackTrace|Devel::StackTrace> like object.

=cut

sub _iterate_stack_trace_frames {
    my ($self, $trace) = @_;
    my $stack_trace = [];

    while (my $frame = $trace->next_frame) {
        push @{$stack_trace}, {
            line_number => $frame->line,
            class_name  => $frame->package,
            file_name   => $frame->filename,
            method_name => $frame->subroutine,
            };
    }
    return $stack_trace;
}
=head1 DEPENDENCIES


=head1 SEE ALSO

=cut

1;

__END__
