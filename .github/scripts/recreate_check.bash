#!/usr/bin/env bash

# ---
# Script to check a Supabase migration file for dangerous
# table "re-creations" (a DROP followed by a CREATE).
#
# Usage: ./check_migration.sh <path_to_migration.sql>
# ---

MIGRATION_FILE=$1

# Check if a file was provided
if [[ -z "$MIGRATION_FILE" ]]; then
  echo "Error: no migration file was provided."
  exit 1
fi

# 1. Find all dropped tables, extract names, sort them, and make unique.
DROPPED_TABLES=$(grep -i 'DROP TABLE' "$MIGRATION_FILE" | \
				 sed -E 's/.*DROP TABLE (IF EXISTS )?([^ ;]+).*/\2/' | sed 's/"//g' | \
                 sort -u)

# 2. Find all created tables, extract names, sort them, and make unique.
CREATED_TABLES=$(grep -i 'CREATE TABLE' "$MIGRATION_FILE" | \
				 sed -E 's/.*CREATE TABLE (IF NOT EXISTS )?([^ (]+).*/\2/' | sed 's/"//g' | \
                 sort -u)

# 3. Find the intersection of the two lists using comm.
RECREATED_TABLES=$(comm -12 <(echo "$DROPPED_TABLES") <(echo "$CREATED_TABLES"))


# 4. Report the findings
if [[ -n "$RECREATED_TABLES" ]]; then
  echo "--- 🚨 DANGER! ---"
  echo "The following tables are being DROPPED and RE-CREATED in '$MIGRATION_FILE':"
  echo ""
  echo "$RECREATED_TABLES"
  echo ""
  echo "This will cause TOTAL DATA LOSS in these tables."
  echo "Review the file immediately."
  exit 1 # Exit with an error code for automation
else
  echo "--- ✅ OK ---"
  echo "No destructive table re-creations detected in '$MIGRATION_FILE'."
  exit 0 # Exit with success
fi
