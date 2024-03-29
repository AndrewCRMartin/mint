#*************************************************************************
#
#   Program:    modeller interface
#   File:       local.tcl
#   
#   Version:    V3.2
#   Date:       24.11.06
#   Function:   Set up local stuff for this installation of Modeller
#   
#   Copyright:  (c) Dr. Andrew C. R. Martin 1995-2006
#   Author:     Dr. Andrew C. R. Martin
#   Address:    Biomolecular Structure & Modelling Unit,
#               Department of Biochemistry & Molecular Biology,
#               University College,
#               Gower Street,
#               London.
#               WC1E 6BT.
#   EMail:      andrew@bioinf.org.uk
#               
#*************************************************************************
#
#   This program is not in the public domain, but it may be copied
#   according to the conditions laid out in the accompanying file
#   COPYING.DOC
#
#   The code may be modified as required, but any modifications must be
#   documented so that the person responsible can be identified. If 
#   someone else breaks this code, I don't want to be blamed for code 
#   that does not work! 
#
#   The code may not be sold commercially or included as part of a 
#   commercial product except as described in the file COPYING.DOC.
#
#*************************************************************************
#
#   Description:
#   ============
#
#*************************************************************************
#
#   Usage:
#   ======
#
#*************************************************************************
#
#   Revision History:
#   =================
#   V1.0  22.08.95 Original    By: ACRM
#   V1.1  24.10.95 Moved name of modeller routines here (homology
#                  modelling has a different name in the MSI version c.f.
#                  the academic version)
#   V1.2  07.11.95 Changed environment variable to MINTDIR to avoid 
#                  clashes with MODELLER
#   V1.3  10.11.95 Skipped
#   V2.0           SKIPPED
#   V3.0  03.10.96 New for Modeller-3
#   V3.1           SKIPPED
#   V3.2           SKIPPED
#
#*************************************************************************
# Set the names of the programs to run
# ------------------------------------
if { {string length $env(mod)} > 0 } {
   set modeller "$env(MODINSTALL)/bin/$env(mod)"
}  else {
   set modeller "/acrm/usr/local/apps/modeller6/bin/mod6v2"
}
set pdbseg   "$env(MINTDIR)/pdb2seg"

##########################################################################
# Data directories
# ----------------
# NOTE! You must put a trailing slash on this line
set pdbdir     /acrm/data/pdb/
set pdbext     .ent
set pdbprep    pdb

#########################################################################
# Set the names of the routines within MODELLER to do the modelling
# -----------------------------------------------------------------
# routine_homol is for modelling where an alignment has been specified
# (MSI calls this "homol")
set routine_homol "model"
# routine_fhomol is for full homology modelling where no alignment has
# been specified
set routine_fhomol "full_homol"

#########################################################################
# Define colours for the Run and Quit buttons. Change these for B&W
# screens!
set ActiveColour  Red
set PassiveColour Cyan
set AdvColour     GreenYellow
set EntryColour   Cyan
set EntryOff      Grey


