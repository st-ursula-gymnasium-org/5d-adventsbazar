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

# ============================================================================
# Publishing
# ============================================================================

.PHONY: publish

## Regenerate pages, commit changes, and push to GitHub
publish: generate_pages
	@echo "Publishing changes to GitHub..."
	if ! git diff --quiet docs/ || ! git diff --cached --quiet docs/ || [ -n "$$(git ls-files --others --exclude-standard docs/)" ]; then
		echo "Changes detected in docs/ folder..."
		git add docs/
		git status --short
		echo "Creating commit..."
		git commit -m "Update generated pages" \
			-m "" \
			-m "Generated with Claude Code" \
			-m "https://claude.com/claude-code" \
			-m "" \
			-m "Co-Authored-By: Claude <noreply@anthropic.com>"
		echo "Pushing to GitHub..."
		GIT_USER=$$(cat /home/a2/pswd/st-ursula-gymnasium-org/github-user.txt | head -1)
		GIT_TOKEN=$$(cat /home/a2/pswd/st-ursula-gymnasium-org/github-password.txt | head -1)
		REPO_URL=$$(git config --get remote.origin.url)
		if [[ $$REPO_URL == https://* ]]; then
			REPO_PATH=$$(echo $$REPO_URL | sed 's|https://github.com/||')
			git push "https://$$GIT_USER:$$GIT_TOKEN@github.com/$$REPO_PATH" HEAD
		else
			echo "Warning: Remote URL is not HTTPS. Attempting regular push..."
			git push
		fi
		echo "✓ Published successfully!"
	else
		echo "No changes to publish."
	fi

.PHONY: push

## Push commits to GitHub using stored credentials
push:
	@echo "Pushing to GitHub..."
	GIT_USER=$$(cat /home/a2/pswd/st-ursula-gymnasium-org/github-user.txt | head -1)
	GIT_TOKEN=$$(cat /home/a2/pswd/st-ursula-gymnasium-org/github-password.txt | head -1)
	REPO_URL=$$(git config --get remote.origin.url)
	if [[ $$REPO_URL == https://* ]]; then
		REPO_PATH=$$(echo $$REPO_URL | sed 's|https://github.com/||')
		git push "https://$$GIT_USER:$$GIT_TOKEN@github.com/$$REPO_PATH" HEAD
	else
		echo "Warning: Remote URL is not HTTPS. Attempting regular push..."
		git push
	fi
	echo "✓ Pushed successfully!"

# ============================================================================
# Help
# ============================================================================

## Print this help
help::
	@awk '/^## ---/ {c=substr($$0,7); print c ":"; c=0; next} /^## /{c=substr($$0,3);next}c&&/^[[:alpha:]][[:alnum:]_/-]+:/{print substr($$1,1,index($$1,":")),c}1{c=0}' $(MAKEFILE_LIST) | column -s: -t -W 2,3 -o " "

## Print extended help. Show all possible targets
help_all:: help
	@echo ""
	@echo "Other Targers:"
	@echo ""
	@awk '/^## ---/ {c=substr($$0,8); print c ":"; c=0; next} /^### /{c=sub
