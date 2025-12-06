# 5D Adventsbazar - Static Website Generator

## Project Overview
This is a static website generator for displaying Christmas greetings (Weihnachtsgrüße) from children. The site is published via GitHub Pages from the `docs/` folder.

## Project Structure

```
5d-adventsbazar/
├── data/
│   └── data.csv                    # Source data with Christmas greetings
├── templates/
│   └── template.html               # HTML template for individual pages
├── scripts/                        # Empty - for future generation scripts
├── docs/                          # ⚠️ GITHUB PAGES - DO NOT EDIT MANUALLY
│   ├── index.html                 # Random redirector to greeting pages
│   └── p/                         # Individual greeting pages
│       ├── {ID}-{UUID}.html       # Generated pages from data.csv
│       └── ...
├── Makefile                       # Build automation
└── PROJECT_INSTRUCTIONS.md        # This file
```

## Data Format

### data/data.csv
- **Delimiter**: Semicolon (`;`)
- **Encoding**: UTF-8
- **Fields**:
  1. `ID` - Numeric identifier (e.g., 410, 420, 430...)
  2. `Timestamp` - Submission date/time (format: DD/MM/YYYY HH:MM:SS)
  3. `Name des Kindes` - Child's name
  4. `Weihnachtsgruß` - Christmas greeting message (can be multiline)

### Example CSV Row:
```csv
410;19/11/2025 19:35:59;Konstantin ;"Frohe Weihnachten und ein fröhliches neues Jahr
Ich wünsche ganz viel Freude, bunte Lichter, viel Lachen und eine richtig schöne Weihnachtszeit.
Für das neue Jahr 2026 wünsche ich viele Abenteuer und tolle Erlebnisse.
Viele Grüße
Konstantin"
```

## Generated Page Structure

### File Naming Convention
Pattern: `{ID}-{UUID}.html`
- Example: `100-eb9a45cf-329f-4ea3-bca1-52232cbf51dc.html`
- ID matches the ID from data.csv
- UUID is randomly generated for uniqueness

### HTML Page Template Structure
Based on existing pages in `docs/p/`, each generated page should contain:

```html
<!doctype html>
<html lang="de">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Weihnachtsgruß – {NAME}</title>
  <style>
    body {
      font-family: "Segoe UI", Roboto, sans-serif;
      margin: 0;
      background: linear-gradient(180deg, #fffdf8 0%, #f7efe3 100%);
      color: #333;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      padding: 2rem;
    }
    .card {
      background: white;
      border-radius: 16px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.1);
      padding: 2rem;
      max-width: 480px;
      text-align: center;
      border: 3px solid #e0c097;
    }
    h1 {
      color: #b44d29;
      font-size: 1.8rem;
      margin-bottom: 0.5rem;
    }
    .author {
      color: #666;
      font-size: 0.95rem;
      margin-bottom: 1rem;
    }
    .text {
      font-size: 1.1rem;
      line-height: 1.5;
      white-space: pre-wrap;
    }
    footer {
      margin-top: 2rem;
      font-size: 0.85rem;
      color: #888;
    }
  </style>
</head>
<body>
  <div class="card">
    <h1>Weihnachtsgruß</h1>
    <div class="author">von {NAME}</div>
    <div class="text">
      {MESSAGE}
    </div>
  </div>
  <footer>
    © 5D Adventsbasar 2025
  </footer>
</body>
</html>
```

### Template Variables
- `{NAME}` - Replace with child's name from CSV
- `{MESSAGE}` - Replace with Christmas greeting from CSV

## Index Page (docs/index.html)

The index page randomly redirects to one of the generated greeting pages:

```html
<!doctype html>
<html lang="en">
<meta charset="utf-8">
<title>Redirecting...</title>
<script>
  const pages = [
    "./p/410-{uuid}.html",
    "./p/420-{uuid}.html",
    // ... all generated pages
  ];
  const target = pages[Math.floor(Math.random() * pages.length)];
  location.href = target;
</script>
<p>Redirecting…</p>
</html>
```

## Generation Workflow

### Current Status
- ✅ Data file exists: `data/data.csv`
- ⚠️ Template is empty: `templates/template.html`
- ⚠️ Generation script not implemented
- ⚠️ Makefile target `generate_pages` is placeholder

### Generation Steps (To Be Implemented)
1. Read `data/data.csv` using semicolon delimiter
2. For each row:
   - Generate a UUID
   - Create filename: `{ID}-{UUID}.html`
   - Fill template with name and message
   - Write to `docs/p/{filename}`
   - Collect page path for index
3. Generate/update `docs/index.html` with all page paths

### Makefile Target
```makefile
generate_pages:
    @echo "generate pages ..."
    # TODO: Implement generation script
```

## Important Notes

### ⚠️ GitHub Pages Warning
**DO NOT manually write files to `docs/` folder!**
- The `docs/` folder is published as GitHub Pages
- All content should be generated programmatically
- Manual edits will be overwritten during regeneration

### CSV Handling
- Use semicolon (`;`) as field delimiter
- Messages can contain newlines and quotes
- Handle quote escaping properly (CSV standard)

### Character Encoding

**⚠️ CRITICAL: All files MUST be UTF-8 encoded**

- Template file: `templates/template.html` must be UTF-8
- CSV data file: `data/data.csv` must be UTF-8
- German special characters: ä, ö, ü, ß, ©
- Locale settings enforced in all scripts and Makefile

**Encoding Fixes Applied:**
- Template converted from ISO-8859-1 to UTF-8
- Makefile exports `LC_ALL=C.UTF-8` and `LANG=C.UTF-8`
- Shell script sets UTF-8 locale explicitly
- AWK script configured for UTF-8 handling

**Verification:**
```bash
# Check file encoding
file -i templates/template.html  # should show: charset=utf-8

# Verify UTF-8 bytes
hexdump -C file.html | grep "ß"  # should show: c3 9f (not df)
hexdump -C file.html | grep "©"  # should show: c2 a9
```

### Implementation Language
- Not yet decided (could be Python, Node.js, shell script, etc.)
- Should be placed in `scripts/` directory
- Should be callable from Makefile

## GitHub Pages URL
```
https://st-ursula-gymnasium-org.github.io/5d-adventsbazar
```

## QR Code Generation
The Makefile includes a target to generate QR code for the site:
```bash
make generate_qr_code
```

## Publishing to GitHub Pages

### Automated Publishing
Use the `publish` target to regenerate pages and deploy to GitHub:

```bash
make publish
```

This target will:
1. **Regenerate all pages** from CSV data
2. **Check for changes** in `docs/` folder
3. **Stage changes** with `git add docs/`
4. **Create commit** with message:
   ```
   Update generated pages

   Generated with Claude Code
   https://claude.com/claude-code

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```
5. **Push to GitHub** using credentials from:
   - Username: `/home/a2/pswd/st-ursula-gymnasium-org/github-user.txt`
   - Token: `/home/a2/pswd/st-ursula-gymnasium-org/github-password.txt`
6. **Automatic deployment** via GitHub Pages

### Security Notes
- Git credentials are read from files (not hardcoded)
- Token is used for HTTPS authentication
- Only commits if there are actual changes
- Follows git safety protocols (no force push, proper attribution)
- Plain ASCII text only (no emojis or special Unicode characters)

## Pushing Code Changes

### Push to GitHub
Use the `push` target to push already-committed changes to GitHub:

```bash
make push
```

This target will:
1. **Read credentials** from secure files
2. **Push commits** to GitHub using token authentication

**Workflow:**
```bash
# Make your changes
git add .
git commit -m "Your commit message"

# Push using stored credentials
make push
```

**Difference from `publish`:**
- `publish`: Regenerates pages, commits `docs/`, and pushes
- `push`: Only pushes existing commits (assumes you already committed)

## Coding Standards & Best Practices

### ⚠️ IMPORTANT: Always Follow These Guidelines

1. **Makefile Rules**
   - Use `.ONESHELL:` directive at the top of Makefile
   - Set `.SHELLFLAGS := -eu -o pipefail -c` for safety
   - Keep Makefile rules minimal - delegate complex logic to scripts
   - All business logic should be in `scripts/` directory, not in Makefile
   - Use `.PHONY:` declarations for non-file targets

2. **Script Organization**
   - Place all scripts in `scripts/` folder
   - Scripts must be executable (`chmod +x`)
   - Use bash for scripting (standard Linux tools preferred)
   - Follow structured, maintainable code patterns:
     - Clear header comments explaining purpose
     - Configuration section at top
     - Well-defined functions with single responsibilities
     - Main function to orchestrate workflow
     - Error checking (`set -euo pipefail`)

3. **Code Structure Template**
   ```bash
   #!/bin/bash
   # Brief description

   set -euo pipefail

   # Configuration section
   CONST_VAR="value"

   # Functions (well-commented, single purpose)
   function_name() {
       # implementation
   }

   # Main function
   main() {
       # orchestrate workflow
   }

   # Execute
   main "$@"
   ```

4. **Tools to Use**
   - Prefer standard Linux tools: bash, awk, sed, grep, etc.
   - Avoid Python/Node.js unless absolutely necessary
   - Use AWK for CSV parsing and text processing
   - Use sed for simple text substitution
   - UUID generation: `/proc/sys/kernel/random/uuid` or `uuidgen`

5. **Text and Character Encoding**
   - Use plain ASCII text whenever possible (no emojis)
   - For internationalization: UTF-8 encoding is required
   - Avoid Unicode decorative characters in code, comments, or commit messages
   - Exception: User-facing content in German (ä, ö, ü, ß, ©)

## Implementation Status

### ✅ Completed
- Data file: `data/data.csv`
- Template file: `templates/template.html`
- Generation script: `scripts/generate_pages.sh` (well-structured with functions)
- Makefile: Updated with `.ONESHELL:` and clean structure

### Script Architecture

The generation system is split into separate AWK and shell scripts for better maintainability:

**1. `scripts/parse_csv.awk`** - CSV Parser
- Handles multiline quoted fields correctly
- Identifies records by checking if line starts with ID (number)
- Extracts 4 fields: ID, timestamp, name, message
- Writes each record to a temp file (one file per record)
- Returns count of processed records

**2. `scripts/generate_pages.sh`** - Page Generator
- **generate_uuid()**: Creates unique identifiers
- **generate_html_page()**: Uses AWK to safely substitute template variables
- **main()**: Orchestrates workflow:
  1. Creates temp directory for parsed records
  2. Calls AWK script to parse CSV
  3. Processes each temp file to generate HTML
  4. Creates index.html with random redirector
  5. Cleans up temp files automatically

**Key Design Decisions**:
- **Temp files**: Avoids issues with bash `read` command on multiline data
- **Separate AWK script**: Cleaner separation of parsing logic
- **AWK for substitution**: Handles multiline messages correctly
- **Trap cleanup**: Ensures temp directory is removed even on error

## Next Steps
1. ✅ Create HTML template in `templates/template.html`
2. ✅ Implement generation script in `scripts/`
3. ✅ Update Makefile to call generation script
4. Test generation with current data
5. Verify GitHub Pages deployment
