# Customise these 2 for your site...
# ----------------------------------
# Root directory for installed MODELLER:
export MODINSTALL=/usr/local/modeller8v0/
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
   MODINSTALL8v0=/usr/local/modeller8v0
   EXECUTABLE_TYPE8v0=i386-intel
   LIBS_LIB8v0=$MODINSTALL8v0/modlib/libs.lib
   KEY_MODELLER8v0=********
   mod=mod8v0
   export MODINSTALL8v0 EXECUTABLE_TYPE8v0 LIBS_LIB8v0 KEY_MODELLER8v0 mod
   PATH=$PATH:$MODINSTALL8v0/bin
   ulimit -S -s unlimited
   alias mod=mod8v0
fi

