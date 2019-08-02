#*************************************************************************
#
#   Program:    modeller interface
#   File:       local.tcl
#   
#   Version:    V1.1
#   Date:       24.10.95
#   Function:   Set up local stuff for this installation of Modeller
#   
#   Copyright:  (c) Dr. Andrew C. R. Martin 1995
#   Author:     Dr. Andrew C. R. Martin
#   Address:    Biomolecular Structure & Modelling Unit,
#               Department of Biochemistry & Molecular Biology,
#               University College,
#               Gower Street,
#               London.
#               WC1E 6BT.
#   Phone:      (Home) +44 (0)1372 275775
#   EMail:      INTERNET: martin@biochem.ucl.ac.uk
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
#
#*************************************************************************
# Set the names of the programs to run
# ------------------------------------
#set modeller "/usr/msi/quanta4.1/modeler/exec/runmod"
set modeller "/usr/user/modeller/bin/mod12"
set pdbseg   "$env(MODELLER)/pdb2seg"

##########################################################################
# Data directories
# ----------------
set pdbdir     /data/pdb/
set pdbext     .pdb
set pdbprep    p

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


