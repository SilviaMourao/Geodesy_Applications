c    Programa a funcionar em Windows NT (Set 97)
c
      PROGRAM EMPCOV                                                            
C PROGRAM EMPIRICAL COVARIANCE FUNCTION, PROGRAMMED BY C.C.TSCHERNING,          
C DEP.GEOD.SC.,OSU, 30 OCT. 73, VERSION 27 JAN 1974.                            
C UPDATED JULY, 9, 1987 BY CCT.                                                 
C                                                                               
C THE PROGRAM COMPUTES AN EMPIRICAL COVARIANCE FUNCTION OF SCALAR               
C OR VECTOR QUANTITIES ON A SPHERICAL SURFACE BY TAKING THE MEAN OF             
C PRODUCT-SUMS OF SAMPLES OF SCALAR VALUES OR OF THE LONGITUDIONAL AND          
C TRANSVERSAL COMPONENTS OF VECTOR QUANTITIES. COVARIANCES BETWEEN              
C MAXIMALLY 2 SETS OF SCALAR OR VECTOR QUANTITIES MAY BE COMPUTED.              
C EACH QUANTITY MUST BE IDENTIFIED BY AN INTEGER BETWEEN 0 AND 16. IF           
C A QUANTITY IS A SCALAR, IT IS IDENTIFIED BY FOR EXAMPLE (1,0).                
C                                                                               
C THE FOLLOWING CODES MAY BE USED:                                              
C                                                                               
C THE FOLLOWING CODES MAY BE USED:                                              
C GEOID UNDULATIONS, HEIGHT ANOMALIES, SEA SURFACE HEIGHTS       1              
C GRAVITY DISTURBANCES                                           2              
C GRAVITY ANOMALIES                                              3              
C RADIAL DERIVATIVES OF GRAVITY ANOMALIES                        4              
C RADIAL DERIVATIVES OF GRAVITY DISTURBANCES                     5              
C MERIDIAN COMPONENT OF DEFLECTION OF THE VERTICAL               6              
C PRIME VERTICAL COMPONENT OF SAME                               7              
C GRAVITY ANOMALY GRADIENT, MERIDIAN COMPONENT                   8              
C   -       -        -    , PRIME VERTICAL COMPONENT             9              
C   -     DISTURBANCE GRADIENT, MERIDIAN COMPONENT              10              
C   -          -          -   , PRIME VERTICAL                  11              
C 2*MIXED SECOND ORDER DERIVATIVE                               12              
C DIFFERENCE BETWEEN HORIZONTAL 2'ORDER DERIVATIVES             13              
C                                                                               
C IF DOUBLE PRECISION IS NEEDED, ACTIVATE                                       
      IMPLICIT double precision (A-H,O-Z)            
C IF FORTRAN 77 IS USED, ACTIVATE STATEMENTS WITH 'C F77' IN FRONT.             
C IF A REAL CONTAIN 4 CHARACTERS, CHANGE FORMATS WITH A6 TO A8.                 
      LOGICAL LTEST,LFOU1,LFOU2,LPUNCH,LFLAT,LSTOP,LPLOT,LVECT,LSMEAN,          
     *LVECTQ,LNOCR,LFOU3,LFOU4,LDOUBL,RC8000,LAREA                              
       CHARACTER*80 DNAME(2)
C IF NOT RC8000 DELETE THE FOLLOWING 4 DECLARATION STATEMENTS.                  
c      EXTERNAL IN,READSTRING,NONPRINT               
c      INTEGER READSTRING                            
c      ZONE IN                                       
c      LONG DNAME,NO                                 
      INTEGER*4 NO                                        
      character*80 spcFile, fileIn, fileOut
c      DIMENSION DNAME(2),SCAL(4),ITYPE(15000,2),DG(15000,2)                       
      DIMENSION SCAL(4),ITYPE(15000,2),DG(15000,2)                       
      COMMON /CMM/ COSLA(15000),SINLA(15000),RLON(15000),COV(200,10),              
     *SSCOV(200,10),S(4),SS(4),NUM(200,10),FMT(10),IPLOT(1428),                 
     *NVAL(10),IHIST(25,4),INUM(4),IOTY(4),IONU,I,K,IDLA,IDLO                   
      DATA COV,SSCOV,S,SS,NUM,INUM,NVAL,IHIST,I,K,IDLA,IDLO                     
     */4008*0.0,2118*0/                                                         
      DATA IOTY,IONU/4*-1,0/                                                    
C IF NOT RC8000 DELETE THE FOLLOWING TWO LINES.                                 
c      ZONE FILE7(128,1,STDERROR),FILE8(128,1,STDERROR),
c     *FILE9(128,1,STDERROR)                            
       RC8000=.FALSE.                                   
C IF THE PROGRAM IS NOT RUN ON AN RC8000 COMPUTER, THEN DEACTIVATE              
C ALL STATEMENTS, WHICH STARTS WITH IF (RC8000).                                
C                                                                               
c      IF (RC8000) CALL ZASSIGN(FILE7,7)                
c      IF (RC8000) CALL ZASSIGN(FILE8,8)                
c      IF (RC8000) CALL ZASSIGN(FILE9,9)                
c      IF (RC8000) CALL NONPRINT(FILE7)                 
c CA      write (*,*) 'Qual o nome do ficheiro de parametros?'
c CA      read(*,1) spcFile
c CA     open(5,file=spcFile)
      open(5,file='empcov.fi5.txt')
      open(6,file='empcov.fi6.txt')
 1    format(80A)
c      open(5,file='gil.file5',status='old')
c      open(6,file='gil.file6',status='old')
      LTEST=.FALSE.                                                             
      ILIM=15000                                                                
C ILIM IS THE MAXIMUM NUMBER OF OBSERVATIONS WHICH CAN BE READ                  
C FROM BOTH INPUT FILES AND MUST BE CONSISTENT WITH THE DIMENSIONS              
C OF ARRAYS "ITYPE,DG,COSLA,SINLA AND RLON.                                     
C                                                                               
C ********************* INPUT (0) ***********************************           
C                                                                               
C INPUT OF TEXT MAX. 60 CHARACTERS DESCRIBING DATA.                             
      READ(5,101)FMT                                                            
      WRITE(6,109)                                                              
  109 FORMAT('0 EMPIRICAL COVARIANCE FUNCTIONS.'/)                              
      WRITE(6,101)FMT                                                           
C                                                                               
C ********************* INPUT (1) ***********************************           
C                                                                               
C INPUT OF INTERVAL-LENGTH,(MINUTES), NUMBER OF INTERVALS, NUMBER OF            
C TIMES THE TABLE CAN BE 'DENSIFIED', LPLOT = PLOT COVARIANCE FUNCTION,         
C LPUNCH = PUNCH TABLE OF COVARIANCE FUNCTION AND LSMEAN = SUBTRACT             
C MEAN VALUE FROM DATA.                                                         
      READ(5,102)DIST,INTNUM,KSTOP,LPLOT,LPUNCH,LSMEAN                          
  102 FORMAT(F7.2,2I4,3L2)                                                      
C                                                                               
      IF (LPLOT.AND.LPUNCH)LPUNCH=.FALSE.                                       
      IF (LSMEAN) WRITE(6,112)                                                  
  112 FORMAT('0MEAN VALUES HAVE BEEN SUBTRACTED FROM DATA.',/)                  
      IF (INTNUM.GT.199) GO TO 9999                                             
      DIST2 = DIST/2.0                                                          
      DISTR = DIST*2.9088821E-4                                                 
      IF (.NOT.LPLOT) GO TO 1001                                                
C                                                                               
C ---------------------- INPUT (1A) ---------------------------------           
C                                                                               
C INPUT OF NAME OF PLOT-JOB FILE, MAX X-VALUE AND MIN AND MAX Y-VALUE.          
      ICHAR=1                                                                   
c      IF (RC8000) ICHAR=READSTRING(IN,DNAME,1)                                  
C     READ(5,101)DNAME(1)                                                       
      WRITE(6,108)(DNAME(IP),IP=1,ICHAR)                                        
  108 FORMAT(' PLOT-JOB FILE OUTPUT TO FILE ',2A8)                              
c      IF (RC8000) CALL OPEN(FILE9,4,DNAME,0)                                    
      OPEN(9,FILE=DNAME(1),STATUS='NEW')                                        
C                                                                               
      READ(5,123)XMAX,YMIN,YMAX                                                 
      TICK=YMAX/5                                                               
      WRITE(9,129)XMAX,YMIN,YMAX,TICK                                           
  129 FORMAT(' JOB CCT 8 3002 TIME 29 SIZE 150000 PERM SD 400 1',/,             
     *' EASYPLOT PLOTFIL.PFIL',/,' -5 1',/,' 40 40 100 60 1.0',/,               
     *' 0 ',F10.1,' 0.5 1.1',/,3F10.1,'  4.0',/,                                
     *' PSI (DEG.)',/,' COVARIANCE')                                            
      WRITE(9,101)FMT                                                           
  123 FORMAT(3F10.1)                                                            
C                                                                               
C ----------------------- INPUT (1B) --------------------------------           
C                                                                               
C INPUT OF NAME OF FILE TO HOLD COVARIANCE FUNCTION TABLE.                      
 1001 IF (.NOT.(LPUNCH.OR.LPLOT)) GO TO 1000                                    
      ICHAR=1                                                                   
c      IF (RC8000) ICHAR=READSTRING(IN,DNAME,1)
c      READ(5,101)DNAME(1)                                                       
      READ(5,101)DNAME(1)                                                       
      WRITE(6,119)(DNAME(IP),IP=1,ICHAR)                                        
  119 FORMAT(' COVARIANCE FUNCTION TABLE OUTPUT TO FILE ',2A8)                  
c      IF (RC8000) CALL OPEN(FILE7,4,DNAME,0)                                    
      OPEN(7,FILE=DNAME(1))                                  
C                                                                               
C                                                                               
C ************************ INPUT (2) *********************************          
C                                                                               
C INPUT:                                                                        
C IMAX = MAXIMAL NUMBER OF OBSERVATIONS IN CURRENT FILE,                        
C IMODE = INPUT MODE (2) GI STANDARD FORMAT FOR GRAVITY DATA (1)                
C   OUTPUT FROM GEOCOL, SCALAR DATA, (3) OUTPUT FROM GEOCOL, VECTOR             
C   DATA, (4) GI STANDARD, PAIRS OF DEFLECTIONS OF THE VERTICAL,                
C LFLAT = LATITUDE FIRST, IANG = 1 FOR ANGLES IN DEGREE, MIN.                   
C   AND SEC., = 2 FOR DEG. AND MIN., = 3 FOR DEGREES AND 4 FOR GRADS,           
C IOBS1 = TYPE OF FIRST DATA ELEMENT,                                           
C IOBS2 = TYPE OF SECOND DATA ELEMENT. IF IT IS EQUAL TO ZERO, A                
C   SCALAR DATATYPE IS INPUT,                                                   
C SCALE= BINSIZE  FOR HISTOGRAM WITH 21 BINS.                                   
C LAREA = TRUE, IF DATA FROM A LIMIT AREA MUST BE INPUT, IN WHICH               
C   CASE THE BOUNDARIES MUST BE INPUT AT (2B).                                  
C DATA RECORDS ARE INPUT FROM UNIT 8, THE NAME OF WHICH MUST BE                 
C INPUT SUBSEQUENTLY (INPUT (2A)).                                              
C A DATA RECORD IS THEN SUPPOSED TO CONSIST OF AT LEAST LATITUDE,               
C LONGITUDE AND ONE OBSERVATION. DEPENDING ON IMODE A NUMBER AND                
C A SECOND OBSERVATION MAY BE CONTAINED, AND ALSO LSTOP, TRUE                   
C FOR THE LAST DATA RECORD.                                                     
C THE INPUT FROM UNIT 8 WILL STOP, EITHER IF IMAX RECORDS HAVE                  
C BEEN INPUT, IF THE VALUE OF LSTOP IN THE DATA RECORD IS TRUE,                 
C OR IF A NEGATIVE STATION NUMBER IS INPUT.                                     
C                                                                               
 1000 READ(5,100)IMAX,IMODE,LFLAT,IANG,IOBS1,IOBS2,SCALE,LAREA                  
  100 FORMAT(2I5,L2,3I4,F5.1,L2)                                                
C                                                                               
      SCALE2=SCALE/2                                                            
      LVECT=IOBS2.GT.0                                                          
      LDOUBL=LVECT.AND.(IOBS1.EQ.12.OR.IOBS1.EQ.13)                             
C LDOUBL IS TRUE, WHEN THE DOUBLE THE AZIMUTH MUST BE USED TO                   
C COMPUTE THE COMPONENTS USED IN THE COMPUTATION. THIS IS SO WHEN               
C THE DATA ARE THE MIXED SECOND ORDER DERIVATIVE AND THE DIFFERENCE             
C OF THE HORIZONTAL SECOND ORDER DERIVATIVES OBTAINED BY TORSION                
C BALANCE.                                                                      
C                                                                               
      ICOUNT=0                                                                  
      LFOU1=.FALSE.                                                             
      LFOU2=.FALSE.                                                             
      LSTOP=.FALSE.                                                             
      IOBS22=0                                                                  
      IF (IONU.LE.0) GO TO 2111                                                 
      DO 2110 K=1,IONU                                                          
      IF (IOBS1.EQ.IOTY(K))IOBS11=K                                             
      IF (IOBS2.EQ.IOTY(K))IOBS22=K                                             
      LFOU1=LFOU1.OR.IOBS1.EQ.IOTY(K)                                           
 2110 LFOU2=LFOU2.OR.IOBS2.EQ.IOTY(K)                                           
      IF (LFOU1.AND.LFOU2) GO TO 2112                                           
 2111 IF (LFOU1)GO TO 2114                                                      
      IONU=IONU+1                                                               
      IOTY(IONU)=IOBS1                                                          
      IOBS11=IONU                                                               
      SCAL(IOBS11)=SCALE                                                        
 2114 IF (IOBS2.EQ.0.OR.LFOU2) GO TO 2112                                       
      IONU=IONU+1                                                               
      IOBS22=IONU                                                               
      SCAL(IOBS22)=SCALE                                                        
      IOTY(IONU)=IOBS2                                                          
 2112 CONTINUE                                                                  
C                                                                               
C --------------------------- INPUT (2A) --------------------------             
C INPUT OF NAME OF FILE HOLDING DATA.                                           
      ICHAR=1                                                                   
c      IF (RC8000) ICHAR=READSTRING(IN,DNAME,1) 
c      READ(5,101)DNAME(1)                                                       
      READ(5,101)DNAME(1)                                                       
c      IF (RC8000) CALL OPEN(FILE8,4,DNAME,0)                                    
      OPEN(8,FILE=DNAME(1),STATUS='OLD')    
c  101 FORMAT(10A4)                             
c  101 FORMAT(10A8)                                                              
  101 FORMAT(80A)                                                              
      II=0                                                                      
      NO=1000                                                                   
C -------------------------- INPUT (2B) -------------------------------         
C                                                                               
C INPUT OF LATITUDE AND LONGITUDE BOUNDARIES IF LAREA IS TRUE.                  
      IF(.NOT.LAREA) GOTO 1010                                                  
      READ(5,188) RLAMIN,RLAMAX,RLOMIN,RLOMAX                                   
 188  FORMAT(4F8.2)                                                             
      CALL RAD(0,0,RLAMIN,RLAMIR,3)                                             
      CALL RAD(0,0,RLAMAX,RLAMAR,3)                                             
      CALL RAD(0,0,RLOMIN,RLOMIR,3)                                             
      CALL RAD(0,0,RLOMAX,RLOMAR,3)                                             
C                                                                               
C ************************** INPUT (3) *******************************          
C                                                                               
 1010 GO TO (2001,2002,2003,2006,2007,2008,2009,2011),IMODE                     
C                                                                               
C2001 READ(8,98)NO,IDLA,RLA,IDLO,RLO,G                                          
 2001 READ(8,98)NO,RLA,RLO,G                                                    
c 2001 READ(8,*)NO,RLA,RLO, G, rdummy

C CHANGE 2013.12.03.                                                            
c     Formato da leitura dos dados
c
C   98 FORMAT(I10,2F12.5,10X,F10.2)
   98 FORMAT(I5,2F12.6,30X,F10.2)
                                             
      GO TO 2010                                                                
C                                                                               
 2002 READ(8,97)IDLA,RLA,IDLO,RLO,G,LSTOP                                       
   97 FORMAT(1X,I2,F5.2,1X,I4,F5.2,25X,F6.1,30X,L1)                             
      GO TO 2010                                                                
C                                                                               
 2003 READ(8,96)IDLA,RLA,IDLO,RLO,G,G1                                          
   96 FORMAT(I6,2(I4,F6.2),16X,2F8.2)                                           
      GO TO 2010                                                                
C                                                                               
 2006 READ(8,95)NO,IDLA,MLA,RLA,IDLO,MLO,RLO,G,G1                               
C  95 FORMAT(I7,20X,2(2I3,F6.2,4X),7X,/,26X,2F7.2,12X)                          
   95 FORMAT(I5,2(I4,I3,F6.2),16X,F8.2,8X,F8.2)                                 
      GO TO 2010                                                                
C                                                                               
 2007 READ(8,94)NO,IDLA,RLA,IDLO,RLO,G                                          
   94 FORMAT(I10,2(I4,F5.1,3X),11X,/,34X,F8.2)                                  
      GO TO 2010                                                                
C                                                                               
 2008 READ(8,93)NO,IDLA,RLA,IDLO,RLO,G,GPOT,G1                                  
   93 FORMAT(I10,2(I4,F5.1,3X),11X,/,2X,F8.2,16X,2F8.2)                         
      G=G-GPOT                                                                  
      GO TO 2010                                                                
C                                                                               
 2009 READ(8,92)NO,RLA,RLO,G                                                    
   92 FORMAT(I11,F9.4,3X,F9.4,25X,F8.2)                                         
      GO TO 2010                                                                
C                                                                               
 2011 READ(8,91)NO,RLA,RLO,G2,G1,G                                              
   91 FORMAT(I8,F11.6,F10.6,10X,F7.3,2F9.3)                                     
C PREPARED FOR DENSITY DATA FROM G.HEIN, HSWB, 1987.                            
      IF (IOBS1.EQ.16) G=(G2-2.67)*10                                           
C                                                                               
C                                                                               
 2010 IF(NO.LT.0) GO TO 2004                                                    
      II=II+1                                                                   
      IF (I.GT.ILIM) GO TO 9999                                                 
      CALL RAD(IDLA,MLA,RLA,RLAR,IANG)                                          
      CALL RAD(IDLO,MLO,RLO,RLOR,IANG)                                          
      IF (LFLAT) GO TO 1211                                                     
      RLA = RLAR                                                                
      RLAR = RLOR                                                               
      RLOR = RLA                                                                
 1211 IF((RLAR.LT.RLAMIR.OR.RLAR.GT.RLAMAR).AND.LAREA) GOTO 2004                
      IF((RLOR.LT.RLOMIR.OR.RLOR.GT.RLOMAR).AND.LAREA) GOTO 2004                
      I=I+1                                                                     
      ICOUNT=ICOUNT+1                                                           
      COSLA(I) = COS(RLAR)                                                      
      SINLAP = SIN(RLAR)                                                        
      SINLA(I) = SINLAP                                                         
      RLON(I) = RLOR                                                            
      IF ( ABS(G)    .GT.300.) WRITE(6,105)I,G                                  
  105 FORMAT(' OBSERVATION NO.',I5,' IS ',F8.1)                                 
C                                                                               
      ITYPE(I,1)=IOBS11                                                         
      ITYPE(I,2)=IOBS22                                                         
      INUM(IOBS11)=INUM(IOBS11)+1                                               
      DG(I,1) = G                                                               
      S(IOBS11)=S(IOBS11)+G                                                     
      SS(IOBS11)=SS(IOBS11)+G*G                                                 
      INDX=( ABS(G+SCALE2))/SCALE                                               
      IF (G.LT.0.0) INDX=-INDX                                                  
      INDX=INDX+12                                                              
      IF (INDX.GT.22)INDX=23                                                    
      IF (INDX.LT.2)INDX=1                                                      
      IHIST(INDX,IOBS11)=IHIST(INDX,IOBS11)+1                                   
      IF (.NOT.LVECT) GO TO 2004                                                
C                                                                               
      INUM(IOBS22)=INUM(IOBS22)+1                                               
      S(IOBS22)=S(IOBS22)+G1                                                    
      SS(IOBS22)=SS(IOBS22)+G1*G1                                               
      DG(I,2)=G1                                                                
      INDX=( ABS(G1+SCALE2))/SCALE                                              
      IF (G1.LT.0.0)INDX=-INDX                                                  
      INDX=INDX+12                                                              
      IF (INDX.GT.22)INDX=23                                                    
      IF (INDX.LT.2)INDX=1                                                      
      IHIST(INDX,IOBS22)=IHIST(INDX,IOBS22)+1                                   
C                                                                               
 2004 IF (NO.LT.0) LSTOP=.TRUE.                                                 
      IF ((.NOT.LSTOP).AND.(II.LT.IMAX)) GO TO 1010                             
C                                                                               
C **************************** INPUT (3) ***************************            
C                                                                               
C INPUT OF LOGICAL VARIABLE LSTOP, TRUE WHEN LAST GRAVITY FILE HAS BEEN         
C INPUT.                                                                        
      READ(5,106)LSTOP                                                          
  106 FORMAT(L2)                                                                
C                                                                               
      WRITE(6,110)II,(DNAME(K),K=1,ICHAR)                                       
      IF (LAREA) WRITE(6,327) ICOUNT,RLAMIN,RLAMAX,RLOMIN,RLOMAX                
  110 FORMAT(1X,I4,' VALUES INPUT FROM FILE ',2A8,/)                            
  327 FORMAT(1X,I4,' INTO THE AREA ',4F8.2/)                                    
c      IF (RC8000) CALL CLOSE(FILE8,.TRUE.)                                      
      CLOSE(8)                                                                  
      IF (.NOT.LSTOP) GO TO 1000                                                
C                                                                               
      DO 2005 IJ=1,4                                                            
      IF (INUM(IJ).LE.0) GO TO 2005                                             
C                                                                               
      IA=INUM(IJ)                                                               
      S(IJ)=S(IJ)/IA                                                            
      SS(IJ)=(SS(IJ)-S(IJ)**2*IA)/(IA-1)                                        
      WRITE(6,103)IOTY(IJ),IA,S(IJ),SS(IJ),SCAL(IJ),(IHIST(IV,IJ),              
     *IV=1,23)                                                                  
  103 FORMAT(' NUMBER OF OBS',I2,'=',I6,' MEAN = ',F7.2,' VAR. =',              
     *F9.1,//,' HISTOGRAM, USING BIN SIZE=',F8.1,//,                            
     *' ',23I4,/,                                                               
     *' OUT-10 -9 -8 -7 -6 -5 -4 -3 -2 -1  0  1  2  3  4  5  6  7  8  9',       
     *' 10OUT',/)                                                               
 2005 CONTINUE                                                                  
C                                                                               
      DO 1210 N = 1, I                                                          
      COSLAP = COSLA(N)                                                         
      SINLAP = SINLA(N)                                                         
      RLONP  = RLON(N)                                                          
      IOBS1=ITYPE(N,1)                                                          
      IOBS2=ITYPE(N,2)                                                          
      LNOCR=.FALSE.                                                             
      IF(IOBS2.GT.0)LNOCR=IOTY(IOBS1).EQ.IOTY(IOBS2)                            
      LVECT=IOBS2.GT.0                                                          
      LDOUBL=.FALSE.                                                            
      IF (LVECT) LDOUBL=IOTY(IOBS1).EQ.12.OR.IOTY(IOBS2).EQ.13                  
      IF (LSMEAN) GO TO 2025                                                    
      DGP1=DG(N,1)                                                              
      IF (LVECT) DGP2=DG(N,2)                                                   
      GO TO 2026                                                                
 2025 DGP1 = DG(N,1)-S(IOBS1)                                                   
      DG(N,1) = DGP1                                                            
      IF (.NOT.LVECT) GO TO 2026                                                
      DGP2 = DG(N,2)-S(IOBS2)                                                   
      DG(N,2)=DGP2                                                              
C                                                                               
 2026 DO 1205 M = 1, N                                                          
      DLON=RLONP-RLON(M)                                                        
      COSDLO= COS(DLON)                                                         
      SINDLO= SIN(DLON)                                                         
      SINLAQ= SINLA(M)                                                          
      COSLAQ= COSLA(M)                                                          
      T = SINLAP*SINLA(M)+COSLAP*COSLA(M)*COSDLO                                
      IF (T.GT.1.0)T=1.0                                                        
      U= SQRT(1.0-T*T)                                                          
      IF (N.EQ.M.OR. ABS(U).LT.1.0E-10.OR.LNOCR) GO TO 2501                     
      CAZP=(-SINLAP*COSLAQ+COSLAP*SINLAQ*COSDLO)/U                              
      SAZP=COSLAQ*SINDLO/U                                                      
      CAZQ=(COSLAP*SINLAQ-SINLAP*COSLAQ*COSDLO)/U                               
      SAZQ=COSLAP*SINDLO/U                                                      
      GO TO 2502                                                                
 2501 CAZP=1.0                                                                  
      CAZQ=1.0                                                                  
      SAZP=0.0                                                                  
      SAZQ=0.0                                                                  
 2502 IF (.NOT.LDOUBL) GO TO 2505                                               
C DOUBLE ANGLE.                                                                 
      CZZ=CAZP                                                                  
      CAZP=CAZP**2-SAZP**2                                                      
      SAZP=2*CZZ*SAZP                                                           
 2505 IF (IOTY(ITYPE(M,1)).NE.13.AND.IOTY(ITYPE(M,1)).NE.12) GO TO 2506         
      CZZ=CAZQ                                                                  
      CAZQ=CAZQ**2-SAZQ**2                                                      
      SAZQ=2*CZZ*SAZQ                                                           
 2506 CONTINUE                                                                  
      IF (T.LT.0.0) T = -T                                                      
      IND = ASIN(SQRT(ABS(1.0-T*T)))/DISTR+1.5                                
      IF (IND.GT.199) GO TO 1205                                                
C                                                                               
      DO 2500 MM=1,IONU                                                         
      LFOU1=MM.EQ.ITYPE(N,1)                                                    
      LFOU2=MM.EQ.ITYPE(N,2)                                                    
      IF (.NOT.(LFOU1.OR.LFOU2)) GO TO 2500                                     
      DGPP=DGP1                                                                 
      IF (LVECT.AND.LFOU1) DGPP=CAZP*DGPP+SAZP*DGP2                             
      IF (LVECT.AND.LFOU2) DGPP=SAZP*DGPP-CAZP*DGP2                             
      DO 2600 MA=1,MM                                                           
      NM=((MM-1)*MM)/2+MA                                                       
      LFOU3=ITYPE(M,1).EQ.MA                                                    
      LFOU4=ITYPE(M,2).EQ.MA                                                    
      IF (.NOT.(LFOU3.OR.LFOU4).OR.(LNOCR.AND.MM.NE.MA))                        
     *GO TO 2600                                                                
C                                                                               
      LVECTQ=ITYPE(M,2).NE.0                                                    
      DGPQ=DG(M,1)                                                              
      IF (LVECTQ.AND.LFOU3) DGPQ=CAZQ*DGPQ+SAZQ*DG(M,2)                         
      IF (LVECTQ.AND.LFOU4) DGPQ=SAZQ*DGPQ-CAZQ*DG(M,2)                         
      CO=DGPP*DGPQ                                                              
      COV(IND,NM)=COV(IND,NM)+CO                                                
      SSCOV(IND,NM)=SSCOV(IND,NM)+CO*CO                                         
      NUM(IND,NM)=NUM(IND,NM)+1                                                 
 2600 CONTINUE                                                                  
 2500 CONTINUE                                                                  
 1205 CONTINUE                                                                  
 1210 CONTINUE                                                                  
C                                                                               
C OUTPUT OF TABLE AND PLOT.                                                     
C                                                                               
      K=0                                                                       
      NPLOT=0                                                                   
 1300 M0=0                                                                      
      DO 1400 M1=1,IONU                                                         
      DO 1400 M2=1,M1                                                           
      M0=M0+1                                                                   
      IF (LNOCR.AND.M1.NE.M2) GO TO 1400                                        
      IF (K.EQ.0) NPLOT=NPLOT+1                                                 
      IDEG = 0                                                                  
      RMIN = 0.0                                                                
      WRITE(6,124)IOTY(M1),IOTY(M2)                                             
  124 FORMAT('0   PSI   COVA(',I2,',',I2,') PROD. STDV OF COV..',/,             
     *'    O  M    (UNIT)**2   NUMB   (UNIT)**2',//)                            
C                                                                               
      DO 1310 J = 1, INTNUM                                                     
      IF (RMIN.LT.60.0) GO TO 1302                                              
      J1 = RMIN/60.0                                                            
      IDEG = IDEG+J1                                                            
      RMIN = RMIN-J1*60.0                                                       
 1302 N = NUM(J,M0)                                                             
      X = 60.0*IDEG+RMIN                                                        
      IF (N.LE.1) GO TO 1301                                                    
C                                                                               
      CO = COV(J,M0)/N                                                          
      SSC = (SSCOV(J,M0)-CO*CO*N)/(N-1)                                         
      IF (SSC.GT.0.0) SSC=SQRT(SSC/N)                                           
  127 FORMAT(F8.3,F10.4,I10)                                                    
      DPSI=IDEG+RMIN/60.0                                                       
      IF (DPSI.LT.0.0E0) DPSI=0.0E0                                             
      WRITE(6,126)IDEG,RMIN,CO,N,SSC                                            
  126 FORMAT(I5,F6.2,F10.2,I10,F10.1)                                           
      IF (LPUNCH) WRITE(7,127)DPSI,CO,N                                         
      IF (LPLOT) WRITE(7,125)DPSI,CO,SSC                                        
  125 FORMAT(' ',F9.4,2F11.3)                                                   
      IF (LPLOT.AND.K.EQ.0) NVAL(NPLOT)=NVAL(NPLOT)+1                           
      IF (K.GE.1.AND.J.EQ.1) RMIN = -DIST/2.0+DIST2                             
 1301 JM=J                                                                      
      JM=MOD(JM,2)                                                              
C LABEL 1301 MOVED UP ONE STATEMENT. CORRECTION JULY 9, 1987, BY CCT.           
      IF (LTEST) WRITE(6,177)J,JM                                               
  177 FORMAT(' J,JM=',2I4)                                                      
      IF (JM.EQ.1.OR.J.EQ.INTNUM) GO TO 1310                                    
      I1 = J/2+1                                                                
      NUM(I1,M0)=NUM(J,M0)+NUM(J+1,M0)                                          
      COV(I1,M0)=COV(J,M0)+COV(J+1,M0)                                          
      SSCOV(I1,M0)=SSCOV(J,M0)+SSCOV(J+1,M0)                                    
 1310 RMIN = RMIN+DIST                                                          
 1400 CONTINUE                                                                  
C                                                                               
      K = K+1                                                                   
      IF (K.GE.KSTOP) GO TO 9999                                                
C                                                                               
      INTNUM = INTNUM/2                                                         
      DIST = 2*DIST                                                             
      GO TO 1300                                                                
C                                                                               
 9999 IF(.NOT.(LPUNCH.OR.LPLOT)) GO TO 9998                                     
      IEM=25                                                                    
      INL=10                                                                    
      WRITE(7,990)INL,IEM                                                       
  990 FORMAT(2A3)                                                               
c     IF (RC8000) CALL CLOSE(FILE7,.TRUE.)                                      
      CLOSE(7)                                                                  
C                                                                               
 9998 IF (.NOT.LPLOT) GO TO 9997                                                
      NPLOT1=NPLOT+1                                                            
      WRITE(9,171)NPLOT1                                                        
      DO 1005 I=1,NPLOT                                                         
      II=I+99                                                                   
 1005 WRITE(9,172)NVAL(I),II                                                    
  171 FORMAT(I3)                                                                
  172 FORMAT(2I4,'  2')                                                         
      WRITE(9,173)XMAX                                                          
  173 FORMAT(' -2 4 0 0',F8.1,' 0  -1  -1',/,' PLOTXFER PFIL SORT',/,           
     *' FINIS')                                                                 
      WRITE(9,990)INL,IEM                                                       
c      IF (RC8000) CALL CLOSE(FILE9,.TRUE.)                                      
      CLOSE(9)                                                                  
C                                                                               
 9997 STOP                                                                      
      END                                                                       
      SUBROUTINE RAD(IDEG,MIN,SEC,RA,IANG)                                      
C THE SUBROUTINE CONVERTS FOR IANG = 1,2,3,4 ANGLES IN (1) DEGREES, MI-         
C NUTES, SECONDS, (2) DEGREES, MINUTES, (3) DEGREES AND (4) 400-DEGREES         
C TO RADIANS.                                                                   
C IF DOUBLE PRECISION IS NEEDED, ACTIVATE:                                      
      IMPLICIT INTEGER(I,J,K,M,N),REAL *8(A-H,O-Z)                              
      PHI = 3.1415926536E0                                                      
      I = 1                                                                     
      IF (IDEG .LT. 0 .AND. IANG .LT. 3) I = -1                                 
      GO TO (1,2,3,4),IANG                                                      
    1 J = 1                                                                     
      IF (MIN.LT.0) J = -1                                                      
      SE =I*IDEG*3600+J*MIN*60+SEC                                              
      I = J*I                                                                   
      GO TO 5                                                                   
    2 SE=I*IDEG*3600+SEC*60                                                     
      GO TO 5                                                                   
    3 SE = SEC*3600                                                             
      GO TO 5                                                                   
    4 SE = SEC*3240                                                             
    5 RA= I*SE/206264.806E0                                                     
      IF (RA.GT.PHI) RA = RA-PHI*2.0E0                                          
      IF (RA.LT.-PHI) RA = RA+PHI*2.0E0                                         
      RETURN                                                                    
      END                                                                       
