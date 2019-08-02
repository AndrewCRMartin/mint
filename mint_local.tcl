#*************************************************************************
#
#   Program:    modeller interface
#   File:       local.tcl
#   
#   Version:    V1.0
#   Date:       22.08.95
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
#
#*************************************************************************
# Set the ecalc path for running the main program
# -----------------------------------------------
set modeller "/usr/msi/quanta4.1/modeler/exec/runmod"
set pdbseg   "$env(MODELLER)/pdb2seg"

##########################################################################
# Add the ecalc directory to the execute path
# -------------------------------------------
# set auto_path "~amartin/modeller $auto_path"

##########################################################################
# Data directories
set pdbdir     /data/pdb/
set pdbext     .pdb
set pdbprep    p

#########################################################################
# Define colours for the Run and Quit buttons. Change these for B&W
# screens!
set ActiveColour  Red
set PassiveColour Cyan
set AdvColour     GreenYellow
set EntryColour   Cyan
set EntryOff      Grey


