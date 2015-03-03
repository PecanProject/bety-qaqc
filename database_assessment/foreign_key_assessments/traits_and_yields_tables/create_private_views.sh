#!/usr/bin/env bash

. connection_variables

PSQL="psql -h $HOST -U $USER $DATABASE"



$PSQL < create_unrestricted_traits_and_yields_view.sql

