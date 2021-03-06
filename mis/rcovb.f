      SUBROUTINE RCOVB
C
C     RCOVB PERFORMS THE BACK-SUBSTITUTIONS TO OBTAIN THE G-SET
C     DISPLACEMENTS OF A SUBSTRUCTURE WHOSE LEVEL IS LOWER THAN OR
C     EQUAL TO THAT OF THE FINAL SOLUTION STRUCTURE (FSS).
C     FOR EACH SUBSTRUCTURE WHOSE DISPLACEMENTS ARE RECOVERED,
C     AN SOLN ITEM IS CREATED BY EDITING THE SOLN ITEM OF THE FSS.
C
      EXTERNAL         ANDF
      LOGICAL          MODAL
      INTEGER          MCBTRL(7)  ,DRY        ,STEP       ,FSS       ,
     1                 RFNO       ,UINMS      ,SCHK       ,UA        ,
     2                 SSNM1      ,SYSBUF     ,RSP        ,RDP       ,
     3                 RECT       ,UPPER      ,LOWER      ,SYM       ,
     4                 HMCB       ,UBMCB      ,UAOMCB     ,UAMCB     ,
     5                 TFLAG      ,SIGNAB     ,SIGNC      ,SCRM      ,
     6                 UGV        ,UI(5)      ,SCR2       ,SCR3      ,
     7                 SCR5       ,NAME(2)    ,BLANK      ,UVEC      ,
     8                 POVE       ,HORG       ,SCR1       ,GMASK     ,
     9                 PAO        ,UB         ,IZ(1)      ,SOFSIZ    ,
     O                 SOF1       ,SOF2       ,SOF3       ,BUF1      ,
     1                 BUF2       ,RC         ,SSNM(2)    ,EQSS      ,
     2                 BUF(1)     ,ANDF       ,UIMPRO     ,ENERGY    ,
     3                 RMASK      ,FILE       ,RD         ,RDREW     ,
     4                 WRT        ,WRTREW     ,REW        ,EOFNRW    ,
     5                 BUF3       ,BUF4
C     INTEGER          SCR6       ,SCR7       ,SRD        ,SWRT
      DOUBLE PRECISION DZ(1)
      CHARACTER        UFM*23     ,UWM*25     ,UIM*29     ,SFM*25    ,
     1                 SWM*27
      COMMON /XMSSG /  UFM        ,UWM        ,UIM        ,SFM       ,
     1                 SWM
      COMMON /BLANK /  DRY        ,LOOP       ,STEP       ,FSS(2)    ,
     1                 RFNO       ,NEIGV      ,LUI        ,UINMS(2,5),
     2                 NOSORT     ,UTHRES     ,PTHRES     ,QTHRES
      COMMON /RCOVCR/  ICORE      ,LCORE      ,BUF1       ,BUF2      ,
     1                 BUF3       ,BUF4       ,SOF1       ,SOF2      ,
     2                 SOF3
      COMMON /RCOVCM/  MRECVR     ,UA         ,PA         ,QA        ,
     1                 IOPT       ,SSNM1(2)   ,ENERGY     ,UIMPRO    ,
     2                 RANGE(2)   ,IREQ       ,LREQ       ,LBASIC
      COMMON /SYSTEM/  SYSBUF     ,NOUT
      COMMON /NAMES /  RD         ,RDREW      ,WRT        ,WRTREW    ,
     1                 REW        ,NOREW      ,EOFNRW     ,RSP       ,
     2                 RDP        ,CSP        ,CDP        ,SQUARE    ,
     3                 RECT       ,DIAG       ,UPPER      ,LOWER     ,
     4                 SYM
      COMMON /MPYADX/  HMCB(7)    ,UBMCB(7)   ,UAOMCB(7)  ,UAMCB(7)  ,
     1                 MPYZ       ,TFLAG      ,SIGNAB     ,SIGNC     ,
     2                 MPREC      ,SCRM
      COMMON /ZZZZZZ/  Z(1)
      EQUIVALENCE      (BUF(1)    ,Z(1))
      EQUIVALENCE      (Z(1)      ,IZ(1)      ,DZ(1))
      DATA    NAME  /  4HRCOV,4HB          /
      DATA    UGV   ,  SCR1,SCR2,SCR3,SCR5 /
     1        106   ,  301, 302, 303, 305  /
      DATA    UI    /  204, 205, 206, 207, 208 /
      DATA    UVEC  ,  POVE,HORG,EQSS / 4HUVEC,4HPOVE,4HHORG,4HEQSS /
      DATA    IB    ,  SCHK / 1,  3   /
      DATA    SCR6  ,  SCR7,SRD,SWRT  / 306,307, 1,2 /
      DATA    RMASK /  469762048  /
      DATA    GMASK /  268435456  /
      DATA    MMASK /  134217728  /
      DATA    BLANK /  4H         /
C
C     INITIALIZE
C
      LCOREZ= KORSZ(Z) - LREQ
      SOF1  = LCOREZ - SYSBUF + 1
      SOF2  = SOF1 - SYSBUF - 1
      SOF3  = SOF2 - SYSBUF
      BUF1  = SOF3 - SYSBUF
      BUF2  = BUF1 - SYSBUF
      BUF3  = BUF2 - SYSBUF
      BUF4  = BUF3 - SYSBUF
      LCORE = BUF4 - 1
      IF (LCORE .LE. 0) GO TO 9008
      CALL SOFOPN (Z(SOF1),Z(SOF2),Z(SOF3))
      UA    = 0
      PAO   = 0
      TFLAG = 0
      SIGNAB= 1
      SIGNC = 1
      MPREC = 0
      SCRM  = SCR5
C
C     FIND OUT HOW MANY UI FILES THERE ARE AND WHICH ONES
C
      DO 10 I = 1,5
      IZ(1) = UI(I)
      CALL RDTRL (IZ)
      IF (IZ(1) .LT. 0) UINMS(1,I) = 0
   10 CONTINUE
C
C     IF UINMS(1,I) = 0         THEN  FILE UI(I) IS PURGED
C     IF UINMS(1,I) = BLANK     THEN  FILE UI(I) IS AVAILABLE AND NOT
C                                     IN USE
C     IF UINMS(1,I) = OTHER     THEN  FILE UI(I) CONTAINS UGV FOR
C                                     SUBSTRUCTURE -OTHER-
C
      SSNM(1) = SSNM1(1)
      SSNM(2) = SSNM1(2)
C
C     IF SSNM IS THE FINAL SOLUTION STRUCTURE (FSS), NO RECOVERY IS
C     NECESSARY.
C
      IF (SSNM(1).NE.FSS(1) .OR. SSNM(2).NE.FSS(2)) GO TO 190
      UA = UGV
      GO TO 508
C
C     SEARCH THE SOF FOR A DISPLACEMENT MATRIX OF SSNM OR A HIGHER
C     LEVEL SUBSTRUCTURE FROM WHICH THE REQUESTED DISPLACEMENTS CAN BE
C     RECOVERED
C
  190 JLVL = 1
  200 CALL SOFTRL (SSNM,UVEC,MCBTRL)
      RC  = MCBTRL(1)
      IF (RC .EQ. 1) GO TO 270
      IF (RC.EQ.2 .AND. DRY.LT.0) GO TO 270
      IF (RC .EQ. 3) GO TO 210
      IF (RC .EQ. 5) CALL SMSG (3,UVEC,SSNM)
      IF (RC .EQ. 4) GO TO 500
      WRITE (NOUT,63070) UWM,SSNM1,SSNM
      GO TO 9200
C
C     NO UVEC AT THIS LEVEL.  SAVE SSNM IN A STACK AT TOP OF OPEN CORE
C     AND SEARCH FOR UVEC OF THE NEXT HIGHER LEVEL
C
  210 LASTSS = 2*JLVL - 1
      IZ(LASTSS  ) = SSNM(1)
      IZ(LASTSS+1) = SSNM(2)
      JLVL = JLVL + 1
      CALL FNDNXL (Z(LASTSS),SSNM)
      IF (SSNM(1) .NE. BLANK) GO TO 230
      WRITE (NOUT,63060) UWM,IZ(LASTSS),IZ(LASTSS+1)
      GO TO 9200
  230 IF (SSNM(1).NE.IZ(LASTSS) .OR. SSNM(2).NE.IZ(LASTSS+1)) GO TO 240
      WRITE (NOUT,63080) UWM,SSNM1,SSNM
      GO TO 9200
C
C     IF SSNM IS NOT THE FSS, LOOK FOR UVEC ON THE SOF.  IF DRY RUN,
C     EXIT.  IF IT IS THE FSS, SET UA=UGV.  IF UGV IS NOT PURGED GO TO
C     BEGIN BACK-SUBSTITUTION.  OTHERWISE, GIVE IT THE SAME TREATMENT
C     AS IF IT WERE NOT THE FSS.
C
  240 IF (SSNM(1).NE.FSS(1) .OR. SSNM(2).NE.FSS(2)) GO TO 200
      IF (DRY .LT. 0) GO TO 500
      UA = UGV
      MCBTRL(1) = UA
      CALL RDTRL (MCBTRL)
      IF (MCBTRL(1) .GT. 0) GO TO 340
      GO TO 200
C
C     FOUND A UVEC ON SOF FOR THIS LEVEL.  SEE IF IT HAS ALREADY BEEN
C     PUT ON A UI FILE.  (IF DRY RUN, EXIT)
C
  270 IF (DRY.LT.0 .OR. JLVL.EQ.1) GO TO 500
      DO 280 I = 1,5
      UA = UI(I)
      IF (SSNM(1).EQ.UINMS(1,I) .AND. SSNM(2).EQ.UINMS(2,I)) GO TO 340
  280 CONTINUE
C
C     DATA BLANK /4H    /
C
C     IT DOES NOT RESIDE ON ANY UI FILE.  FIND A UI FILE TO USE.
C
      J = 0
      DO 290 I = 1,5
      IF (UINMS(1,I) .EQ. 0) GO TO 290
      J = J + 1
      IF (UINMS(1,I) .EQ. BLANK) GO TO 310
  290 CONTINUE
      GO TO 297
C
C     ALL UI FILES SEEM TO BE IN USE.  DO ANY REALLY EXIST
C
  297 IF (J .EQ. 0) GO TO 320
C
C     AT LEAST ONE EXISTS.  RE-USE THE ONE WITH OLDEST DATA
C
      I = LUI + 1
      IF (I .GT. 5) I = 1
      J = I
  300 IF (UINMS(1,I) .NE. 0) GO TO 310
C
C     NO FILE THERE.  TRY NEXT ONE.
C
      I = I + 1
      IF (I .GT. 5) I = 1
      IF (I .EQ. J) GO TO 320
      GO TO 300
C
C     FOUND A UI FILE TO USE
C
  310 LUI = I
      UA  = UI(I)
      UINMS(1,I) = SSNM(1)
      UINMS(2,I) = SSNM(2)
      GO TO 330
C
C     ALL UI FILES ARE PURGED.  USE SCR1 INSTEAD
C
  320 UA = SCR1
C
C     COPY UVEC FROM SOF TO UA
C
  330 CALL MTRXI (UA,SSNM,UVEC,0,RC)
C
C     TOP OF BACK-SUBSTITUTION LOOP
C
  340 UB = UA
      UAOMCB(1) = 0
      ICORE = LASTSS  + 2
      IDPCOR= ICORE/2 + 1
C
C     CHECK IF THE EQSS ITEM IS THERE FOR THIS SUBSTRUCTURE
C
      CALL SFETCH (Z(LASTSS),EQSS,SCHK,RC)
      IF (RC .NE. 1) GO TO 6317
C
C     COMPUTE TIME TO RECOVER THIS LEVEL AND CHECK TIME-TO-GO
C
C     (A DETAILED TIME CHECK SHOULD BE CODED LATER.  FOR THE PRESENT,
C     JUST CHECK TO SEE IF TIME HAS RUN OUT NOW.)
C
      CALL TMTOGO (I)
      IF (I .LE. 0) GO TO 6309
C
C     CHECK REMAINING SPACE ON SOF.  FIRST CALCULATE HOW MUCH SPACE
C     THE RECOVERED DISPLACEMENT MATRIX WILL TAKE (ASSUMING IT IS FULL).
C
      MCBTRL(1) = UB
      CALL RDTRL (MCBTRL)
      I = MCBTRL(2)
C
C     NO. OF COLUMNS IN DISPLACEMENT MATRIX IN I
C
      CALL SOFTRL (Z(LASTSS),HORG,MCBTRL)
      RC = MCBTRL(1)
      ITEM = HORG
      IF (RC .GT. 1) GO TO 6317
      NROW = MCBTRL(3)
      J = I*NROW
C
C     NOW CHECK SPACE
C
      IF (SOFSIZ(I) .LT. J) GO TO 6310
C
C     CREATE THE SOLUTION ITEM FOR THE RECOVERED SUBSTRUCTURE.
C
      CALL RCOVLS (Z(LASTSS))
      IF (IOPT .LT. 0) GO TO 9000
C
C     FIND A UI FILE FOR DISPLACEMENTS
C
      J = 0
      DO 420 I = 1,5
      IF (UINMS(1,I) .EQ. 0) GO TO 420
      J = J + 1
      IF (UINMS(1,I) .EQ. BLANK) GO TO 440
  420 CONTINUE
C
C     NO UNUSED UI FILES ARE AVAILABLE.  IF TWO OR MORE UI FILES ARE
C     NOT PURGED, USE THE ONE WITH OLDEST DATA.  OTHERWISE, USE SCR2.
C     MAKE SURE WE DON T ASSIGN THE SAME FILE AS THE HIGHER
C     LEVEL DISPLACEMENTS ARE ON (UB)
C
      IF (J .LT. 2) GO TO 450
      I = LUI + 1
      IF (I .GT. 5) I = 1
      J = I
  430 IF (UINMS(1,I).NE.0 .AND. UI(I).NE.UB) GO TO 440
      I = I + 1
      IF (I .GT. 5) I = 1
      IF (I .EQ. J) GO TO 450
      GO TO 430
C
C     FOUND A UI FILE
C
  440 LUI = I
      UA  = UI(I)
      UINMS(1,I) = IZ(LASTSS  )
      UINMS(2,I) = IZ(LASTSS+1)
      GO TO 455
  450 UA = SCR2
C
C     IF THE RECOVERED SUBSTRUCTURE WAS NOT REDUCED GENERATE THE
C     DISPLACEMENTS DIRECTLY.
C     IF THE SUBSTRUCTURE WAS REDUCED AND THE UIMPROVED FLAG IS SET
C     AND THIS IS A NON-STATICS RUN GENERATE THE IMPROVED DISPLACEMENTS.
C     IF THE SUBSTRUCTURE WAS IN A GUYAN REDUCTION AND THIS IS A
C     STATICS RUN GENERATE THE LOADS ON THE OMMITED POINTS.
C
C     INCLUDE THE CHECK ON THE POVE ITEM ALSO TO BE COMPATABLE WITH
C     PREVIOUS SOFS WITH NO TYPE BITS
C
  455 CALL SOFTRL (Z(LASTSS),POVE,MCBTRL)
      IPOVE = MCBTRL(1)
      CALL FDSUB (SSNM,IDIT)
      RC = 4
      IF (IDIT .LT. 0) GO TO 6317
      CALL FMDI (IDIT,IMDI)
      MODAL = .FALSE.
      IF (ANDF(BUF(IMDI+IB),MMASK) .NE. 0) MODAL = .TRUE.
      IF (ANDF(BUF(IMDI+IB),RMASK).NE.0 .AND. UIMPRO.NE.0 .AND.
     1    RFNO.GT.2) GO TO 470
      IF (ANDF(BUF(IMDI+IB),GMASK).NE.0 .AND. RFNO.LE.2) GO TO 480
      IF (ANDF(BUF(IMDI+IB),RMASK).EQ.0 .AND. IPOVE.EQ.1 .AND.
     1    RFNO.LE.2) GO TO 480
      GO TO 490
C
C     IF THE USER REQUESTED AN IMPROVED VECTOR AND THIS IS A NONSTATICS
C     RUN THEN GENERATE IT.
C
  470 CALL RCOVUI (UB,Z(LASTSS),MODAL)
      IF (IOPT .LT. 0) GO TO 9000
      GO TO 495
C
C     GENERATE THE LOADS ON THE OMITED POINTS FOR REDUCED SUBSTRUCTURES
C     IF THIS IS A STATICS RUN
C
  480 CALL RCOVUO (0,UAOMCB(1),Z(LASTSS))
      IF (IOPT .LT. 0) GO TO 9000
C
C     MULIPLY AND ADD TO GET DISPLACEMENTS OF LOWER-LIVEL SUBSTRUCTURE.
C
C     COPY H OR G TRANSFORMATION MATRIX TO SCR3
C
      CALL SOFOPN (Z(SOF1),Z(SOF2),Z(SOF3))
  490 ITEM = HORG
      CALL MTRXI (SCR3,Z(LASTSS),HORG,0,RC)
      IF (RC .NE. 1) GO TO 6317
C
C     SETUP FOR MPYAD
C
      CALL SOFCLS
      HMCB(1) = SCR3
      UBMCB(1)= UB
      CALL RDTRL (HMCB)
      CALL RDTRL (UBMCB)
      IF (UAOMCB(1) .NE. 0) CALL RDTRL (UAOMCB)
      CALL MAKMCB (UAMCB,UA,HMCB(3),RECT,UBMCB(5))
      MPYZ = LCOREZ - ICORE - 7
      CALL MPYAD (DZ(IDPCOR),DZ(IDPCOR),DZ(IDPCOR))
      CALL WRTTRL (UAMCB)
C
C     COPY RECOVERED DISPLACEMENTS TO SOF
C
  495 CALL SOFOPN (Z(SOF1),Z(SOF2),Z(SOF3))
      CALL MTRXO (UA,Z(LASTSS),UVEC,0,RC)
C
C     END OF BACK-SUBSTITUTION LOOP
C     CLOSE AND REOPEN THE SOF TO GET ANY CONTROL BLOCKS WRITTEN TO
C     FILE
C
      CALL SOFCLS
      CALL SOFOPN (Z(SOF1),Z(SOF2),Z(SOF3))
      SSNM(1) = IZ(LASTSS)
      SSNM(2) = IZ(LASTSS+1)
      LASTSS  = LASTSS - 2
      JLVL    = JLVL - 1
      WRITE (NOUT,63120) UIM,JLVL,SSNM
      IF (JLVL .GT. 1) GO TO 340
C
C     NORMAL COMPLETION OF MODULE EXECUTION
C
  508 CONTINUE
  500 DO 510 I = 1,5
      IF (UINMS(1,I) .EQ. 0) UINMS(1,I) = BLANK
  510 CONTINUE
      CALL SOFCLS
      RETURN
C
C     ERROR PROCESSING
C
 6309 WRITE (NOUT,63090) SFM,IZ(LASTSS),IZ(LASTSS+1),SSNM,SSNM1
      N = -37
      GO TO 9100
 6310 WRITE (NOUT,63100) SWM,IZ(LASTSS),IZ(LASTSS+1),SSNM,SSNM1
      GO TO 9200
 6317 IF (RC .EQ. 2) RC = 3
      CALL SMSG (RC-2,ITEM,Z(LASTSS))
 9000 WRITE (NOUT,63170) SWM,SSNM1
      GO TO 9200
 9008 N = 8
 9100 CALL SOFCLS
      CALL MESAGE (N,FILE,NAME)
 9200 IOPT = -1
      GO TO 500
C
C     FORMAT STATEMENTS
C
63060 FORMAT (A25,' 6306, ATTEMPT TO RECOVER DISPLACEMENTS FOR NON-',
     1       'EXISTANT SUBSTRUCTURE ',2A4)
63070 FORMAT (A25,' 6307, WHILE ATTEMPTING TO RECOVER DISPLACEMENTS ',
     1       'FOR SUBSTRUCTURE ',2A4,1H,, /32X,'THE DISPLACEMENTS FOR ',
     2       'SUBSTRUCTURE ',2A4,' WERE FOUND TO EXIST IN DRY RUN ',
     3       'FORM ONLY.')
63080 FORMAT (A25,' 6308, NO SOLUTION AVAILABLE FROM WHICH DISPLACE',
     1       'MENTS FOR SUBSTRUCTURE ',2A4, /32X,'CAN BE RECOVERED.  ',
     2       'HIGHEST LEVEL SUBSTRUCTURE FOUND WAS ',2A4)
63090 FORMAT (A25,' 6309, INSUFFICIENT TIME REMAINING TO RECOVER DIS',
     1       'PLACEMENTS OF SUBSTRUCTURE ',2A4, /32X,'FROM THOSE OF ',
     2       'SUBSTRUCTURE ',2A4,'.  (PROCESSING USER RECOVER REQUEST',
     3       /32X,'FOR SUBSTRUCTURE ',2A4,1H))
63100 FORMAT (A27,' 6310, INSUFFICIENT SPACE ON SOF TO RECOVER DIS',
     1       'PLACEMENTS OF SUBSTRUCTURE ',2A4, /32X,' FROM THOSE OF ',
     2       'SUBSTRUCTURE ',2A4,' WHILE PROCESSING USER RECOVER ',
     3       'REQUEST', /32X,'FOR SUBSTRUCTURE ',2A4)
63120 FORMAT (A29,' 6312, LEVEL',I4,' DISPLACEMENTS FOR SUBSTRUCTURE ',
     1       2A4, /36X,'HAVE BEEN RECOVERED AND SAVED ON THE SOF.')
63170 FORMAT (A25,' 6317, RECOVER OF DISPLACEMENTS FOR SUBSTRUCTURE ',
     1       2A4,' ABORTED.')
      END
