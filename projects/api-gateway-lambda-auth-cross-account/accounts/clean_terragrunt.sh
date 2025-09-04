#!/bin/bash

echo "🔍 Searching and deleting .terragrunt-cache folders..."
find . -type d -name ".terragrunt-cache" -exec rm -rf {} +
echo "✅ Removed all .terragrunt-cache folders."

echo "🔍 Searching and deleting .terraform.lock.hcl files..."
find . -type f -name ".terraform.lock.hcl" -exec rm -f {} +
echo "✅ Removed all .terraform.lock.hcl files."

echo "🧹 Clean up completed."

