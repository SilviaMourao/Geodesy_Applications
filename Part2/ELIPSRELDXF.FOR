C    *************  PROGRAMA ELIPSES  ******************

      PROGRAM ELIPSES

C   O PROGRAMA CALCULA OS ELEMENTOS DAS ELIPSES RELATIVAS DA REDE
C   E DESENHA AS ELIPSES NUM FILE.DXF


      IMPLICIT INTEGER*4 (I-N)
      IMPLICIT REAL*8 (A-H,O-Z)
	DIMENSION NP(100),AM(100),AP(100),VA(200,200)
      CHARACTER*15 NOME1,NOME2,NOME3
	DATA AM,AP,VA/100*0.D0,100*0.D0,40000*0.D0/
      pi = 4.d0*datan(1.d0)

	WRITE(*,'(A,3/)')
     1 ' DETERMINA AS ELIPSES DE ERRO DE UMA REDE GEODESICA'
      OPEN(0,FILE='DINAM.IN')
      
C	WRITE(*,*)'FICHEIRO DAS COORDENADAS DOS PONTOS DA REDE ?'
C      READ(*,'(A14)')NOME1
      READ(0,'(/,A15)') NOME1

C	WRITE(*,*)'FICHEIRO DAS MATRIZES DE COVARIANCIA ?'
C      READ(*,'(A14)')NOME2
      NOME2='VARCOV.OUT'

C	WRITE(*,*)'FICHEIRO DAS OBSERVACOES ?'
C      READ(*,'(A14)')NOME3
      READ(0,'(A15,4/)') NOME3

C      WRITE(*,*)'ESCALA DA ELIPSE ?'
C      READ(*,*) ESC
      READ(0,*) ESC,EGR
	READ(0,*) FK
	ESC1=ESC*FK
	CLOSE(0)

      OPEN(1,FILE=NOME1,STATUS='OLD')
      OPEN(2,FILE=NOME2,STATUS='OLD')
      OPEN(3,FILE=NOME3,STATUS='OLD')
      OPEN(5,FILE='ELIPSREL.OUT')

C    HEADER OF FILE.DXF
      open(4,file='elipsRL.dxf')
      write (4, '(i3)') 0
      write (4, '(a7)') 'SECTION'
      write (4, '(i3)') 2
      write (4, '(a8)') 'ENTITIES'


      READ(1,'(2/)')
	READ(1,*) NL,NF,ND,NC,NA

      XMIN=1.D32
	YMIN=1.D32
      DO I=1,NL+NF
        READ(1,*) NP(I), AM(I), AP(I)
	  IF (XMIN.GT.AM(I)) XMIN=AM(I)
	  IF (YMIN.GT.AP(I)) YMIN=AP(I)
	ENDDO

	DO I=1,2*NL
        DO J=1,i
	   READ(2,*) VA(I,J)
         VA(J,I)=VA(I,J)
	  ENDDO
	ENDDO

      WRITE(5,'(a,/)') 'ELIPSES DE ERRO RELATIVAS'
      WRITE(5,10) 
10	FORMAT('#ESTAC.1   #ESTAC.2    E1(m)     E2(m)    RUMO E1(gr)')

      DO I=1,ND
        READ(3,*) NPE,NPV
	  J=1
	  DO WHILE (NPE.NE.NP(J)) 
	   J=J+1
	  ENDDO
	  K=1
	  DO WHILE (NPV.NE.NP(K)) 
	   K=K+1
	  ENDDO

	  CM=(AM(J)+AM(K))/2.D0
	  CP=(AP(J)+AP(K))/2.D0
	  J=2*J-1
	  K=2*K-1

	  VDM=VA(J,J)+VA(K,K)-2*VA(J,K)
	  VDP=VA(J+1,J+1)+VA(K+1,K+1)-2*VA(J+1,K+1)
	  VDMP=VA(J,J+1)-VA(J,K+1)-VA(J+1,K)+VA(K,K+1)

	  IF ((VDM-VDP).NE.0.D0) THEN
c	    TETA=DATAND(2*VDMP/(VDM-VDP))/2.D0
	    TETA=90.D0-DATAN2D(2.d0*VDMP,(VDM-VDP))/2.D0
	    IF (TETA.LT.0.D0) TETA=TETA+360.D0
	  ELSE
	    TETA=0.D0
	  ENDIF

	  A=DSQRT((VDM+VDP+SQRT((VDM-VDP)**2+(2*VDMP)**2))/2)
	  B=DSQRT((VDP+VDM-SQRT((VDP-VDM)**2+(2*VDMP)**2))/2)

	  WRITE(5,200)NPE,NPV,A,B,TETA
200     FORMAT(2I8,2X,2F10.3,F10.2)

C    DESENHO DAS ELIPSES EM DXF

	  C1=DCOSD(TETA+90.d0)
	  S1=DSIND(TETA+90.d0)	  
	  C2=DCOSD(TETA)
	  S2=DSIND(TETA)
        
        X1=ESC1*(A*C1*DCOSD(0.D0)+B*S1*DSIND(0.D0))+CM
        Y1=ESC1*(A*C2*DCOSD(0.D0)+B*S2*DSIND(0.D0))+CP
	  DO J=0,360,5
	    ALF=REAL(J)
	    X2=ESC1*(A*C1*DCOSD(ALF)+B*S1*DSIND(ALF))+CM
	    Y2=ESC1*(A*C2*DCOSD(ALF)+B*S2*DSIND(ALF))+CP
	    CALL LINE(X1,Y1,X2,Y2)
	    X1=X2
	    Y1=Y2
	  ENDDO
      ENDDO

	XMAX=XMIN+ESC/FK*EGR
      CALL LINE(XMIN,YMIN,XMAX,YMIN)
	D=(XMAX-XMIN)/10
      CALL LINE(XMIN,YMIN+D,XMIN,YMIN-D)
      CALL LINE(XMAX,YMIN+D,XMAX,YMIN-D)
      CALL TEXTO(XMIN,YMIN+2*D,INT(EGR*100))

C    END OF FILE.DXF
      write (4, '(i3)') 0
      write (4, '(a6)') 'ENDSEC'
      write (4, '(i3)') 0
      write (4, '(a3)') 'EOF'

      CLOSE(1)
      CLOSE(2)
      CLOSE(3)
	CLOSE(4)

      END


	SUBROUTINE LINE(X1,Y1,X2,Y2)
	implicit real*8 (a-h,o-z)
      zero=0.0
      write (4, fmt = '(a3)') '  0'
      write (4, fmt = '(a4)') 'LINE'
      write (4, fmt = '(a3)') '  8'
      write (4, fmt = '(a5)') 'LAYER'
      write (4, fmt = '(a3)') ' 10'
      write (4, 20) X1
      write (4, fmt = '(a3)') ' 20'
      write (4, 20) Y1
      write (4, fmt = '(a3)') ' 30'
      write (4, 20) zero
      write (4, fmt = '(a3)') ' 11'
      write (4, 20) X2
      write (4, fmt = '(a3)') ' 21'
      write (4, 20) Y2
      write (4, fmt = '(a3)') ' 31'
      write (4, 20) zero
20    FORMAT(F12.2)
	RETURN
	END


	SUBROUTINE TEXTO(X1,Y1,IES)
	implicit real*8 (a-h,o-z)
      zero=0.0
      write (4, fmt = '(a3)') '  0'
      write (4, fmt = '(a4)') 'TEXT'
      write (4, fmt = '(a3)') '  8'
      write (4, fmt = '(a5)') 'LAYER'
      write (4, fmt = '(a3)') '  1'
      write (4, fmt = '(I2,a3)') IES,' cm'
      write (4, fmt = '(a3)') ' 40'
      write (4, fmt = '(I3)') 600
      write (4, fmt = '(a3)') ' 10'
      write (4, 21) X1
      write (4, fmt = '(a3)') ' 20'
      write (4, 21) Y1
      write (4, fmt = '(a3)') ' 30'
      write (4, 21) zero
21    FORMAT(F12.2)


	RETURN
	END
