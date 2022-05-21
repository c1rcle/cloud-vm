/* -*- mode: C; tab-width: 2; indent-tabs-mode: nil; fill-column: 79; coding: iso-latin-1-unix -*- */
/*
  hpcc.c
*/

#include <hpcc.h>
#include <ctype.h>

int
main(int argc, char *argv[]) {
  int myRank, commSize;
  char *outFname;
  FILE *outputFile;
  HPCC_Params params;
  time_t currentTime;
  void *extdata;

  MPI_Init( &argc, &argv );

  if (HPCC_external_init( argc, argv, &extdata ))
    goto hpcc_end;

  if (HPCC_Init( &params ))
    goto hpcc_end;

  MPI_Comm_size( MPI_COMM_WORLD, &commSize );
  MPI_Comm_rank( MPI_COMM_WORLD, &myRank );

  outFname = params.outFname;

  /* -------------------------------------------------- */
  /*                    SingleSTREAM                    */
  /* -------------------------------------------------- */

  MPI_Barrier( MPI_COMM_WORLD );

  BEGIN_IO( myRank, outFname, outputFile);
  fprintf( outputFile, "Begin of SingleSTREAM section.\n" );
  END_IO( myRank, outputFile );

  if (params.RunSingleStream) HPCC_SingleStream( &params );

  time( &currentTime );
  BEGIN_IO( myRank, outFname, outputFile);
  fprintf( outputFile,"Current time (%ld) is %s\n",(long)currentTime,ctime(&currentTime));
  fprintf( outputFile, "End of SingleSTREAM section.\n" );
  END_IO( myRank, outputFile );

  /* -------------------------------------------------- */
  /*                       MPIFFT                       */
  /* -------------------------------------------------- */

  MPI_Barrier( MPI_COMM_WORLD );

  BEGIN_IO( myRank, outFname, outputFile);
  fprintf( outputFile, "Begin of MPIFFT section.\n" );
  END_IO( myRank, outputFile );

  if (params.RunMPIFFT) HPCC_MPIFFT( &params );

  time( &currentTime );
  BEGIN_IO( myRank, outFname, outputFile);
  fprintf( outputFile,"Current time (%ld) is %s\n",(long)currentTime,ctime(&currentTime));
  fprintf( outputFile, "End of MPIFFT section.\n" );
  END_IO( myRank, outputFile );

  /* -------------------------------------------------- */
  /*                        HPL                         */
  /* -------------------------------------------------- */

  BEGIN_IO( myRank, outFname, outputFile);
  fprintf( outputFile, "Begin of HPL section.\n" );
  END_IO( myRank, outputFile );

  if (params.RunHPL) HPL_main( argc, argv, &params.HPLrdata, &params.Failure );

  time( &currentTime );
  BEGIN_IO( myRank, outFname, outputFile);
  fprintf( outputFile,"Current time (%ld) is %s\n",(long)currentTime,ctime(&currentTime));
  fprintf( outputFile, "End of HPL section.\n" );
  END_IO( myRank, outputFile );

  hpcc_end:

  HPCC_Finalize( &params );

  HPCC_external_finalize( argc, argv, extdata );

  MPI_Finalize();
  return 0;
}
