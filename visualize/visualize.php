#!/usr/bin/php -q
<?php
/*
  Authors: Mikhail Limanskiy

  This file is part of Electorus.

  Electorus is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Electorus is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Electorus.  If not, see <http://www.gnu.org/licenses/>.

 Analyzes the database with protocols and produces user-friendly reports of different kind.
*/

    include("library/class/pData.class.php");
    include("library/class/pDraw.class.php");
    include("library/class/pImage.class.php");

    function drawGraph($name, $votes)
    {
        $ds = new pData;

        $t = array_sum($votes);
        $norm =
            function($v) use ($t)
            {
                return round($v * 100 / $t, 2);
            };
        $v = array_map($norm, $votes);
        $ds->AddPoints($v, "Votes");
        $ds->setAxisName(0, "Votes");
        $ds->setAxisUnit(0, "%");
        $ds->AddPoints(array_keys($votes), "Candidates");
        $ds->setSerieDescription("Candidates","Candidates");
        $ds->SetAbscissa("Candidates");

        // image size
        $w = 800; $h = 300;

        $gr = new pImage($w, $h, $ds);
        $gr->setShadow(TRUE);
        $gr->drawRoundedFilledRectangle(5, 5, $w - 5, $h - 5, 5, array("R" => 240, "G" => 240, "B" => 240));
        $gr->setFontProperties(array("FontName"=>"library/fonts/verdana.ttf", "FontSize"=>8));

        $palette = array("0"=>array("R"=>188,"G"=>224,"B"=>46,"Alpha"=>100),
                 "1"=>array("R"=>224,"G"=>100,"B"=>46,"Alpha"=>100),
                 "2"=>array("R"=>224,"G"=>214,"B"=>46,"Alpha"=>100),
                 "3"=>array("R"=>46,"G"=>151,"B"=>224,"Alpha"=>100),
                 "4"=>array("R"=>176,"G"=>46,"B"=>224,"Alpha"=>100),
                 "5"=>array("R"=>224,"G"=>46,"B"=>117,"Alpha"=>100),
                 "6"=>array("R"=>92,"G"=>224,"B"=>46,"Alpha"=>100),
                 "7"=>array("R"=>224,"G"=>176,"B"=>46,"Alpha"=>100));

        $gr->setGraphArea(50, 40, $w - 50, $h - 40);
        $gr->drawScale(array("CycleBackground"=>TRUE,"DrawSubTicks"=>TRUE,"GridR"=>0,"GridG"=>0,"GridB"=>0));
        $gr->drawBarChart(array("DisplayValues"=>TRUE, "DisplayPos"=>LABEL_POS_INSIDE, "OverrideColors"=>$palette));
        
        $gr->drawText(160, 10, $name, array("FontSize"=>12, "Align"=>TEXT_ALIGN_TOPMIDDLE));

        $gr->render("$name.png");
        echo("rendered $name.png\n");
    }

/*    drawGraph("test", array("Единая Россия" => 400, "КПРФ" => 325, "ЛДПР" => 123, "Правое дело" => 32, "Яблуко" => 45, "Справедливая Россия" => 111));
    exit(0);*/
    
    $dbName = "Electorus";
    $dbUser = "electorus";
    $dbPass = "qwe123";
    $dbHost = "localhost";

    $link = mysql_connect($dbHost, $dbUser, $dbPass) or die("Can not connect to SQL server: " . mysql_error());
    mysql_select_db($dbName) or die("Cannot select DB: " . mysql_error());
    
    $sql_votes_by_region =  "SELECT R.name region, SUM(P.Electors_qty) electors_qty, C.Name candidate, sum(Value) votes_qty " .
                            "FROM Votes, Candidates AS C, Committees AS Co, Regions AS R, Protocols AS P " .
                            "WHERE C.Id = Candidates_id " .
                            "AND Votes.Protocols_id = P.id " .
                            "AND P.Committees_id = Co.Id " .
                            "AND Co.Regions_id = R.Id " .
                            "GROUP BY R.id, Candidates_id";

    $result = mysql_query($sql_votes_by_region) or die ("Cannot get data: " . mysql_error());

    $current_rgn = "";
    $votes = array();
    while ($row = mysql_fetch_array($result))
    {
        if ($row["region"] != $current_rgn)
        {
            if ($current_rgn != "")
            {
                drawGraph($current_rgn, $votes);
                $votes = array();
            }
            $current_rgn = $row["region"];
        }

        $votes[$row["candidate"]] = $row["votes_qty"];
    }

    mysql_close($link);
?>
