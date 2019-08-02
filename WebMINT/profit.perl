#!/usr/local/bin/perl
#*************************************************************************
#
#   Program:    prefit
#   File:       profit.perl
#   
#   Version:    V0.1
#   Date:       06.02.97
#   Function:   HTTP query server for running modeller
#   
#   Copyright:  (c) UCL, Dr. Andrew C. R. Martin 1997
#   Author:     Dr. Andrew C. R. Martin
#   Address:    Biomolecular Structure & Modelling Unit,
#               Department of Biochemistry & Molecular Biology,
#               University College,
#               Gower Street,
#               London.
#               WC1E 6BT.
#   Phone:      (Home) +44 (0)1372 275775
#   EMail:      martin@biochem.ucl.ac.uk
#               andrew@stagleys.demon.co.uk
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
#   V0.1  06.02.97 Original    By: ACRM
#
#*************************************************************************
# Customisation variables
# -----------------------
# The directory used for temporary files. Must be world writable
$tmpdir  = "/home/bsm/martin/modeller/WebMINT/temp";
$htmldir = "/home/bsm/martin/public_html/dynamic";

# The name of the profit program
$profit   = "/home/bsm/martin/bin/profit";
$gnuplot  = "/usr/local/bin/gnuplot";
$ppmtogif = "/usr/local/apps/netpbm/ppmtogif";
$pbmtoxbm = "/usr/local/apps/netpbm/pbmtoxbm";

# Parameters to define how the PDB is stored
$pdbdir  = "/data/pdb_release/all/";
$pdbprep = "pdb";
$pdbext  = ".ent";

# Turn on true CGI version
$cgi_version = 1;

#*************************************************************************
# Main Program
# ------------
# Sets names of external programs and environment variables they require.
# Gets and parses the HTTP form input information. Build a sequence file
# and tests it using the chothia program.
# 
# 06.02.97 Original    By: ACRM
# 

# Set the name of the file which stores the commands and of the model
# PDB file
$comfile   = "$tmpdir/profit_$$.com";
$modfile   = "$tmpdir/model_$$.pdb";
$outfile   = "$tmpdir/profit_$$.out";
$byresfile = "$tmpdir/byres_$$.dat";
$gifname   = "byres_$$.gif";
$giffile   = "$htmldir/$gifname";

# Set environment variables for external programs
$ENV{'DATADIR'}    = "/home/bsm/martin/data";


if($cgi_version)
{
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
    $pdbdata = $CgiData{'modelpdb'};
    $pdbcode = $CgiData{'pdbcode'};
}
else
{
    $pdbdata = "DUMMY";
    $pdbcode = "DUMMY";
}

$pdbfile = $pdbdir . $pdbprep . $pdbcode . $pdbext;
&WriteHTMLHead();

&WritePDB($modfile, $pdbdata);
$rms = &RunProFit($comfile, $modfile, $pdbfile, $outfile, $byresfile);

&DoByResGraph($byresfile, $giffile);

&DisplayResults($rms, $gifname);
&WriteHTMLTail();

&CleanUp;



## END OF MAIN PROGRAM

#*************************************************************************
sub CleanUp
{
    unlink("$tmpdir/br_$$.dat");
    unlink("$tmpdir/byres_$$.dat");
    unlink("$tmpdir/byres_$$.pbm");
    unlink("$tmpdir/gnuplot_$$.com");
    unlink("$tmpdir/model_$$.pdb");
    unlink("$tmpdir/profit_$$.com");
    unlink("$tmpdir/profit_$$.out");
}

#*************************************************************************
sub DoByResGraph
{
    local ($byresfile, $giffile) = @_;

    $gpcom   = "$tmpdir/gnuplot_$$.com";
    $pbmfile = "byres_$$.pbm";
    $brfile  = "br_$$.dat";

    `awk '{print \$1, \$(NF)}' $byresfile > $tmpdir/$brfile`;

    open(COM, ">$gpcom") || die "Can't write gnuplot control file";
    print COM "set terminal pbm\n";
    print COM "set output \"$pbmfile\"\n";
    print COM "set xlabel \"Residue number\"\n";
    print COM "set ylabel \"RMSd (Angstroms)\"\n";
    print COM "set nokey\n";
    print COM "plot '$brfile' with lines\n";
    close(COM);

    # Run gnuplot
    `cd $tmpdir; $gnuplot $gpcom`;
    # Convert to a GIF
    `cd $tmpdir; $ppmtogif $pbmfile >$giffile`;
}

#*************************************************************************
sub DisplayResults
{
    local ($rms,$gifname) = @_;

    print "<p>RMS deviation on $gnfitted CA atoms was: $rms Angstroms</p>\n";

    print "<p><img src=\"http://www.biochem.ucl.ac.uk/~martin/dynamic/$gifname\"></p>\n";
}

#*************************************************************************
# Write a control file for ProFit
sub RunProFit
{
    local($comfile, $modfile, $pdbfile, $outfile, $byresfile) = @_;
    local($junk, $rms);

    $gnfitted = 0;

    open(COM,">$comfile") || die "Error opening ProFit control file for writing";
    print COM "ref $pdbfile\n";
    print COM "mob $modfile\n";
    print COM "gappen 30\n";
    print COM "align\n";
    print COM "atoms ca\n";
    print COM "fit\n";
    print COM "nfit\n";
    print COM "residue $byresfile\n";

    close(COM);

    # Actually run ProFit
    `$profit <$comfile >$outfile`;

    open(COM, $outfile) || die "Can't open ProFit output file for reading";
    while(<COM>)
    {
        if(/RMS:/)
        {
            ($junk, $rms) = split(/RMS: /);
        }
        elsif(/Number of fitted atoms/)
        {
            ($junk, $gnfitted) = split(/atoms: /);
        }
    }
    close(COM);

    return($rms);
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
sub WritePDB
{
    local ($modfile, $contents) = @_;

    open(PDB, ">$modfile");
    print PDB "$contents\n";
    close(PDB);
}


#*************************************************************************
sub WriteHTMLHead
{
    print "<html><head><title>ProFit - Results</title>\n";
    print "<link rev=\"made\" href=\"mailto:martin\@biochem.ucl.ac.uk\">\n";
    print "</head>\n";
    print "<body bgcolor=FFFFFF>\n";
    print "<p><h1><font color=\"FF0000\">ProFit: Fitting Results</font></h1></p>\n";
}

#*************************************************************************
sub WriteHTMLTail
{
    print "</body>\n";
    print "</html>\n";
}
