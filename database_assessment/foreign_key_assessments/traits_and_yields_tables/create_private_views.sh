#!/usr/bin/env bash

# Modify as needed:
DATABASE=ebi_production_copy



psql $DATABASE < create_unrestricted_traits_and_yields_view.sql

