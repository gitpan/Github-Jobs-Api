package Github::Jobs::Api;

use Moose;
use MooseX::Params::Validate;
use Moose::Util::TypeConstraints;
use namespace::clean;

use Carp;
use Data::Dumper;


use JSON;
use Readonly;
use HTTP::Request;
use LWP::UserAgent;


our $VERSION = '0.01';

Readonly my $BASE_URL    => "http://jobs.github.com/positions.json";

type 'TrueFalse'   	=> where { /\btrue\b|\bfalse\b/i };
has  'description'      => (is => 'ro', isa => 'Str', required => 1);
has  'full_time'     	=> (is => 'rw', isa => 'TrueFalse');
has  'location' 	=> (is => 'ro', isa => 'Str');
has  'lat'		=> (is => 'ro', isa => 'Str');
has  'long'		=> (is => 'ro', isa => 'Str');
has  'browser'		=> (is => 'rw', isa => 'LWP::UserAgent', default => sub { return LWP::UserAgent->new(); });


around BUILDARGS => sub
{
 my $orig  = shift;
 my $class = shift;
 if (@_ == 1 && ! ref $_[0])
 {
  return $class->$orig(description => $_[1]);
 }
 else {
  return $class->$orig(@_);
 }
};

sub BUILD
{
    my $self = shift;
    croak("ERROR: description must be specified.\n") unless ($self->description);
}

sub search
{
 my $self    = shift;
 my ($browser, $url, $request, $response, $content);
 $browser   = $self->browser;
 $url	= sprintf("%s?description=%s", $BASE_URL, $self->description);
 $url	.= sprintf("&full_time=%s", $self->full_time) if $self->full_time;
 $url	.= sprintf("&location=%s", $self->location) if $self->location;
 $url	.= sprintf("&lat=%s", $self->lat) if $self->lat;
 $url	.= sprintf("&long=%s", $self->long) if $self->long;
 $request  = HTTP::Request->new(GET => $url);
 $response = $browser->request($request);

 croak("ERROR: Couldn't fetch data [$url]:[".$response->status_line."]\n") unless $response->is_success;
 $content  = $response->content;
 croak("ERROR: No data found.\n") unless defined $content;
 return $content;
}

__PACKAGE__->meta->make_immutable;
no Moose;
no Moose::Util::TypeConstraints;

1;


__END__


=head1 NAME

 GitHub Jobs API - interface to GitHub Jobs API!

 =head1 VERSION

  Version 0.01

  =head1 SYNOPSIS

   Google::Shopping - The GitHub Jobs API allows you to search, view, and create jobs with JSON over HTTP.

   use strict;
use warnings;
use Data::Dumper;
use JSON::XS;

my $q ='perl';
my $str = Github::Jobs::Api->new(description=>$q);
my $get_v = $str->search();

#print Dumper($get_v);
my $decoded = JSON::XS::decode_json($get_v);
foreach my $items(@ {$decoded})
{
    print $items-> {title} . "----";
    print $items-> {company} . "\n";
}




=head1 AUTHOR

 Ovidiu Nita Tatar, C<< <ovn.tatar at gmail.com> >>

 =head1 BUGS

  Please report any bugs or feature requests to: https://github.com/ovntatar/GoogleShopping/issues

=head1 SUPPORT

 You can find documentation for this module with the perldoc command.

 perldoc Google::Shopping


 You can also look for information at: https://github.com/ovntatar/GoogleShopping

 or on the Google official api documnetation site: https://developers.google.com/shopping-search/v1/getting_started#filters


     =head1 ACKNOWLEDGEMENTS


      =head1 LICENSE AND COPYRIGHT

       Copyright 2013 Ovidiu Nita Tatar.

       This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.



