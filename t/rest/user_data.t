use Test::More;

use strict;
use warnings;

use HTTP::Request::Common;
use JSON;

use lib qw(t/lib);

use Test::WWW::Mechanize::Catalyst 'MyApp';

my $mech = Test::WWW::Mechanize::Catalyst->new();

$mech->add_header('Accept' => 'application/json');

my $res = $mech->request(POST '/user', [data => encode_json({name => 'bar', password => 'foo'})]);

ok(my $json = JSON::decode_json($res->content), 'response is JSON response');

is($json->{success}, 'true', 'submission was successful');
die;

is($res->header('location'), 'http://localhost/user/1', 'user location is set');

$mech->get_ok('/users', undef, 'request list of users');

ok($json = JSON::decode_json($mech->content), 'response is JSON response');

is($json->{results}, 1, 'one results');

$mech->get_ok('/user/1', undef, 'get user 1');

ok($json = JSON::decode_json($mech->content), 'response is JSON response');

is($json->{data}->{name}, 'bar', 'user name is "bar"');

my $request = POST '/user/1', [name => 'bas', password => 'foo'];
$request->method('PUT');  # don't use PUT directly because it won't pick up the form parameters

ok($mech->request($request), 'change user name');

ok($json = JSON::decode_json($mech->content), 'response is JSON response');

is($json->{success}, 'true', 'change was successful');

is($json->{data}->{name}, 'bas', 'user name has changed');

$request = POST '/user', [id => 1, name => 'bast', password => 'foo'];
$request->method('PUT');  # don't use PUT directly because it won't pick up the form parameters

ok($mech->request($request), 'change user name');

ok($json = JSON::decode_json($mech->content), 'response is JSON response');

is($json->{success}, 'true', 'change was successful');

is($json->{data}->{name}, 'bast', 'user name has changed');


$mech->get_ok('/user/1', undef, 'get user 1');

ok($json = JSON::decode_json($mech->content), 'response is JSON response');

is($json->{data}->{name}, 'bast', 'user name has changed');

$request = POST '/user/1', [name => 'bas', password => 'foo'];
$request->method('DELETE');  # don't use PUT directly because it won't pick up the form parameters

ok($mech->request($request), 'user deleted');

$request = GET '/user/1';
is($mech->request($request)->code, 404, 'has been deleted');

done_testing;