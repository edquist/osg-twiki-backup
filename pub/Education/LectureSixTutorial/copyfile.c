/* System Header Files */
#include <stdio.h>

/* GAT Header Files */
#include "GAT.h"
#include "GATTestUtils.h"

int main (int argc, char *argv[])
{
  GATContext  context = NULL;
  GATLocation name1   = NULL;
  GATLocation name2   = NULL;
  GATFile     file1   = NULL;
  GATResult   retval  = GAT_FAIL;

  /* check for correct invocation */
  if ( argc < 2 )
  {
     printf ("\n\tUsage: %s <src> <target>\n"
             "\n\tprogram does:\n"
             "\n\t\tcp <name1> <name2>\n\n" , argv[0]);
     exit   (1);
  }
  
  /* initialize GAT: create context */
  context  = GATContext_Create   ();

  /* create URLs for all file names */
  name1    = GATLocation_Create  (argv[1]);
  name2    = GATLocation_Create  (argv[2]);

  /* create initial file object */
  file1    = GATFile_Create (context, name1, 0);

  /* cp <name1> <name2> */
  retval = GATFile_Copy   (file1, name2, GATFileMode_Overwrite);
  GAT_TEST_TRACE(retval == GAT_SUCCESS, context);

  /* clean up */
  GATFile_Destroy     (&file1);
  GATLocation_Destroy (&name1);
  GATLocation_Destroy (&name2);
  GATContext_Destroy  (&context);

  return (0);
}

