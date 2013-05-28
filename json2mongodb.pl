#!/usr/bin/perl
use strict;
use Data::Dumper;
use MongoDB;
use  Getopt::Long;
use JSON;
use Encode;
#use utf8;

($\,$,) =("\n-----\n",",");
my $port = '27017'; 
my $host = 'localhost'; 

GetOptions(
	'port|p=i' => \$port,
	'host|h=s' => \$host 
);

my $db = shift or die 'DB not specified'; 
my $col = shift or die 'Collection not specified'; 
my $src = shift or die 'JSON docs not specified'; 

my $json = JSON->new;

my $connection = MongoDB::Connection->new(host => $host, port => $port) or die 'Connection';
my $database   = $connection->get_database($db) or die 'DB';
my $collection = $database->get_collection($col) or die 'Collection';
sub import{
	open F, '<',shift;
	binmode F;
	my $file = <F>;
	close F;
	utf8::decode($file); #perl mongodb assume no utf8 encoding strings but the PERL internal representation 
	my $data = $json->decode($file);
	my $id         = $collection->insert($data) or warn 'File';
}


undef $/;
if (-e $src and -f $src){
	import $src;
	#doit $src;
}elsif(-d $src){
	opendir DIR, $src or die qq|Impossible to open $src|;
	my @files = grep {-f } map {qq|$src/$_|} readdir DIR;
	closedir DIR;
	foreach (@files){
		import $_;
	}	
}
