# CsvToSql

Converts a comma delimitered CSV to a MSSQL script. 

## Requires

* awk, sed, wc - (found in [GNU on Windows](https://github.com/bmatzelle/gow), [Scoop](https://scoop.sh) (`scoop install gow`) or [Cygwin](https://www.cygwin.com/))
* Powershell

## Usage

`./ConvertCsvTo-Sql -CsvPath <path/to/csv> -OutputFile <path/to/output>`

If `-OutputFile` is omitted it will just write to stdout. 
