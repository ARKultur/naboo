#!/bin/env bash

echo "This script will destroy the database. Are you sure you want to delete this database ?"
read -p "Press [Enter] key to continue..."

export DATABASE="naboo"
export DATABASE_TEST="${DATABASE}_test"
sudo -u postgres psql -c "DROP DATABASE IF EXISTS ${DATABASE};"
sudo -u postgres psql -c "DROP DATABASE IF EXISTS ${DATABASE_TEST};"
