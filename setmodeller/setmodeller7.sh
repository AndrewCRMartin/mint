# Customise these 2 for your site...
# ----------------------------------
# Root directory for installed MODELLER:
export MODINSTALL=/usr/local/modeller7v7/
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
   MODINSTALL7v7=/usr/local/modeller7v7
   EXECUTABLE_TYPE7v7=i386-intel
   LIBS_LIB7v7=$MODINSTALL7v7/modlib/libs.lib
   KEY_MODELLER7v7=********
   mod=mod7v7
   export MODINSTALL7v7 EXECUTABLE_TYPE7v7 LIBS_LIB7v7 KEY_MODELLER7v7 mod
   PATH=$PATH:$MODINSTALL7v7/bin
   ulimit -S -s unlimited
   alias mod=mod7v7
fi

