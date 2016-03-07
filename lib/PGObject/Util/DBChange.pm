package PGObject::Util::DBChange;

use 5.006;
use strict;
use warnings;

use strict;
use warnings;
use Digest::SHA;
use Cwd;
use Moo;

=head1 NAME

PGObject::Util::DBChange - The great new PGObject::Util::DBChange!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use PGObject::Util::DBChange;

    my $foo = PGObject::Util::DBChange->new();
    ...

=head1 PROPERTIES

=head2 path

Path to load content from -- Must be defined and '' or a string

=cut

has path => (is => 'ro'
             isa => sub { die 'path undefined' unless defined $_[0]; 
                          die 'references not allowed' if ref $_[0]; } );

=head2 content

Content of the file.  Can be specified at load, or is built by reading from the
file.

=cut

has content => (is => 'lazy');

sub _build_content {
    my ($self) = @_;
    my $file;
    local $!;
    open(FILE, '<', $self->path) or
        die 'FileError: ' . Cwd::abs_path($self->path) . ": $!";
    binmode FILE, ':utf8';
    $content = join '', <FILE>;
    close FILE;
    return $content;
}

=head2 dependencies

A list of other changes to apply first.  If strings are provided, these are
turned into path objects.

Currently these must be explicitly provided. Future bersions may read these from
comments in the files themselves.

=cut

has dependencies => (is => 'ro',
                     default => sub { [] },
                     isa => sub {  die 'dependencies must be an arrayref' 
                                           unless ref $_[0] =~ /ARRAY/;
                                   for (@{$_[0]}) {
                                       die 'dependency must be a PGObject::Util::Change object'
                                           unless eval { $_->isa(__PACKAGE__) };
                                   }
                           }
                    );
                                           

=head2 sha

The sha hash of the normalized content (comments and whitespace lines stripped)
of the file.

=cut

has sha => (is => 'lazy');

sub _build_sha {
    my ($self) = @_;
    my $content = $self->content; 
    my $normalized = join "\n",
                     grep { /\S/ }
                     map { my $string = $_; $string =~ s/--.*//; $string }
                     split("\n", $content);
    return Digest::SHA::sha512_base64($normalized);
}

=head2 begin_txn

Code to begin transaction, defaults to 'BEGIN;'

=cut

has begin_txn => is ('ro', default => 'BEGIN;');

=head2 commit_txn

Code to commit transaction, defaults to 'COMMIT;'

Useful if one needs to do two phase commit or similar

=cut

has commit_txn => is ('ro', default => 'COMMIT;');

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Chris Travers, C<< <chris.travers at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pgobject-util-dbchange at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PGObject-Util-DBChange>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PGObject::Util::DBChange


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=PGObject-Util-DBChange>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/PGObject-Util-DBChange>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/PGObject-Util-DBChange>

=item * Search CPAN

L<http://search.cpan.org/dist/PGObject-Util-DBChange/>

=back


=head1 ACKNOWLEDGEMENTS

Sedex Global sponsored part of this development.

=head1 LICENSE AND COPYRIGHT

Copyright 2016 The LedgerSMB Core Team.

This program is distributed under the (Revised) BSD License:
L<http://www.opensource.org/licenses/BSD-3-Clause>

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

* Neither the name of LedgerSMB
nor the names of its contributors may be used to endorse or promote
products derived from this software without specific prior written
permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of PGObject::Util::DBChange
