
/**********************************************************
 * 
 * @file: examples/example_60_-_job_submit.c
 * 
 * @description: 
 *   submit the given binary as job to any resource.
 *
 * Copyright (C) GridLab Project (http://www.gridlab.org/)
 * This file is part of the GAT Engine.
 * 
 * Contributed by Hartmut Kaiser <kaiser@cs.vu.nl>.
 * Contributed by Andre Merzky   <merzky@cs.vu.nl>.
 * 
 **********************************************************/

/*** LICENSE ***/

/* System Header Files */
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/utsname.h>
#include <unistd.h>

/* GAT Header Files */
#include <GAT.h>
#include <GATUtil.h>

/* Static function prototypes */
static GATSoftwareDescription 
       create_software_description (GATContext   context, 
                                    const char*  exe, 
                                    int          nargs, 
                                    const char** args);

static GATResourceDescription 
       create_hardware_resource_description (void);

/**********************************************************
 * This program creates a full job description for the 
 * given binary, and submits it to a resource broker.
 **********************************************************/
int main (int argc, char *argv[])
{
  char*  exe   = NULL;
  int    nargs = argc - 1;
  char** args  = &argv[1];

  GATContext        context  = NULL;
  GATResourceBroker broker   = NULL;
  GATJob            job      = NULL;
  GATSoftwareDescription sd  = NULL;
  GATResourceDescription hrd = NULL;
  
  /* Call this before any other GAT call! Otherwise it will fail. */
  context = GATContext_Create();
  
  if ( argc < 2 )
  {
     printf ("\n\tUsage: %s <binary> [args]\n"
             "\n\trun the given program.\n\n", argv[0]);
    exit (1);
  }

  /* store away args */
  exe = (char *) GATUtil_strdup (argv[1]);
  
  /* submit the job to the resource broker */
  broker = GATResourceBroker_Create (context, 0, 0);
  
  /* create the software description of the job to start */
  sd = create_software_description (context, exe, nargs, (char const **)args);

  /* create a hardware resource description describing the required job 
     environment */
  hrd = create_hardware_resource_description ();

  /* test job submission through a resource description */
  {
    GATJobID_const jobid = NULL;
    
    /* make a job description out of the software and hardware resource 
       description */
    GATJobDescription jd = NULL;

    jd = GATJobDescription_Create_Description (context, sd, hrd);
    
    /* submit a new job */
    GATResourceBroker_SubmitJob (broker, jd, &job);

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
//  GATTable		 environment = NULL;
  int i = 0;
  
  /* create and fill the attribute table */
  attributes = GATTable_Create ();

  /* create "location" attribute" */
  location = GATLocation_Create (exe);
  
  GATTable_Add_GATObject(attributes, "location", 
    GATLocation_ToGATObject_const (location));    

  /* create and fill the "arguments" attribute */
  arguments = GATList_String_Create ();
  for (i = 1; i < nargs; ++i)
  {
    GATList_String_Insert (arguments, 
                           GATList_String_End (arguments), 
                           args[i]);
  }
  GATTable_Add_GATObject (attributes, "arguments", 
     GATList_String_ToGATObject_const (arguments));

  /* create and file the "environment" attribute */
//  environment = GATTable_Create();
//  GATTable_Add_String(environment, "LD_LIBRARY_PATH", "/opt/intel_fc_80/lib/");
//  GATTable_Add_String(environment, "GAT_VERBOSE", "1");
//  GATTable_Add_GATObject(attributes, "environment", 
//		GATTable_ToGATObject_const(environment));

  GATTable_Add_String(attributes, "stdout", "/home/train37/result.out");
  GATTable_Add_String(attributes, "stderr", "/home/train37/result.err");

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
       create_hardware_resource_description (void)
{
  GATHardwareResourceDescription hw_desc      = NULL;
  GATTable                       requirements = NULL;
    
  /* create and fill the requirements table */
  requirements = GATTable_Create ();

  GATTable_Add_float  (requirements, "memory.size", 0.256f);
  GATTable_Add_float (requirements, "cpu.count", 1);
  GATTable_Add_String (requirements, "cpu.type", "unknown");

  /* create the software Resource description */
  hw_desc = GATHardwareResourceDescription_Create (requirements);

  GATTable_Destroy (&requirements);
  
  return (GATHardwareResourceDescription_ToGATResourceDescription (hw_desc));
}

