# Customise these 2 for your site...
# ----------------------------------
# Root directory for installed MODELLER:
export MODINSTALL=/acrm/usr/local/apps/modeller6/
# Directory in which MINT is installed
export MINTDIR=/acrm/home/andrew/modeller

if [ -e $MODINSTALL ]; then
   # Root directory for the Protein DataBank (not essential, can be omitted):
   export PDB=/acrm/data/pdb/

   # MODELLER key. Change to the key provided by Andrej Sali:
   export KEY=********

   # Alias for mint
   alias mint='$MINTDIR/mint.tcl'

   # Set MODELLER environment variables and update the command path:
   if [ -e $MODINSTALL/bashrc ]; then
      source $MODINSTALL/bashrc
   fi

fi

