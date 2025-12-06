#
# Makefile for 5D Adventsbasar Static Site Generator
#
# This Makefile provides targets for generating HTML pages from CSV data
# and managing the static website deployment.
#

.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
SHELL := /bin/bash

# Ensure UTF-8 locale for proper character handling
export LC_ALL = C.UTF-8
export LANG = C.UTF-8

.PHONY: all

all: help

# ============================================================================
# Page Generation
# ============================================================================

## Generate Message pages to be shown on the link
generate_pages:
	@./scripts/generate_pages.sh

# ============================================================================
# QR Code Generation
# ============================================================================

## Generate QR code for the 5d-adventsbazar url
generate_qr_code:
	@echo "Generating QR code for GitHub Pages URL..."
	qrencode -o adventsbazar_qr.png "https://st-ursula-gymnasium-org.github.io/5d-adventsbazar"
	@echo "QR code saved to: adventsbazar_qr.png"


## Print this help
help::
	@awk '/^## ---/ {c=substr($$0,7); print c ":"; c=0; next} /^## /{c=substr($$0,3);next}c&&/^[[:alpha:]][[:alnum:]_/-]+:/{print substr($$1,1,index($$1,":")),c}1{c=0}' $(MAKEFILE_LIST) | column -s: -t -W 2,3 -o " "

## Print extended help. Show all possible targets
help_all:: help
	@echo ""
	@echo "Other Targers:"
	@echo ""
	@awk '/^## ---/ {c=substr($$0,8); print c ":"; c=0; next} /^### /{c=sub
