#!/usr/local/bin/wish -f
#*************************************************************************
#
#   Program:    MINT (Modeller INTerface)
#   File:       mint.tcl
#   
#   Version:    V1.2
#   Date:       07.11.95
#   Function:   Write a control file for Modeller
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
#               (Work) +44 (0)171 387 7050 X 3284
#   EMail:      martin@biochem.ucl.ac.uk
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
#   V1.0  23.08.95 Original
#   V1.1  24.10.95 Moved name of modeller routines into mint_local since
#                  homology modelling has a different name in the MSI 
#                  version c.f. the academic version.
#                  The run name wasn't being set if we had specified an
#                  alignment.
#   V1.2  07.11.95 Changed environment variable to MINTDIR to avoid 
#                  clashes with MODELLER
#
#
#*************************************************************************


##########################################################################
# proc AlignHelp
# --------------
# Provide help text for the specify alignment window
# 23.08.95 Original    By: ACRM
#
proc AlignHelp {{w .ahelp}} {
    toplevel $w

    wm title $w "Modeller Alignment Help"
    wm iconname $w "Modeller Alignment Help"

    message $w.msg -justify left -relief raised -bd 2 \
            -font -Adobe-Helvetica-Medium-R-Normal--*-180-* \
            -text "Enter the name of an alignment file in the `Alignment \
            File' text box. This file may be in PIR-like format (with \
            annotations to describe the PDB source) or in Quanta format. \
            Select the appropriate radio button. Specify the code used \
            in the alignment file for the target sequence in the \
            `Target code' text box. \
            If you use a Quanta format alignment file, the template PDB \
            codes should match those used in the alignment file and \
            should be valid PDB file stems for files in the current, or PDB, \
            directory. \
            Clicking the `No Alignment' button \
            will revert to full homology modelling where the program \
            will supply the alignment."

    button $w.quit -text "Exit" -command "destroy $w"

    pack append $w $w.msg top $w.quit { top fillx }
}


##########################################################################
# proc NoAlignment
# ----------------
# Exit from the specify alignment window, resetting to full homology 
# modelling
# 23.08.95 Original    By: ACRM
#
proc NoAlignment { } {
    global method

    set method full
    .basic.pir.entry configure -state normal -background cyan
    focus .basic.pir.entry
    destroy .specalign
}


##########################################################################
# proc SpecAlign
# --------------
# Display window for specifying the alignment
# 23.08.95 Original    By: ACRM
#
proc SpecAlign {{w .specalign}} {
    global alnfile alnseqid alntype method
    global EntryColour EntryOff PassiveColour ActiveColour

    toplevel $w

    wm title $w "Modeller Alignment"
    wm iconname $w "Modeller Alignment"

    set method homol
    .basic.pir.entry configure -state disabled -background $EntryOff

    frame $w.top -bd 1m
    frame $w.bot -bd 1m
    pack append $w $w.top {top fillx} $w.bot {top fillx}
    frame $w.top.l -bd 1m
    frame $w.top.r -bd 1m
    pack append $w.top $w.top.l {left filly} $w.top.r {left filly}

    # Create a text gadget 'entry' for alignment file
    frame $w.top.l.alnfile -bd 1m
    entry $w.top.l.alnfile.entry -relief sunken -width 40 \
            -textvariable alnfile -background $EntryColour
    bind  $w.top.l.alnfile.entry <Return> "focus $w.top.l.alnseqid.entry"
    label $w.top.l.alnfile.label -text "Alignment file:"
    # Attach the entry and label to the frame
    pack append $w.top.l.alnfile \
            $w.top.l.alnfile.entry right \
            $w.top.l.alnfile.label left
    # Attach to the main window
    pack append $w.top.l $w.top.l.alnfile {top fillx}
    
    # Create a text gadget 'entry' for target code
    frame $w.top.l.alnseqid -bd 1m
    entry $w.top.l.alnseqid.entry -relief sunken -width 10 \
            -textvariable alnseqid -background $EntryColour
    bind  $w.top.l.alnseqid.entry <Return> "focus $w.top.l.alnfile.entry"
    label $w.top.l.alnseqid.label -text "Target code:   "
    # Attach the entry and label to the frame
    pack append $w.top.l.alnseqid \
            $w.top.l.alnseqid.label left \
            $w.top.l.alnseqid.entry left
    # Attach to the main window
    pack append $w.top.l $w.top.l.alnseqid {top fillx}
    
    # Create radio buttons for the file type
    radiobutton $w.top.r.pir -text PIR -variable alntype \
            -value PIR -anchor w
    radiobutton $w.top.r.quanta -text Quanta -variable alntype \
            -value QUANTA -anchor w
    # Attach to the main window
    pack append $w.top.r \
            $w.top.r.pir    {top fillx expand} \
            $w.top.r.quanta {top fillx expand} 

    button $w.bot.noal -text "No alignment" -command "NoAlignment" \
            -width 12 -height 2 -background $PassiveColour \
            -activebackground $ActiveColour 
    button $w.bot.help -text "Help!" -command "AlignHelp" \
            -width 12 -height 2 \
            -activebackground $ActiveColour 
    button $w.bot.exit -text "Exit" -command "ExitSpecAlign" \
            -width 12 -height 2 -background $PassiveColour \
            -activebackground $ActiveColour 
    pack append $w.bot \
            $w.bot.noal {left expand filly} \
            $w.bot.help {left expand filly} \
            $w.bot.exit {left expand filly}

    focus $w.top.l.alnfile.entry
}


##########################################################################
# proc ExitSpecAlign
# ------------------
# Exit from the specify alignment window
# 23.08.95 Original    By: ACRM
#
proc ExitSpecAlign { } {
    focus .basic.template.entry
    destroy .specalign
}


##########################################################################
# proc Options
# ------------
# Display the options window for setting advanced items
# 23.08.95 Original    By: ACRM
#
proc Options {{w .optwindow}} {
    global pdbdir pdbext pdbprep
    global EntryColour ActiveColour

    toplevel $w

    wm title $w "Modeller Options"
    wm iconname $w "Modeller Options"

    # Create a text gadget 'entry' for PDB directory
    frame $w.pdbdir -bd 1m
    entry $w.pdbdir.entry -relief sunken -width 40 -textvariable pdbdir \
            -background $EntryColour
    bind  $w.pdbdir.entry <Return> "focus $w.pdbext.entry"
    label $w.pdbdir.label -text "PDB directory:"
    # Attach the entry and label to the frame
    pack append $w.pdbdir $w.pdbdir.label {left expand} \
            $w.pdbdir.entry left
    # Attach to the main window
    pack append $w $w.pdbdir {top fillx}
    
    # Create a text gadget 'entry' for PDB extension
    frame $w.pdbext -bd 1m
    entry $w.pdbext.entry -relief sunken -width 40 -textvariable pdbext \
            -background $EntryColour
    bind  $w.pdbext.entry <Return> "focus $w.pdbprefix.entry"
    label $w.pdbext.label -text "PDB extension:"
    # Attach the entry and label to the frame
    pack append $w.pdbext $w.pdbext.label {left expand} \
            $w.pdbext.entry left
    # Attach to the main window
    pack append $w $w.pdbext {top fillx}

    # Create a text gadget 'entry' for PDB prefix
    frame $w.pdbprefix -bd 1m
    entry $w.pdbprefix.entry -relief sunken -width 10 \
            -textvariable pdbprep -background $EntryColour
    bind  $w.pdbprefix.entry <Return> "focus $w.pdbdir.entry"
    label $w.pdbprefix.label -text "PDB prefix (- if none):"
    # Attach the entry and label to the frame
    pack append $w.pdbprefix $w.pdbprefix.label left \
            $w.pdbprefix.entry {left expand}
           
    # Attach to the main window
    pack append $w $w.pdbprefix {top fillx}

    button $w.quit -text "Exit" -command "destroy $w"
    pack append $w $w.quit {top fillx}

    focus $w.pdbdir.entry
}


##########################################################################
# proc MainHelp
# -------------
# Provide help text for the main window
# 22.08.95 Original    By: ACRM
#
proc MainHelp {{w .help}} {
    toplevel $w

    wm title $w "Modeller Main Help"
    wm iconname $w "Modeller Help"

    message $w.msg -justify left -relief raised -bd 2 \
            -font -Adobe-Helvetica-Medium-R-Normal--*-180-* \
            -text "Enter the name of a standard PIR file in the `PIR \
            Sequence File' text box and PDB codes for template \
            structures into the `Template PDB Codes' text box. These \
            should be specified in lower case using the standard \
            4-character name and separated by spaces. Optionally, a \
            5th character may be supplied to represent the chain to \
            be modelled. Full homology \
            modelling will be performed and the supplied structures will \
            be aligned. By clicking the `Specify Alignment' button, you \
            may supply an alignment rather than asking the program to \
            perform the alignment. This is likely to give better results! \
            If you use a Quanta format alignment file, the template PDB \
            codes should match those used in the alignment file and \
            should be valid PDB file stems for files in the current, or PDB, \
            directory."

    button $w.quit -text "Exit" -command "destroy $w"

    pack append $w $w.msg top $w.quit { top fillx }
}


##########################################################################
#  proc WriteControl filename
#  --------------------------
#  Write the control file from the values of the global variables
#
#  22.08.95 Original    By: ACRM
#  24.08.95 Imports seqname rather than calculating internally
#  24.10.95 Imports names of modeller routines
#
proc WriteControl filename {
    #  Reference global variables
    global pdbdir refinement pdbext
    global templatelist pirfile seqformat segfile seqname
    global method alnfile alnseqid alntype nmodel
    global routine_homol routine_fhomol

    #  Open the file
    set file [open $filename w]
    

    # For both modelling methods
    #  This is all for full homology modelling
    puts $file "INCLUDE"
    puts $file [format "SET ATOM_FILES_DIRECTORY = './:%s'" $pdbdir]
    puts $file [format "SET PDB_EXT = '%s'" $pdbext]
    puts $file [format "SET FINISH_METHOD = '%s'" $refinement]
    puts $file "SET STARTING_MODEL = 1"
    puts $file [format "SET ENDING_MODEL = %d" $nmodel]
    if {$nmodel == 1} {
        puts $file "SET DEVIATION = 0"
    } else {
        puts $file "SET DEVIATION = 4.0"
    }

    puts -nonewline $file "SET KNOWNS = "
    foreach code $templatelist {
        puts -nonewline $file [format "'%s' " $code]
    }
    puts $file " "

    puts $file [format "SET ALIGNMENT_FORMAT = '%s'" $alntype] 

    if {$method == "full"} {
        puts $file [format "SET SEQUENCE = '%s'" $seqname]

        set segfile [format "%s.seg" $seqname]
        puts $file [format "SET SEGFILE = '%s'" $segfile]

        puts $file [format "CALL ROUTINE = '%s'" $routine_fhomol]
    }  else {
        puts $file [format "SET SEQUENCE = '%s'" $alnseqid]
        puts $file [format "SET ALNFILE = '%s'" $alnfile]

        puts $file [format "CALL ROUTINE = '%s'" $routine_homol]
    }

    #  Close the file
    close $file
}


##########################################################################
#   proc InitWM 
#   -----------
#   Initialise the window manager, set up the name bar, etc.
#
#   22.08.94 Original   By: ACRM
#   27.01.95 V1.1
#
proc InitWM { } {
    wm title . "Modeller Inteface V1.1 (c) 1995, Dr. Andrew C.R. \
Martin, UCL"
    wm iconname . "Modeller"
}


##########################################################################
#   proc InitVariables
#   ------------------
#   Initialise all variables
#
#   22.08.95 Original   By: ACRM
#
proc InitVariables { } {
    #  Reference global variables
    global refinement nmodel
    global method alntype

    set refinement refine
    set nmodel     1
    set method     full
    set alntype    PIR
}


##########################################################################
#  proc quit button
#  ----------------
#  The procedure is used to end the program.
#  It is invoked with either the quit or run parameter
#  Sets the focus back to one of the text entries, so that
#  a FocusOut from the run button doesn't occur after the
#  button has been destroyed
#
#  22.08.95 Original    By: ACRM
#  24.08.95 Gets runname from $seqname rather than just modeller
#  24.10.95 If it's full homology modelling the runname is got
#           from the sequence id in the alignment file rather than
#           the pir filename (which is probably blank)
#
proc quit button {
    global method segfile seqname pirfile
    global alnseqid

    if {$button == "run"} { 
        if {$method == "full"} {
            set seqname [lindex [split $pirfile .] 0 ]
        } else {
            set seqname $alnseqid
        }

        set controlfile [format "%s_%s.top" $seqname [pid]]
        WriteControl $controlfile
        if {$method == "full"} {
            BuildSegFile $segfile
        }
        RunModeller  $controlfile
    }

    focus .basic.pir.entry
    destroy .
}


##########################################################################
#   proc RunModeller file
#   ---------------------
#   Run the Modeller program using the control file we have generated
#
#   22.08.95 Original   By: ACRM
#
proc RunModeller file {
    global modeller
    exec $modeller $file &
}


##########################################################################
#   proc BuildSegFile file
#   ----------------------
#   Run the pdb2seg to create a seg alignment file for a set of PDB codes.
#   This is used for full homology modelling where an alignment hasn't
#   been specified.
#
#   22.08.95 Original   By: ACRM
#
proc BuildSegFile file {
    global pdbseg pirfile pdbdir pdbprep pdbext templatelist

    eval exec $pdbseg $pirfile $pdbdir $pdbprep $pdbext $file \
            $templatelist
}


##########################################################################
# proc BuildFrames
# ----------------
# Create 4 frames and attach to the main window
# 22.08.95 Original    By: ACRM
#
proc BuildFrames { } {
    frame .basic   -relief raised -border 1
    frame .medium  -relief raised -border 1
    frame .options -relief raised -border 1
    frame .buttons -relief raised -border 1
    pack append . .basic   {top fill expand} \
                  .medium  {top fill expand} \
                  .options {top fill expand} \
                  .buttons {top fill expand}
}


##########################################################################
# proc BuildBasic
# ---------------
# Build the basic section of the main window
# 22.08.95 Original    By: ACRM
#
proc BuildBasic { } {
    global templatelist pirfile
    global EntryColour

    # Create a text gadget 'entry' for PIR sequence filename
    frame .basic.pir -bd 1m
    entry .basic.pir.entry -relief sunken -width 40 \
            -textvariable pirfile -background $EntryColour
    bind  .basic.pir.entry <Return> "focus .basic.template.entry"
    label .basic.pir.label -text "PIR Sequence File:"
    # Attach the entry and label to the frame
    pack append .basic.pir .basic.pir.entry right .basic.pir.label left
    # Attach to the main window
    pack append .basic .basic.pir {top fillx}

    # Create a text gadget 'entry' for the template list
    frame .basic.template -bd 1m
    entry .basic.template.entry -relief sunken -width 40 \
            -textvariable templatelist -background $EntryColour
    bind  .basic.template.entry <Return> "focus .medium.nmodel.entry"
    label .basic.template.label -text "Template PDB codes:"
    # Attach the entry and label to the frame
    pack append .basic.template .basic.template.entry right \
            .basic.template.label left
    # Attach to the main window
    pack append .basic .basic.template {top fillx}
}


##########################################################################
# proc BuildMedium
# ----------------
# Build the medium-level options section of the main window
# 22.08.95 Original    By: ACRM
#
proc BuildMedium { } {
    global refinement nmodel
    global EntryColour

    # Text entry for number of models
    frame .medium.nmodel -bd 1m
    entry .medium.nmodel.entry -relief sunken -width 10 \
          -textvariable nmodel -background $EntryColour
    label .medium.nmodel.label -text "Number of models:"
    bind  .medium.nmodel.entry <Return> "focus .basic.pir.entry"
    # Attach the entry and label to the frame
    pack append .medium.nmodel \
            .medium.nmodel.label top \
            .medium.nmodel.entry top
    # Attach to the main window
    pack append .medium .medium.nmodel {left filly padx 50m}

    # Radio buttons for refinement method
    frame .medium.refine -bd 1m
    radiobutton .medium.refine.full -text Full -variable refinement \
            -value refine -anchor w
    radiobutton .medium.refine.local -text Local -variable refinement \
            -value local -anchor w
    radiobutton .medium.refine.none -text None -variable refinement \
            -value nothing -anchor w
    label .medium.refine.label -text "Refinement:"
    # Attach to frame
    pack append .medium.refine \
            .medium.refine.label {top fillx} \
            .medium.refine.full {top fillx} \
            .medium.refine.local {top fillx} \
            .medium.refine.none {top fillx}
    # Attach to main frame
    pack append .medium .medium.refine {right filly padx 50m}
    
}


##########################################################################
# proc BuildOptions
# -----------------
# Build the options section of the main window
# 22.08.95 Original    By: ACRM
#
proc BuildOptions { } {
    global AdvColour ActiveColour

    button .options.specify -text "Specify Alignment" \
            -command "SpecAlign" \
            -width 22 -height 2  \
            -activebackground $ActiveColour 

    pack append .options .options.specify {left expand pady 10}

    button .options.options -text "Options" \
            -command "Options" \
            -width 22 -height 2 \
            -activebackground $ActiveColour 

    pack append .options .options.options {left expand pady 10}

}


##########################################################################
# proc BuildButtons
# -----------------
# Build the buttons section of the main window
# 22.08.95 Original    By: ACRM
#
proc BuildButtons { } {
    global AdvColour ActiveColour PassiveColour

    button .buttons.quit -text "Quit" \
            -command "quit quit" \
            -width 10 -height 2 \
            -activebackground $ActiveColour \
            -background $PassiveColour 

    pack append .buttons .buttons.quit {left expand pady 10}

    button .buttons.help -text "Help!" \
            -command "MainHelp" \
            -width 10 -height 2 \
            -activebackground $ActiveColour

    pack append .buttons .buttons.help {left expand pady 10}

    button .buttons.run -text "Run" \
            -command "quit run" \
            -width 10 -height 2 \
            -activebackground $ActiveColour \
            -background $PassiveColour 

    pack append .buttons .buttons.run {left expand pady 10}

}


##########################################################################
# proc BuildWindowContents
# ------------------------
# Build the contents of the main window
# 22.08.95 Original    By: ACRM
#
proc BuildWindowContents { } {
    BuildFrames
    BuildBasic
    BuildMedium
    BuildOptions
    BuildButtons
}


##########################################################################
#                                                                        #
#                       START OF MAIN PROGRAM                            #
#                                                                        #
##########################################################################
# Read local.tcl which defines stuff for this local setup
#
source "$env(MINTDIR)/mint_local.tcl"

# Initialise the window manager
InitWM
# Initialise variables
InitVariables
# Build the window contents
BuildWindowContents
# Set the focus to the PIR filename
focus .basic.pir.entry

##########################################################################
#                                                                        #
#                         END OF MAIN PROGRAM                            #
#                                                                        #
##########################################################################
