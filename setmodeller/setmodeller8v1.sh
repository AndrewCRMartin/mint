# Customise these 2 for your site...
# ----------------------------------
# Root directory for installed MODELLER:
export MODINSTALL=/usr/local/modeller8v1/
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
   MODINSTALL8v1=/usr/local/modeller8v1
   EXECUTABLE_TYPE8v1=i386-intel
   LIBS_LIB8v1=$MODINSTALL8v1/modlib/libs.lib
   KEY_MODELLER8v1=********
   mod=mod8v1
   export MODINSTALL8v1 EXECUTABLE_TYPE8v1 LIBS_LIB8v1 KEY_MODELLER8v1 mod
   PATH=$PATH:$MODINSTALL8v1/bin
   ulimit -S -s unlimited
   alias mod=mod8v1
fi

