# Customise these 2 for your site...
# ----------------------------------
# Root directory for installed MODELLER:
setenv MODINSTALL /acrm/usr/local/apps/modeller6/
# Directory in which MINT is installed
setenv MINTDIR      /acrm/home/andrew/modeller

if (-e $MODINSTALL) then
   # Root directory for the Protein DataBank (not essential, can be omitted):
   setenv PDB /acrm/data/pdb/

   # MODELLER key. Change to the key provided by Andrej Sali:
   setenv KEY ********

   # Set MODELLER environment variables and update the command path:
   if (-e $MODINSTALL/bashrc) source $MODINSTALL/bashrc

   # Alias for mint
   alias  mint         $MINTDIR/mint.tcl
endif
