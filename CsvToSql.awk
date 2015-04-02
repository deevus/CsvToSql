BEGIN { FS="," }
{
  num_fields = csv_parse($0, row, ",", "\"", "''", "\\n", 1);
  # get header row names
  if (NR == 1) {
    num_fields = csv_parse($0, col, ",", "\"", "''", "\\n", 1);
  }
  # process every other row
	else {
    # start with select text
		printf "%s", "SELECT "

    # iterate each column value
    for (i = 1; i<=num_fields; i++) {
      printf "%s", "'" row[i] "' AS '" col[i] "'"

      # add a comma except for last row
      if (i < num_fields) printf "%s", ", "
    }

    # nlines is the number of lines in the file
    # so that we know when not to union
		if (NR != nlines) print " UNION ALL"
    else print "" # end with new line
	}
}

########################### AWK CSV Parser ###########################
#                                                                    #
#      ********** This file is in the public domain. **********      #
#                                                                    #
# Use this source in any way you wish.                               #
# Feedback and bug reports would be appreciated.                     #
# As would a note about what how you are using it.                   #
#                                                                    #
# For more information email LoranceStinson+csv@gmail.com.           #
# Or see http://lorance.freeshell.org/csv/                           #
#                                                                    #
######################################################################
function csv_parse(string,csv,sep,quote,escape,newline,trim, fields,pos,strtrim) {
    if (length(string) == 0) return 0
    string = sep string
    fields = 0
    while (length(string) > 0) {
        if (trim && substr(string, 2, 1) == " ") {
            if (length(string) == 1) return fields
            string = substr(string, 2)
            continue
        }
        strtrim = 0
        if (substr(string, 2, 1) == quote) {
            pos = 2
            do {
                pos++
                if (pos != length(string) &&
                    substr(string, pos, 1) == escape &&
                    index(quote escape, substr(string, pos + 1, 1)) != 0) {
                    string = substr(string, 1, pos - 1) substr(string, pos + 1)
                } else if (substr(string, pos, 1) == quote) {
                    strtrim = 1
                } else if (pos >= length(string)) {
                    if (newline == -1) {
                        return -1
                    } else if (newline) {
                        if (getline == -1) return -4
                        string = string newline $0
                    }
                }
            } while (pos < length(string) && strtrim == 0)
            if (strtrim == 0) {
                return -3
            }
        } else {
            if (length(string) == 1 || substr(string, 2, 1) == sep) {
                fields++
                csv[fields] = ""
                if (length(string) == 1) return fields
                string = substr(string, 2)
                continue
            }
            pos = index(substr(string, 2), sep)
            if (pos == 0) {
                fields++
                csv[fields] = substr(string, 2)
                return fields
            }
        }
        if (trim && pos != (length(string) + strtrim) && substr(string, pos + strtrim, 1) == " ") {
            trim = strtrim
            while (pos < length(string) && substr(string, pos + trim, 1) == " ") {
                trim++
            }
            string = substr(string, 1, pos + strtrim - 1) substr(string,  pos + trim)
            if (!strtrim) {
                pos -= trim
            }
        }
        if ((pos != length(string) && substr(string, pos + 1, 1) != sep)) {
            return -4
        }
        fields++
        csv[fields] = substr(string, 2 + strtrim, pos - (1 + strtrim * 2))
        if (pos == length(string)) {
            return fields
        } else {
            string = substr(string, pos + 1)
        }
    }
    return fields
}
function csv_create (csv,fields,sep,quote,escape,level, field,pos,string) {
    sep     = (sep ? sep : ",")
    quote   = (quote ? quote : "\"")
    escape  = (escape ? escape : "\"")
    level   = (level ? level : 0)
    string = ""
    for (pos = 1; pos <= fields; pos++) {
        field = csv[pos]
        if (field) {
            if (level == 0) {
                string = string csv_escape_string(field, quote, escape, quote escape)
            } else if ((level >= 2) ||
                       (level == 1 && field !~ /^-*[0-9.][0-9.]*$/)) {
                string = string quote csv_escape_string(field, "", escape, quote escape) quote
            } else {
                string = string field
            }
        } else if (level == 3) {
            string = string quote quote
        }
        if (pos < fields) string = string sep
    }
    return string
}
function csv_err (number) {
    if (number == -1) {
        return "More data expected."
    } else if (number == -2) {
        return "Unable to read the next line."
    } else if (number == -3) {
        return "Missing end quote."
    } else if (number == -4) {
        return "Missing separator."
    }
}
function csv_escape_string (string,quote,escape,special, pos,prev,char,csv) {
    prev = 1
    csv = ""
    for (pos = 1; pos < length(string) + 1; pos++) {
        char = substr(string, pos, 1)
        if (index(special, char) > 0) {
            if (pos == 1) {
                csv = escape char
            } else {
                csv = csv substr(string, prev, (pos - prev)) escape char
            }
            prev = pos + 1
        }
    }
    if (prev != pos) {
        csv = csv substr(string, prev)
    }
    if (quote && string != csv) {
        return quote csv quote
    } else {
        return csv
    }
}
