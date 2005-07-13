#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/utsname.h>
#include <unistd.h>

/* GAT Header Files */
#include "GAT.h"

/* Static function prototypes */
static GATSoftwareDescription 
       create_software_description (GATContext   context, 
                                    const char*  exe, 
                                    int          nargs, 
                                    const char** args);

static GATResourceDescription 
       create_hardware_resource_description (const char* host);

int main (int argc, char *argv[])
{
  char*  exe   = NULL;
  char*  host  = NULL;
  int    nargs = argc - 2;
  char** args  = &argv[2];

  GATResult         retval   = GAT_FAIL;
  GATContext        context  = NULL;
  GATResourceBroker broker   = NULL;
  GATJob            job      = NULL;
  GATSoftwareDescription sd  = NULL;
  GATResourceDescription hrd = NULL;
  
  /* Call this before any other GAT call! Otherwise it will fail. */
  context = GATContext_Create();
  
  if ( argc < 3 )
  {
     printf ("\n\tUsage: %s <host> <binary> [args]\n"
             "\n\trun the given program on the given host.\n\n", argv[0]);
    exit (1);
  }

  /* store away args */
  host = GATUtil_strdup (argv[1]);
  exe  = GATUtil_strdup (argv[2]);
  
  /* submit the job to the resource broker */
  broker = GATResourceBroker_Create (context, 0, 0);
  
  /* create the software description of the job to start */
  sd = create_software_description (context, exe, nargs, (char const **)args);

  /* create a hardware resource description describing the required job 
     environment */
  hrd = create_hardware_resource_description (host);

  /* test job submission through a resource description */
  {
    GATJobID_const    jobid = NULL;
    GATJobDescription jd    = NULL;
    
    /* make a job description out of the software and hardware resource 
       description */
    jd = GATJobDescription_Create_Description (context, sd, hrd);
    
    /* submit a new job */
    GATResourceBroker_SubmitJob (broker, jd, &job);

    /* time for decent output */
    sleep (1);

    /* retrieve the GAT job id of the newly created job */
    GATJob_GetJobID (job, &jobid);
    printf ("started %s: %s\n", exe, GATString_GetBuffer (jobid));
    
    /* clean up memory */
    GATJobDescription_Destroy (&jd);
  }
  
  /* free up all allocated memory */
  GATJob_Destroy                 (&job);
  GATResourceBroker_Destroy      (&broker);
  GATResourceDescription_Destroy (&hrd);
  GATSoftwareDescription_Destroy (&sd);
  GATContext_Destroy             (&context);

  free   (exe);

  return (0);
}

/* Local functions */

/* create a software description describing the job to start */
static GATSoftwareDescription
       create_software_description (GATContext   context, 
                                    const char*  exe, 
                                    int          nargs, 
                                    const char** args)
{
  GATSoftwareDescription sw_desc    = NULL;
  GATLocation            location   = NULL;
  GATList_String         arguments  = NULL;
  GATTable               attributes = NULL;
  GATFile                file       = NULL;
  int i = 0;
  
  /* create and fill the attribute table */
  attributes = GATTable_Create ();

  /* create "location" attribute" */
  location = GATLocation_Create (exe);
  
  GATTable_Add_GATObject(attributes, "location", 
    GATLocation_ToGATObject_const (location));    

  /* create and fill the "arguments" attribute */
  arguments = GATList_String_Create ();

  for (i = 0; i < nargs; ++i)
  {
    GATList_String_Insert (arguments, 
                           GATList_String_End (arguments), 
                           args[i]);
  }

  GATTable_Add_GATObject (attributes, "arguments", 
     GATList_String_ToGATObject_const (arguments));

  /* create the software description object */
  sw_desc = GATSoftwareDescription_Create (attributes);

  /* free the allocated memory */
  GATList_String_Destroy (&arguments);
  GATLocation_Destroy    (&location);
  GATTable_Destroy       (&attributes);

  return (sw_desc);
}

/* create a hardware resource description describing the required job 
   environment */
static GATResourceDescription 
       create_hardware_resource_description (const char* host)
{
  GATHardwareResourceDescription hw_desc      = NULL;
  GATTable                       requirements = NULL;
    
  /* create and fill the requirements table */
  requirements = GATTable_Create ();

  /* add required OS parameters to the requirements table */
  GATTable_Add_float  (requirements, "memory.size",  0.256f);
  GATTable_Add_float  (requirements, "disk.size",    10.f);
  GATTable_Add_float  (requirements, "cpu.speed",    1.f);
  GATTable_Add_String (requirements, "cpu.type",     "unknown");
  GATTable_Add_String (requirements, "machine.type", "i686");
  GATTable_Add_String (requirements, "machine.node", host);

  /* create the software Resource description */
  hw_desc = GATHardwareResourceDescription_Create (requirements);

  GATTable_Destroy (&requirements);
  
  return (GATHardwareResourceDescription_ToGATResourceDescription (hw_desc));
}

