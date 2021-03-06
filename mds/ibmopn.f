      SUBROUTINE IBMOPN (*,*,LU,FNAME)        
C        
C     THIS MDS SUBROUTINE OPENS AN IBM FORTRAN LOGICAL UNIT WHICH HAS   
C     NOT BEEN ASSIGNED EXTERNALLY.        
C        
C     THIS SUBROUTINE USES THE FOLLOWING 3 IBM SYSTEM ROUTINES:        
C        
C     IQZDDN - TO DETERMINE WHETHER FILE ALREADY EXISTS OR NOT        
C     QQDCBF - TO DYNAMICALLY BUILD AN ATTRIBUTE LIST BY DDNAME        
C     QQGETF - TO DYNAMICALLY ALLOCATE FILE IN TSO OR BATCH        
C        
C     ALTERNATE RETURN 1: FILE OPENED SUCESSFULLY        
C     ALTERNATE RETURN 2: ERROR OPENING FILE        
C        
      CHARACTER  FNAME*8, OLD*3, NEW*3, ODNW*3        
      DATA       OLD, NEW / 'OLD', 'NEW' /        
C        
      ISTUS = IQZDDN(FNAME)        
      ODNW  = OLD        
      IF (ISTUS .NE. 0) GO TO 10        
      ODNW = NEW        
      CALL QQDCBF (FNAME,0,'F  ',80,80,DA)        
   10 CALL QQGETF (LU,FNAME,IERR)        
      IF (IERR .NE. 0) GO TO 20        
      OPEN (UNIT=LU,FILE=FNAME,STATUS=ODNW,ERR=20)        
      RETURN 1        
C        
C     ERROR        
C        
   20 RETURN 2        
      END        
