      SUBROUTINE GFSMA
C
C     MODULE GFSMA  ( GENERAL FLUID / STRUCTURE MATRIX ASSEMBLER )
C
C
C     DMAP CALL
C
C        GFSMA  AXY,AFRY,KYY,DKAA,DKFRFR,KAA,MAA,GM,GO,USETS,USETF,
C               PHIA,PHIX,LAMA/KMAT,MMAT,GIA,POUT,HC/V,N,NOGRAV/
C               V,N,NOFREE/V,Y,KCOMP/V,Y,COMPTYP/V,N,FORM/V,Y,LMODES $
C
C     INPUT DATA BLOCKS
C
C        AXY    - STRUCTURE / FLUID AREA MATRIX
C        AFRY   - FREE SURFACE AREA MATRIX
C        KYY    - FLUID STIFFNESS MATRIX
C        DKAA   - STRUCTURE GRAVITY STIFFNESS MATRIX
C        DKFRFR - FREE SURFACE GRAVITY STIFFNESS MATRIX
C        KAA    - REDUCED STRUCTURE STIFFNESS MATRIX
C        MAA    - REDUCED STRUCTURE MASS MATRIX
C        GM     - MULTIPOINT CONSTRAINT TRANSFORMATION MATRIX
C        GO     - OMIT POINT TRANSFORMATION MATRIX
C        USETS  - STRUCTURE ONLY SET DEFINITION TABLE
C        USETF  - FLUID AND STRUCTURE SET DEFINITION TABLE
C        PHIA   - SOLUTION EIGENVECTORS  A - SET
C        PHIX   - SOLUTION EIGENVECTORS  X - SET
C        LAMA   - SOLUTION EIGENVALUE TABLE
C
C     OUTPUT DATA BLOCKS
C
C        KMAT   - COMBINATION FLUID / STRUCTURE STIFFNESS MATRIX
C        MMAT   - COMBINATION FLUID / STRUCTURE MASS MATRIX
C        GIA    - PRESSURE TRANSFORMATION MATRIX
C        POUT   - PARTITIONING VECTOR FOR MODAL DISPLACEMENTS
C        HC     - CONSTRAINT TRANSFORMATION MATRIX FOR INCOMPRESSIBLE
C                 APPROACH
C
C     PARAMETERS
C
C        NOGRAV  - GRAVITY FLAG  (-1 FOR NO GRAVITY)
C        NOFREE  - FREE SURFACE FLAG  (-1 FOR NO FREE SURFACE)
C        KCOMP   - COMPRESSIBILITY FACTOR  (DEFAULT = 1.0)
C        COMPTYP - TYPE OF COMPRESSIBLILITY COMPUTATIONS
C                       -1  STRUCTURE AND FREE SURFACE ARE COUPLED
C                           WITH A SPRING TO RESIST VOLUME CHANGE
C                        1  PURE INCOMPRESSIBLE - CONSTRAINT EQUATION
C                           IS GENERATED TO RESTRICT VOLUME CHANGE
C        FORM    - TYPE OF FORMULATION TO BE USED
C                       -1  DIRECT FORMULATION
C                        1  MODAL FORMULATION
C        LMODES  - NUMBER OF MODES USED IN MODAL FORMULATION
C                  ( -1 IF ALL STRUCTURE MODES ARE TO BE USED (
C
      INTEGER       FORM     ,COMPTP
C
C     MODULE PARAMETERS
C
      COMMON /BLANK/     NOGRAV   ,NOFREE   ,KCOMP   ,COMPTP
     1                  ,FORM     ,LMODES
C
C     LOCAL VARIABLES FOR GFSMOD AND GFSMO2
C
      COMMON /GFSMOX/    DUMMY(38)
C***********************************************************************
C
      IF(FORM .GT. 0) GO TO 10
C
C     DIRECT FORMULATION
C
      CALL GFSDIR
      GO TO 100
C
C     MODAL FORMULATION
C
   10 CALL GFSMOD
      CALL GFSMO2
C
C     MODULE COMPLETION
C
  100 CONTINUE
      RETURN
      END