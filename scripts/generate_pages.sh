#!/usr/bin/bash
#
# Generate HTML pages from CSV data
#
# This script reads Christmas greetings from a CSV file and generates
# individual HTML pages for each greeting, plus an index page that
# randomly redirects to one of the generated pages.
#

set -euo pipefail

# Ensure UTF-8 locale for proper character handling
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# ============================================================================
# Configuration
# ============================================================================

CSV_FILE="data/data.csv"
TEMPLATE_FILE="templates/template.html"
OUTPUT_DIR="docs/p"
INDEX_FILE="docs/index.html"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# ============================================================================
# Functions
# ============================================================================

# Generate UUID (try /proc first, fallback to uuidgen)
generate_uuid() {
    cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen
}

# Generate single HTML page from template
# Args: template_file, name, message, id, output_file
generate_html_page() {
    local template_file="$1"
    local name="$2"
    local message="$3"
    local id="$4"
    local output_file="$5"

    # Use awk for safe substitution with multiline content
    awk -v name="$name" -v msg="$message" '{
        gsub(/\{\{NAME\}\}/, name)
        gsub(/\{\{MESSAGE\}\}/, msg)
        print
    }' "$template_file" > "$output_file"
}

# ============================================================================
# Main
# ============================================================================

main() {
    echo "Initializing..."

    # Check required files
    if [ ! -f "$CSV_FILE" ]; then
        echo "Error: CSV file not found: $CSV_FILE" >&2
        exit 1
    fi

    if [ ! -f "$TEMPLATE_FILE" ]; then
        echo "Error: Template file not found: $TEMPLATE_FILE" >&2
        exit 1
    fi

    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    rm -f "$OUTPUT_DIR"/*.html

    # Create temp directory for parsed records
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" EXIT

    # Parse CSV into temp files
    echo "Parsing CSV data..."
    local record_count
    record_count=$(awk -f "$SCRIPT_DIR/parse_csv.awk" -v outdir="$temp_dir" "$CSV_FILE")

    if [ "$record_count" -eq 0 ]; then
        echo "Error: No records found in CSV" >&2
        exit 1
    fi

    echo "Generating $record_count pages..."

    # Array to store page paths
    declare -a pages

    # Process each record file
    for record_file in "$temp_dir"/record_*; do
        # Read the 4 lines (id, timestamp, name, message)
        {
            read -r id
            read -r timestamp
            read -r name
            # Read rest as message (may be multiline)
            message=$(cat)
        } < "$record_file"

        # Generate filename
        local uuid filename filepath
        uuid=$(generate_uuid)
        filename="${id}-${uuid}.html"
        filepath="$OUTPUT_DIR/$filename"

        # Generate HTML page
        generate_html_page "$TEMPLATE_FILE" "$name" "$message" "$id" "$filepath"

        echo "  Created $filename for $name"

        # Store page path
        pages+=("./p/$filename")
    done

    # Generate index.html
    echo "Generating $INDEX_FILE..."

    cat > "$INDEX_FILE" << 'EOF'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
  <meta http-equiv="Pragma" content="no-cache">
  <meta http-equiv="Expires" content="0">
  <title>Redirecting...</title>
</head>
<body>
<script>
  const pages = [
EOF

    # Add page paths
    for page in "${pages[@]}"; do
        echo "    \"$page\"," >> "$INDEX_FILE"
    done

    # Remove trailing comma from last entry
    sed -i '$ s/,$//' "$INDEX_FILE"

    # Write footer
    cat >> "$INDEX_FILE" << 'EOF'
  ];
  const target = pages[Math.floor(Math.random() * pages.length)];
  location.href = target;
</script>
<p>Redirecting…</p>
</body>
</html>
EOF

    echo "Done! Generated ${#pages[@]} pages."
}

# Run main
main "$@"
