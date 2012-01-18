#!/usr/bin/perl -w

#  Authors: Vitaly Repin (perl scripting), Mikhail Limanskii (SQL statements)

#  This file is part of Electorus.

#  Electorus is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.

#  Electorus is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with Electorus.  If not, see <http://www.gnu.org/licenses/>.

# Analyzes the database with protocols and produces user-friendly reports of different kind.


use strict;

use DBI;
use Chart::HorizontalBars;
use Text::Iconv;
use utf8;

# Database to connect to
my $db      = "Electorus";
# Database user with read-only access to the database
my $user    = "";
# (Database) User's password.
my $psw     = "";
# Directory to write reports to
my $path    = ".";

# To show russian labels in the diagrams. Temporary hack due to GD issue
my $conv = Text::Iconv->new("utf8", "koi-7");

# Outputs Region report to png file
# Params:
# #1: Region name
# #2: Reference to hash array with votes
sub gen_region_report($ $)
{
    my $current_region = shift;
    my $votes_ref = shift;

    my $obj = Chart::HorizontalBars->new (1400, 600);
    $obj->set ('title' => "!!!! DEVELOPERS DEMO: " . $conv->convert(uc($current_region)));
    
    my $subtitle;

    foreach(keys %$votes_ref) {
            $obj->add_pt ($conv->convert(uc($_)), $votes_ref->{$_});
            $subtitle .= $conv->convert(uc($_)) . ": " . $votes_ref->{$_} . "; ";
    };
    $obj->set('sub_title' => $subtitle);
    my $fname = $current_region . ".png";
    print "Output: $fname\n";
    $obj->png ($current_region . ".png");
};

# SQL statement author: Mikhail Limanskii
my $sql_votes_by_region =   "SELECT R.name region, SUM(P.Electors_qty) electors_qty, C.Name candidate, sum(Value) votes_qty " .
                            "FROM Votes, Candidates AS C, Committees AS Co, Regions AS R, Protocols AS P " .
                            "WHERE C.Id = Candidates_id " .
                            "AND Votes.Protocols_id = P.id " .
                            "AND P.Committees_id = Co.Id " .
                            "AND Co.Regions_id = R.Id " .
                            "GROUP BY R.id, Candidates_id";

# Connect to the database.
my $dbh = DBI->connect("DBI:mysql:database=$db;host=localhost",
                         $user, $psw,
                         {'RaiseError' => 1});

my $sth = $dbh->prepare($sql_votes_by_region);
$sth->execute();

my $current_region = '';
# Votes per candidate. Key: candidate. Value: Votes qty
my %votes;

# Processing the regions
while (my $ref = $sth->fetchrow_hashref()) {
    my $region  = $ref->{'region'};
    if ($region ne $current_region) {
        # Region changed. Process the data and clear all the structs after
        if($current_region ne '') { # Ignoring 1st switch from empty region
            gen_region_report($current_region, \%votes);
        };
        $current_region = $region;
        %votes = ();
    };

    my $cand    = $ref->{'candidate'};
    $votes{$cand} = $ref->{'votes_qty'};
}

# Processing the last region
gen_region_report($current_region, \%votes);

$sth->finish();

# Disconnect from the database.
$dbh->disconnect();
