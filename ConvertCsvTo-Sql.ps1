param([parameter(mandatory=$true)]$CsvPath, $OutputFile)

# import lib functions
. "$psscriptroot/CsvToSql-Lib.ps1"

# required utils
require("awk")
require("sed")
require("wc")

# get number of lines
$nlines = $(get-content $CsvPath | wc -l)

# remove trailing whitespace from columns
$sed_trail_ws = "s:[ \t]*,:,:g"

# escape single quotes
$sed_single_quote = "s:\d039:\d039\d039:g"

# do the work
$csv_str = get-content $CsvPath | sed "$sed_trail_ws;$sed_single_quote"
$result = $csv_str | awk -f "$psscriptroot/csvtosql.awk" -v nlines=$nlines

if($OutputFile) {
  $result | out-file -encoding utf8 $OutputFile
}
else { $result }