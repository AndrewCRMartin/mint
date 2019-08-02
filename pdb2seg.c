/*************************************************************************

   Program:    pdb2seg
   File:       pdb2seg.c
   
   Version:    V1.3
   Date:       20.09.01
   Function:   Create a seg alignment file for Modeller from a set of
               PDB codes
   
   Copyright:  (c) Dr. Andrew C. R. Martin 1995-2001
   Author:     Dr. Andrew C. R. Martin
   Address:    Biomolecular Structure & Modelling Unit,
               Department of Biochemistry & Molecular Biology,
               University College,
               Gower Street,
               London.
               WC1E 6BT.
   Phone:      (Home) +44 (0)1372 275775
               (Work) +44 (0)171 387 7050 X 3284
   EMail:      INTERNET: martin@biochem.ucl.ac.uk
               
**************************************************************************

   This program is not in the public domain, but it may be copied
   according to the conditions laid out in the accompanying file
   COPYING.DOC

   The code may be modified as required, but any modifications must be
   documented so that the person responsible can be identified. If someone
   else breaks this code, I don't want to be blamed for code that does not
   work! 

   The code may not be sold commercially or included as part of a 
   commercial product except as described in the file COPYING.DOC.

**************************************************************************

   Description:
   ============

**************************************************************************

   Usage:
   ======
   pdb2seg <pirfile> <pdbdir> <pdbprep> <pdbext> <outfile> <code> 
           [<code> .... ]

**************************************************************************

   Revision History:
   =================
   V1.0  23.08.95 Original
   V1.1  27.10.05 Looks first in the current directory for PDB files
   V1.2  22.10.96 Removes : from COMPND fields as these mess up the
                  fields in the .seg file
   V1.3  20.09.01 Initialise nres and nchain variables

*************************************************************************/
/* Includes
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "bioplib/pdb.h"
#include "bioplib/seq.h"
#include "bioplib/macros.h"
#include "bioplib/SysDefs.h"

/************************************************************************/
/* Defines and macros
*/
#define MAXBUFF  160
#define MAXCHAIN 16

/************************************************************************/
/* Globals
*/
BOOL gFullSeq = FALSE;

/************************************************************************/
/* Prototypes
*/
int main(int argc, char **argv);
void ReadPDBHeader(FILE *fp, char *name, char *source, 
                   REAL *resolution, REAL *rfactor, int *type);
PDB *FindChain(PDB *start, char chain);
void ProcessFile(FILE *out, char *pdbdir, char *pdbprep, char *pdbext, 
                 char *incode);
void LabelChainBreak(char *seq, char breakchar);
void WriteString(FILE *out, char *string, int maxlen);
void Usage(void);
void ProcessPIRFile(FILE *out, char *pirfile);


/************************************************************************/
/*>int main(int argc, char **argv)
   -------------------------------
   Main program for generation of a .seg file for Modeller

   23.08.95 Original    By: ACRM
*/
int main(int argc, char **argv)
{
   char pirfile[MAXBUFF],
        pdbdir[MAXBUFF],
        pdbext[MAXBUFF],
        pdbprep[MAXBUFF];
   FILE *out;

   gFullSeq = FALSE;

   if(argc < 7 || (argc < 8 && argv[1][0] == '-'))
   {
      Usage();
      return(0);
   }

   argc--;
   argv++;
   if(argv[0][0] == '-')
   {
      if(argv[0][1] == 'f')
      {
         gFullSeq = TRUE;
      }
      else
      {
         Usage();
         return(0);
      }
      argc--;
      argv++;
   }
   strcpy(pirfile, argv[0]);
   
   argc--;
   argv++;
   strcpy(pdbdir, argv[0]);
   
   argc--;
   argv++;
   strcpy(pdbprep, argv[0]);
   
   argc--;
   argv++;
   strcpy(pdbext, argv[0]);
   
   argc--;
   argv++;
   if((out = fopen(argv[0], "w"))==NULL)
   {
      fprintf(stderr,"Unable to open output file: %s\n",argv[0]);
      return(1);
   }
   
   while(argc > 1)
   {
      argc--;
      argv++;
      
      ProcessFile(out, pdbdir, pdbprep, pdbext, argv[0]);
   }

   ProcessPIRFile(out, pirfile);
   
   return(0);
}

   
/************************************************************************/
/*>void ReadPDBHeader(FILE *fp, char *name, char *source, 
                      REAL *resolution, REAL *rfactor, int *type)
   --------------------------------------------------------------
   Reads the required header information out of a PDB file

   23.08.95 Original    By: ACRM
   22.10.96 Replaces : with space in name and source fields
*/
void ReadPDBHeader(FILE *fp, char *name, char *source, 
                   REAL *resolution, REAL *rfactor, int *type)
{
   char buffer[MAXBUFF];
   int  i;
   BOOL GotName   = FALSE,
        GotSource = FALSE;

   strcpy(source, "unknown");
   strcpy(name,   "unknown");
   
   while(fgets(buffer, MAXBUFF, fp))
   {
      TERMINATE(buffer);
      
      if(!GotName && !strncmp(buffer, "COMPND", 6))
      {
         buffer[50] = '\0';
         strcpy(name,buffer+10);
         for(i=strlen(name)-1; i>0 && name[i] == ' '; i--);
         name[i+1] = '\0';
         for(i=0; name[i]; i++)
         {
            if(name[i]==':')
               name[i] = ' ';
         }
         GotName = TRUE;
      }         
      else if(!GotSource && !strncmp(buffer, "SOURCE", 6))
      {
         buffer[30] = '\0';
         strcpy(source,buffer+10);
         for(i=strlen(source)-1; i>0 && source[i] == ' '; i--);
         source[i+1] = '\0';
         for(i=0; source[i]; i++)
         {
            if(source[i]==':')
               source[i] = ' ';
         }
         GotSource = TRUE;
      }
      else if(!strncmp(buffer, "ATOM  ",6))
      {
         break;
      }
   }
   
   rewind(fp);
   if(!GetResolPDB(fp, resolution, rfactor, type))
   {
      *resolution = (REAL)(-1.0);
      *rfactor    = (REAL)(-1.0);
   }
   else
   {
      *rfactor *= 100.0;
   }
}


/************************************************************************/
/*>PDB *FindChain(PDB *start, char chain)
   --------------------------------------
   Finds a chain from a PDB file freeing memory of other chains

   23.08.95 Original    By: ACRM
*/
PDB *FindChain(PDB *start, char chain)
{
   PDB *pdb = NULL,
       *prev,
       *p;
   
   if(chain == ' ')
   {
      pdb = start;
   }
   else
   {
      /* Find the start of the specified chain, freeing anything before
         the chain.
      */
      prev = NULL;
      for(p=start; p!=NULL; NEXT(p))
      {
         if(p->chain[0] == chain)
         {
            pdb = p;
            break;
         }
         prev = p;
      }
      if(pdb==NULL)
      {
         FREELIST(start, PDB);
         return(NULL);
      }
      if(prev != NULL)
      {
         prev->next = NULL;
         FREELIST(start, PDB);
         start = NULL;
      }

      /* Find the next chain and free                                   */
      prev = NULL;
      for(p=pdb; p!=NULL; NEXT(p))
      {
         if(p->chain[0] != chain)
         {
            if(prev != NULL)
            {
               prev->next = NULL;
               FREELIST(p, PDB);
            }
            break;
         }
         prev = p;
      }
   }

   return(pdb);
}


/************************************************************************/
/*>void ProcessFile(FILE *out, char *pdbdir, char *pdbprep, char *pdbext,
                    char *incode)
   ----------------------------------------------------------------------
   Process a PDB file writing the required information to the output file

   23.08.95 Original    By: ACRM
   27.10.95 Tries to open the file in the current directory first.
*/
void ProcessFile(FILE *out, char *pdbdir, char *pdbprep, char *pdbext,
                 char *incode)
{
   FILE *in;
   PDB  *pdb = NULL, 
        *p;
   char code[16],
        filename[MAXBUFF],
        name[MAXBUFF],
        source[MAXBUFF],
        pdbname[MAXBUFF],
        chain,
        firstchain,
        lastchain,
        *seq;
   int  natoms,
        type,
        firstres,
        lastres;
   REAL resolution,
        rfactor;
   
   /* Build pdb code and chain name                                     */
   strcpy(code, incode);
   chain = ' ';
   if(strlen(code) == 5)
   {
      chain = code[4];
      code[4] = '\0';
   }
   
   /* Build filename without directory specification (so we try the
      current directory first) and try to open the file.
   */
   if(!strcmp(pdbprep,"-"))
   {
      sprintf(filename,"%s%s",code,pdbext);
      strcpy(pdbname,code);
   }
   else
   {
      sprintf(filename,"%s%s%s",pdbprep,code,pdbext);
      sprintf(pdbname,"%s%s",pdbprep,code);
   }

   if((in = fopen(filename,"r"))==NULL)
   {
      /* If we failed to open the file, build the filename again using the
         PDB directory specification and try again to open the file
      */
      if(!strcmp(pdbprep,"-"))
      {
         sprintf(filename,"%s%s%s",pdbdir,code,pdbext);
         strcpy(pdbname,code);
      }
      else
      {
         sprintf(filename,"%s%s%s%s",pdbdir,pdbprep,code,pdbext);
         sprintf(pdbname,"%s%s",pdbprep,code);
      }
      
      if((in = fopen(filename,"r"))==NULL)
      {
         fprintf(stderr,"Unable to read PDB file: %s\n",filename);
         return;
      }
   }

   /* Extract the required data from the PDB header                     */
   ReadPDBHeader(in, name, source, &resolution, &rfactor, &type);
   rewind(in);

   /* Read the PDB file and find the appropriate chain if specified,
      freeing the rest 
   */
   if((pdb = ReadPDBAtoms(in, &natoms))==NULL)
   {
      fprintf(stderr,"No memory for PDB linked list reading %s\n",
              filename);
      return;
   }
   if((pdb = FindChain(pdb, chain))==NULL)
   {
      fprintf(stderr,"Chain %c not found in PDB file %s\n",
              chain, filename);
      return;
   }

   if(gFullSeq)
   {
      /* Get the sequence out of the PDB linked list                    */
      if((seq = PDB2Seq(pdb))==NULL)
      {
         FREELIST(pdb, PDB);
         fprintf(stderr,"No memory for sequence in PDB file %s\n", 
                 filename);
         return;
      }
   }
   
   /* Find the first and last residue numbers and chain ids             */
   firstres   = pdb->resnum;
   firstchain = pdb->chain[0];
   p          = pdb;
   LAST(p);
   lastres    = p->resnum;
   lastchain  = p->chain[0];

   /* Write the code header to the file                                 */
   fprintf(out,">P1;%s\n",incode);
   
   /* Write the header info                                             */
   fprintf(out,"%s:%s:%d:%c:%d:%c:%s:%s:%.2f:%.2f\n",
           ((type==STRUCTURE_TYPE_NMR) ? "structureN" :
           ((type==STRUCTURE_TYPE_MODEL) ? "structureM" :
           "structureX")),
           pdbname,
           firstres, firstchain,
           lastres,  lastchain,
           name, source,
           resolution, rfactor);

   if(gFullSeq)
   {
      /* Add trailing *                                                 */
      seq = strcat(seq,"*");
      
      /* Change chain-break * to /                                      */
      LabelChainBreak(seq, '/');
      
      /* Write out the sequence                                         */
      WriteString(out, seq, 40);
      free(seq);
   }
   else
   {
      /* Just a star for the sequence means get it from the PDB file    */
      fprintf(out,"*\n");
   }
   
   
   /* Free linked list                                                  */
   FREELIST(pdb, PDB);
}   


/************************************************************************/
/*>void LabelChainBreak(char *seq, char breakchar)
   -----------------------------------------------
   Changes chain break * characters to the specified character. Doesn't
   affect the trailing *

   23.08.95 Original    By: ACRM
*/
void LabelChainBreak(char *seq, char breakchar)
{
   int i;
   
   for(i=0; i<strlen(seq)-1; i++)
   {
      if(seq[i] == '*')
         seq[i] = breakchar;
   }
}
   

/************************************************************************/
/*>void WriteString(FILE *out, char *string, int maxlen)
   -----------------------------------------------------
   Write a string with a maximum of maxlen characters per line. Makes
   no attempt to do anything sensible like splitting at spaces.

   23.08.95 Original    By: ACRM
*/
void WriteString(FILE *out, char *string, int maxlen)
{
   int i;

   for(i=0; i<strlen(string); i++)
   {
      fprintf(out,"%c",string[i]);
      if(!((i+1)%maxlen))
         fprintf(out,"\n");
   }
   if((i%maxlen))
      fprintf(out,"\n");
}


/************************************************************************/
/*>void Usage(void)
   ----------------
   Prints a usage message

   23.08.95 Original    By: ACRM
   22.10.96 V1.2
   20.09.01 V1.3
*/
void Usage(void)
{
   fprintf(stderr,"\npdb2seg V1.3 (c) 1995 Dr. Andrew C.R. Martin, \
UCL\n");
   fprintf(stderr,"Usage: pdb2seg [-f] <pirfile> <pdbdir> <pdbprep> \
<pdbext> <outfile> <code> [<code> .... ]\n");
   fprintf(stderr,"       -f        Create full sequence file\n");
   fprintf(stderr,"       <pirfile> A standard PIR file\n");
   fprintf(stderr,"       <pdbdir>  The PDB directory (with \
trailing /)\n");
   fprintf(stderr,"       <pdbprep> Any charactres prepended to PDB code \
in PDB directory\n");
   fprintf(stderr,"       <pdbext>  The extension (with .) used in the \
PDB directory\n");
   fprintf(stderr,"       <outfile> Output filename\n");
   fprintf(stderr,"       <code>    PDB code with optional trailing \
chain id\n");

   fprintf(stderr,"\nBuilds a SEG file for Modeller from a set of PDB \
codes and a PIR file\n");
   fprintf(stderr,"of the sequence to be modelled.\n\n");
}


/************************************************************************/
/*>void ProcessPIRFile(FILE *out, char *pirfile)
   ---------------------------------------------
   Proxess a standard PIR sequence file, rewriting it in the form
   required in the .seg file.

   23.08.95 Original    By: ACRM
   20.09.01 Initialise nchain and nres to zero
*/
void ProcessPIRFile(FILE *out, char *pirfile)
{
   FILE *fp;
   char *seqs[MAXCHAIN],
        *buffer,
        idbuff[MAXBUFF],
        *id,
        *idp;
   int  nchain = 0,
        nres = 0,
        i;
   BOOL punct,
        error;
   
   if((fp=fopen(pirfile, "r"))==NULL)
   {
      fprintf(stderr,"Unable to open PIR sequence file: %s\n",pirfile);
      return;
   }
   
   nchain = ReadPIR(fp, FALSE, seqs, MAXCHAIN, NULL, &punct, &error);

   strcpy(idbuff, pirfile);
   for(id=idbuff;(*id)!='\0';)
   {
      if((idp = strchr(id, '/'))==NULL)
         break;
      id = idp+1;
   }

   if((idp=strchr(id,'.'))!=NULL)
      *idp = '\0';

   fprintf(out, ">P1;%s\n",id);
   fprintf(out, "sequence:    :    : :    : :    :    :0.00:0.00\n");
   for(i=0; i<nchain; i++)
      nres += strlen(seqs[i]);
      
   if((buffer=(char *)malloc((nres+nchain+1)*sizeof(char)))==NULL)
   {
      fprintf(stderr,"No memory for neat sequence printing\n");
      
      for(i=0; i<nchain; i++)
      {
         fprintf(out,"%s",seqs[i]);
         if(i<nchain-1)
            fprintf(out,"/\n");
         else
            fprintf(out,"*\n");
         free(seqs[i]);
      }
   }
   else
   {
      buffer[0] = '\0';
      for(i=0; i<nchain; i++)
      {
         strcat(buffer,seqs[i]);
         strcat(buffer,"/");
      }
      buffer[strlen(buffer)-1] = '*';
      WriteString(out, buffer, 40);
      free(buffer);
   }

   fclose(fp);
}

