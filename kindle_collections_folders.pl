#!/usr/bin/perl
# Rebuild the contents of the collections.json file using the folder structure of a Kindle DX.
#
# 1: Mount the device (/mnt in this example)
# 2: Backup the collections.json file if you want.
# 2: perl kindle_collections.pl /mnt > /mnt/system/collections.json (use the apropiated paths)
# 3: Reboot the device (Home->Menu->Settings->Menu->restart)

use strict;
use File::Find;
use Digest::SHA1 qw(sha1_hex);

my $dir = $ARGV[0] || $ENV{PWD};
my $hash = undef;

sub find_books {
    if ( -f $_) {
        my $file = $File::Find::name; # devuelve el fichero con ruta entera
        if ($file =~ m@(documents.*\.(:?pdf|mobi|txt|azw))$@i) {
            my ($item) = "/mnt/us/$1";
            my @array = split("/", $file);
            my $collection = @array[-2];
            $hash->{ucfirst(lc($collection))}->{sha1_hex($item)} = $item;
        }
    }
}

find(\&find_books, $dir);

print "{\"".join (',"', map {"$_\@en-US\":{\"items\":[\"*".join ('","*', keys %{$hash->{$_}})."\"],\"lastAccess\":0}"} sort keys %{$hash})."}";
