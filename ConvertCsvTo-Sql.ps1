param($CsvPath, $OutputFile)

# import lib functions
. "./CsvToSql-Lib.ps1"

# required utils
require("awk")
require("sed")
require("wc")

# get number of lines
$nlines = $(get-content $CsvPath | wc -l)

# do the work
$csv_str = get-content $CsvPath | sed 's:[ \t]*,:,:g; s:\d039:\d039\d039:g' 
$result = $csv_str | awk -f csvtosql.awk -v nlines=$nlines

if($OutputFile) {
  $result | out-file -encoding utf8 $OutputFile
}
else { $result }