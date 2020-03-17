
# Convex Hull showcase

## Overview

A collection of scripts to rebuild the Convex Hull show case.


## Prerequisite

* Running Exasol instance or Exasol community edition
* Published sports analytics script language container
* Python3 is introduced an additional scripting language to the SQL compiler by
"alter session set script_languages..."


## Sequence

1) Import position data in showcase schema
2) Create Convex Hull User Defined Function (UDF)
3) Create MATCH_CONVEX_HULL table for Tableau report