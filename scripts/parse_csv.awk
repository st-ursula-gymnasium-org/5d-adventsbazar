#!/usr/bin/awk -f
#
# Parse CSV file with multiline quoted fields
# Outputs each record as separate files in a temp directory
#
# Usage: awk -f parse_csv.awk -v outdir=/tmp/records data/data.csv
#

BEGIN {
    # Ensure UTF-8 handling
    FPAT = "([^;]*)|(\"[^\"]*\")"
    FS = ";"
    record = ""
    in_record = 0
    record_num = 0

    if (outdir == "") {
        print "Error: outdir variable must be set" > "/dev/stderr"
        exit 1
    }
}

# Skip header
NR == 1 { next }

{
    # Check if line starts with a number (new record)
    if ($0 ~ /^[0-9]+;/) {
        # If we have a previous record, process it
        if (in_record && record != "") {
            process_record(record, record_num)
            record_num++
        }
        # Start new record
        record = $0
        in_record = 1
    } else if (in_record) {
        # Continuation of previous record (multiline field)
        record = record "\n" $0
    }
}

END {
    # Process last record if any
    if (in_record && record != "") {
        process_record(record, record_num)
        record_num++
    }
    # Output total count
    print record_num
}

function process_record(rec, num) {
    # Split record by semicolon
    n = split(rec, fields, ";")

    if (n >= 4) {
        id = fields[1]
        timestamp = fields[2]
        name = fields[3]

        # Message is everything from field 4 onwards (in case message contains semicolons)
        message = fields[4]
        for (i = 5; i <= n; i++) {
            message = message ";" fields[i]
        }

        # Remove surrounding quotes from message
        gsub(/^"/, "", message)
        gsub(/"$/, "", message)

        # Trim whitespace from name
        gsub(/^[[:space:]]+/, "", name)
        gsub(/[[:space:]]+$/, "", name)

        # Write to temp file
        filepath = outdir "/record_" sprintf("%04d", num)
        print id > filepath
        print timestamp >> filepath
        print name >> filepath
        print message >> filepath
        close(filepath)
    }
}
