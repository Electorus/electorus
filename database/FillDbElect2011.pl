#!/usr/bin/perl -w

#  Author: Vitaly Repin

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

# Produces SQL script to populate the database with Russian Parliament's elections of year 2011.

use strict;
use Text::CSV::Encoded;
use utf8;
binmode STDOUT, ':utf8';

# Name of the file with the Elections 2011 results
my $results = "./p2011.csv";

my %candidates = ("Справедливая Россия" => 1, "ЛДПР" => 2, "Патриоты России" => 3, "КПРФ" => 4, "ЯБЛОКО" => 5, "Единая Россия" => 6, "Правое дело" => 7);

# Initialization of the Elections and Candidates tables. The database is supposed to be empty!
sub print_init()
{
  print "SET autocommit=0;\n";
  print "USE Electorus;\n";

  print "DELETE FROM Votes WHERE (Candidates_id <8) AND (Candidates_id > 0);\n";
  print "DELETE FROM Candidates WHERE Elections_id = 1;\n";
  print "DELETE FROM Elections WHERE Id=1;\n";
  print "INSERT INTO Elections (Id, Name, Date) VALUES (1, \"Выборы в Гос. Думу 2011\", \"04122011\");\n";

  foreach (keys %candidates) {
    print "INSERT INTO Candidates (Id, Name, Elections_id) VALUES (" .  $candidates{$_} . ", \"" . $_ . "\", 1);\n";
  };

  print "DELETE FROM Protocols;\n";
  print "DELETE FROM Regions;\n";
  print "DELETE FROM Committees;\n";
  print "DELETE FROM Communities;\n";
  print "INSERT INTO Communities (Id, Name) VALUES (1, \"Даннные ЦИК. Импорт из CSV-файла с сайта Ассоциации 'Голос'\");\n";
};

print_init();

open(RES, "< $results")
        or die "Couldn't open $results for reading: $!\n";

my $csv = Text::CSV::Encoded->new ({
                    sep_char => ';',
                    encoding_in  => "cp1251", # CSV file is cp1251 encoded
                    encoding_out => "utf8"
          }) or die "" . Text::CSV::Encoded->error_diag ();

# Skipping first line
<RES>;

# Protocol's id
my $prot_id = 1;
# Vote's id
my $vote_id = 1;
# Region's id
my $region_id = 1;
# Regions's table. Keeping in memory while executing the script
my %regions;
# Committee's id
my $comm_id = 1;
# There are 2 columns for committee in CSV. Higher committee and lower :-)
# 1 entry per committee. Yes, this is bad from memory consumption PoV.
# Used only in initial database population script!
my %comms_lo;
my %comms_hi;
# Line counter. To make periodic commits
my $line_qty = 0;

while (<RES>) {
   if ($csv->parse($_)) {
        my @columns = $csv->fields();
        # Inserting Region if it was not seen before
        my $region = $columns[3];
        my $cur_reg_id = $region_id;
        if (!exists($regions{$region})) {
            $regions{$region} = $region_id;
            print "INSERT INTO Regions (Id, Name) VALUES (" . $region_id++ . ", \"$region\");\n";
        } else {
            $cur_reg_id = $regions{$region};
        };

        # Inserting Committee if it was not seen before
        my $c_lo = $columns[0];
        my $c_hi = $columns[1];
        if (!exists($comms_hi{$c_hi})) {
            $comms_hi{$c_hi} = $comm_id;
            print "INSERT INTO Committees (Id, Parent_id, Name, Regions_id) VALUES (" . $comm_id++;
            print ", NULL, \"$c_hi\", $cur_reg_id);\n";
        };
        if (!exists($comms_lo{$c_lo})) {
            $comms_lo{$c_lo} = $comm_id;
            print "INSERT INTO Committees (Id, Parent_id, Name, Regions_id) VALUES (" . $comm_id++;
            print ", " . $comms_hi{$c_hi} . ", \"$c_lo\", $cur_reg_id);\n";
        };
        # Inserting "УИК" record (the lowest committee layer). Protocols are produced by "УИК"
        my $cur_comm_id = $comm_id;
        print "INSERT INTO Committees (Id, Parent_id, Name, Regions_id) VALUES (" . $comm_id++;
        print ", " . $comms_lo{$c_lo} . ", \"УИК N " . $columns[4] . "\", $cur_reg_id);\n";
        # Inserting protocol record
        print "INSERT INTO Protocols (Id, Name, User_id, Scan, Committees_id, Communities_id, Elections_Id, ";
        print "Electors_qty, Electors_remote_qty, Ballot_total_qty, Ballot_early_qty, Ballot_regular_qty, ";
        print "Ballot_outdoor_qty, Ballot_deactive_qty, Ballot_mobile_qty, Ballot_land_qty, Ballot_wrong_qty, ";
        print "Ballot_right_qty, Ballot_lost_qty, Remote_doc_rcvd_qty, Remote_doc_given_qty, Remote_doc_unused_qty, ";
        print "Remote_doc_given_upper_layer_qty, Remote_doc_lost_qty, Ballot_not_accounted_qty) VALUES (";
        my $name = "Протокол УИК N " . $columns[4] . ". Регион: '" . $region . "', комиссия: '" . $c_lo;
        $name .= "', вышестоящая комиссия: '" . $c_hi . "'";
        print $prot_id . ", \" $name . \", 1, NULL, $cur_comm_id, "; # Id, Name, User_id, Scan, Committees_id
        print "1, 1, "; # Communities_id, Elections_id
        print $columns[5] . ", ";   # Electors_qty
        print $columns[17] . ", ";  # Electors_remote_qty
        print $columns[6] . ", ";   # Ballot_total_qty
        print $columns[7] . ", ";   # Ballot_early_qty
        print $columns[8] . ", ";   # Ballot_regular_qty
        print $columns[9] . ", ";   # Ballot_outdoor_qty
        print $columns[10] . ", ";  # Ballot_deactive_qty
        print $columns[11] . ", ";  # Ballot_mobile_qty
        print $columns[12] . ", ";  # Ballot_land_qty
        print $columns[13] . ", ";  # Ballot_wrong_qty
        print $columns[14] . ", ";  # Ballot_right_qty
        print $columns[21] . ", ";  # Ballot_lost_qty
        print $columns[15] . ", ";  # Remote_doc_rcvd_qty
        print $columns[16] . ", ";  # Remote_doc_given_qty
        print $columns[18] . ", ";  # Remote_doc_unused_qty
        print $columns[19] . ", ";  # Remote_doc_given_upper_layer_qty
        print $columns[20] . ", ";  # Remote_doc_lost_qty
        print $columns[22] . ");\n";# Ballot_not_accounted_qty
        # Inserting votes records for the current protocol
        for (my $cand_id = 23; $cand_id < 30; $cand_id++) {
            print "INSERT INTO Votes (Id, Value, Candidates_id, Protocols_id) VALUES (";
            print $vote_id++ . ", " . $columns[$cand_id] . ", " . ($cand_id - 22) . ", $prot_id);\n";
        };
        $prot_id++;
        $line_qty++;
        if($line_qty > 400) {
            print "COMMIT;\n";
            $line_qty = 0;
        };
   } else {
        my $err = $csv->error_input;
        print "Failed to parse line: $err";
   }
};

close RES;

print "COMMIT;\n";
