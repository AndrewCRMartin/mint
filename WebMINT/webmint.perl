#!/usr/local/bin/perl
#*************************************************************************
#
#   Program:    webmint
#   File:       webmint.perl
#   
#   Version:    V0.1
#   Date:       18.10.96
#   Function:   HTTP query server for running modeller
#   
#   Copyright:  (c) UCL/Dr. Andrew C. R. Martin 1995-6
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
#   V1.0  19.05.95 Original    By: ACRM
#   V1.1  08.02.96 Added comment about checking the sequence if there
#                  are lots of errors
#   V1.2  29.02.96 When user requests the Kabat numbering, the alignment
#                  is also displayed
#   V1.3  08.05.96 Now does multiple runs of chothia program with 
#                  different data files
#
#*************************************************************************
# Customisation variables
# -----------------------
# The directory used for temporary files. Must be world writable
$tmpdir  = "/home/bsm/martin/modeller/WebMINT/temp";

# The name of the modeller program
$modeller = "/home/bsm/martin/sg/bin/modeller3/bin/mod3";

# The name of the pdb to seg conversion program
$pdbseg = "/home/bsm/martin/modeller/pdb2seg";

$runmod = "/home/bsm/martin/modeller/WebMINT/runmod";

# Parameters to define how the PDB is stored
$pdbdir = "/data/pdb_release/all/";
$pdbprep = "pdb";
$pdbext = ".ent";

# Cause contents of files to be printed to the calling Web page
#$testing = 1;


#*************************************************************************
# Main Program
# ------------
# Sets names of external programs and environment variables they require.
# Gets and parses the HTTP form input information. Build a sequence file
# and tests it using the chothia program.
# 
# 19.05.95 Original    By: ACRM
# 
# The user to receive messages when a test has been run
$MailRecipient = "martin";
# Don't send mail if query came from this host
$NoMailHost    = "bsmir06";
# Set the name of the topfile which stores the commands
$topfile = "$tmpdir/webmint_$$.top";
$pirfnam = "webmint_$$.pir";
$segfile = "$tmpdir/webmint_$$.seg";

# External Programs
$bindir    = "/home/bsm/martin/bin";

# Set environment variables for external programs
$ENV{'DATADIR'}    = "/home/bsm/martin/data";

# Get environment variables from the HTTP form
$method     = $ENV{'REQUEST_METHOD'};
$type       = $ENV{'CONTENT_TYPE'};
$length     = $ENV{'CONTENT_LENGTH'};
$RemoteHost = $ENV{'REMOTE_HOST'};

# Turn on flushing
$| = 1;

# Output MIME header information
print "Content-type: text/html\n\n";

# Check the method and type are correct
if($method ne "POST")
{
    print "<p><h2>Error:</h2>\n";
    print "This script may only be referenced using the http POST method.\n";
    print 'See <a href="http://www.ncsa.uiuc.edu/SDG/Software/Mosaic/Docs/fill-out-forms/overview.html">forms overview</a> for details';
    print "</p>\n\n";
    print "<p>Supplied method was: $method</p>\n\n";
    exit 1;
}
if(!($type =~ "multipart/form-data"))
{
    print "<p><h2>Error:</h2>\n";
    print "This script can only be used to decode http FORM data results.</p>\n";
    print "Type is $type\n";
    exit 1;
}

# Extract the data boundary
($junk,$boundary) = split('boundary=',$type);

# Parse the input
%CgiData = &ParseInput($boundary);
$pirfile = $CgiData{'pirfile'};
$sequence = $CgiData{'sequence'};
$templates = $CgiData{'templates'};
$refinement = $CgiData{'refinement'};

&WritePIR($pirfnam, $pirfile, $sequence);
&WriteTop($topfile, $pirfnam, $templates, $refinement, $seqname, $segfile);

&TestPrint($topfile, $pirfnam) if($testing);

&RunModeller($templates);
# &RunModeller($topfile, $pirfnam, $segfile, $templates);









# Send an EMail message to say that modeller has been run
if($RemoteHost ne $NoMailHost)
{
    &SendMail($MailRecipient, $address, $RemoteHost,
              $CgiData{'light'}, $CgiData{'heavy'});
}

## END OF MAIN PROGRAM


#*************************************************************************
# Write a .top file:
sub WriteTop
{
    local($topfile, $pirfnam, $templates, $refinement, $seqnam, $segfile) = @_;

    $templates =~ s/[,;:]/ /g;

    open(TOP,">$topfile") || die "Error openining TOP file for writing";
    print TOP "INCLUDE\n";
    print TOP "SET ATOM_FILES_DIRECTORY = '$tmpdir/:$pdbdir'\n";
    print TOP "SET PDB_EXT = '.ent'\n";
    print TOP "SET STARTING_MODEL = 1\n";
    print TOP "SET ENDING_MODEL = 1\n";
    print TOP "SET DEVIATION = 0\n";
    print TOP "SET KNOWNS = '$templates'\n";
    print TOP "SET HETATM_IO = off\n";
    print TOP "SET WATER_IO = off\n";
    print TOP "SET HYDROGEN_IO = off\n";
    if($refinement == 1)
    {
        print TOP "SET MD_LEVEL = 'refine2'\n";
    }
    elsif($refinement == 2)
    {
        print TOP "SET MD_LEVEL = 'refine1'\n";
    }
    elsif($refinement == 3)
    {
        print TOP "SET MD_LEVEL = 'nothing'\n";
    }
    print TOP "SET ALIGNMENT_FORMAT = 'PIR'\n";

    $temp = $pirfnam;
    for($i=0; $i<4; $i++)
    {
        chop $temp;
    }
    print TOP "SET SEQUENCE = '$temp'\n";
    print TOP "SET SEGFILE = '$segfile'\n";
    print TOP "CALL ROUTINE = 'full_homol'\n";

    close(TOP);
}                                                    








#*************************************************************************
# %cgidata ParseInput(TEXT boundary)
# ----------------------------------
# Routine to parse multipart/form-data input and build an associative 
# array of data items and their contents.
# 18.10.96 Original   By: ACRM
#
sub ParseInput 
{
    local($boundary) = @_;

    local($req,@data,$i,$key,$val,%output);

    # Place the input data into the $req string
    if ($ENV{'REQUEST_METHOD'} eq "GET") 
    {
        $req = $ENV{'QUERY_STRING'};
    }
    elsif ($ENV{'REQUEST_METHOD'} eq "POST") 
    {
        read(STDIN,$req,$ENV{'CONTENT_LENGTH'});  
    }

    # Remove ^M characters
    $req =~ s/\r//g;

    # Split at \n signs into the data array
    @data = split(/\n/,$req);     

    # For each item in the data array
    $key = "0";
    $val = "";
    $GotBoundary = 0;
    foreach $i (0..$#data)
    {
        # If we've hit a boundary, dump the last block into the assoc array
        if($data[$i] =~ /$boundary/)
        {
            # Make this check since the first line has a boundary
            if($key ne "0")
            {
                while(substr($val,-1) eq "\n")
                {
                    chop $val;
                }
                $output{$key} = $val;
            }
            $GotBoundary = 2;
            $val = "";
            $key = "";
        }
        else
        {
            if($GotBoundary == 2)
            {
                $GotBoundary--;
                ($junk,$key) = split('name=\"',$data[$i]);
                ($key,$junk) = split('\"',$key);
            }
            elsif($GotBoundary == 1)
            {
                $GotBoundary--;
            }
            else
            {
                $val .= "$data[$i]\n";
            }
        }
    }

    # Last key...
    if($key ne "0")
    {
        $output{$key} = $val;
    }

    # Return the associative array
    return(%output);
}


#*************************************************************************
sub WritePIR
{
    local ($pirfnam, $contents, $sequence) = @_;
    local ($fnam);

    $fnam = "$tmpdir" . "/" . "$pirfnam";

    open(PIR, ">$fnam");
    if($contents eq "")
    {
        print PIR ">P1;target\n";
        print PIR "Target to be modelled entered from Web page\n";
        print PIR "$sequence*\n";
    }
    else
    {
        print PIR "$contents\n";
    }
    close(PIR);
}

#*************************************************************************
# void SendMail($recipient, $address, $RemoteHost, $light, $heavy)
# ----------------------------------------------------------------
# Sends a mail message to $recipient to say that $address has done a
# search.
# 14.03.95 Original    By: ACRM
# 15.03.95 Modified to display sequences
# 
sub SendMail
{
    local($recipient, $address, $RemoteHost, $light, $heavy) = @_;
    local($message);

    $message = <<"EOF";
Subject: Chothia Canonical Test
To: $recipient

A Chothia Canonical test has been run (from node $RemoteHost) by $address 

Light chain was: 
$light

Heavy chain was: 
$heavy

EOF

    open(MAIL, "|/usr/lib/sendmail -t") || die " ";
    print MAIL $message;
    close(MAIL);
}


#*************************************************************************
sub TestPrint
{
    local($topfile, $pirfnam) = @_;

    open(TOP,$topfile);
    print "<h1>TOP FILE</h1>\n";
    print "<pre>\n";
    while(<TOP>)
    {
        print;
    }
    print "</pre>\n";
    close(TOP);
    

    open(PIR,"$tmpdir/$pirfnam");
    print "<h1>PIR FILE</h1>\n";
    print "<pre>\n";
    while(<PIR>)
    {
        print;
    }
    print "</pre>\n";
    close(PIR);
}


#*************************************************************************
sub RunModeller
{
    # Wait for the lock file to be removed
    while(-e "$tmpdir/Lock..Modeller")
    { 
        ;
    }

    # Create our own lock file
    open(LOCK,">$tmpdir/Lock..Modeller");
    close(LOCK);

    # Create the Run file if it doesn't exist
    if(! -e "$tmpdir/RunModeller")
    {
        open(RUNFILE,">$tmpdir/RunModeller");
        close(RUNFILE);
    }

    # Write our Modeller command to the Run file
    open(RUNFILE,">>$tmpdir/RunModeller");
    print RUNFILE "$runmod $$ $templates\n";
    close(RUNFILE);

    # Release the lock
    unlink("$tmpdir/Lock..Modeller");

    # Print a message for the user
    print "<h2>Take note!</h2>\n";
    print "The reference number for your model is: $$\n";

}

#*************************************************************************

sub RunModellerCrap
{
    local ($topfile, $pirfnam, $segfile, $templates) = @_;

    $modscript = "$tmpdir/runmod_$$.csh";

    open(SCRIPT,">$modscript") || die "Can't write modeller script";

    print SCRIPT "\#!/usr/bin/tcsh\n\n";
    print SCRIPT "source /home/bsm/martin/modeller/setmodeller\n";
    print SCRIPT "cd $tmpdir\n";

    print SCRIPT "$pdbseg $pirfnam $pdbdir $pdbprep $pdbext $segfile $templates\n\n";

    print SCRIPT "$modeller $topfile\n";

#   print SCRIPT "\\rm -f $topfile\n";
#   print SCRIPT "\\rm -f $tmpdir/$pirfnam\n";
#   print SCRIPT "\\rm -f $modscript\n";
#   print SCRIPT "\\rm -f $segfile\n";
    close SCRIPT;

    `chmod a+x $modscript`;
#    `rsh bsmir06 "$modscript &" &`;
    `rsh bsmir06 $modscript`;
}
    
