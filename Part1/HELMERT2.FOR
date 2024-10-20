C     PROGRAMA HELMERT1.FOR                                              
C  CALCULA ESTIMATIVAS DOS PARAMETROS (3 COMPONENTES DUMA               
C  TRANSLACAO OBRIGATORIA + 3 ROTACOES E UM FACTOR DE ESCALA            
C  OPCIONAIS) DE UMA TRANSFORMACAO ENTRE 2 SISTEMAS GEODE-              
C  SICOS ('DATA'), COM O MÁXIMO DE 150 PONTOS                                                      
      IMPLICIT REAL*8(A-H,O-Z)                                        
      DIMENSION PA(7)                 
      CHARACTER*20 ELIP1,ELIP2,entra,sai
	CHARACTER*30 NOME
      CHARACTER*5 TIPO   
C  NUMERO DE CASAS DECIMAIS EXACTAS DESEJADAS NOS SEGUNDOS              
      ND=5                                                            

      PI=4.D0*DATAN(1.D0)
      Write(*,*) 'Ficheiro de Parametros Helmert:'
	read(*,*) entra

	OPEN (0,FILE=entra,STATUS='OLD')                                            
      DO I=1,7
	   READ(0,*) PA(I)
	ENDDO
	CLOSE(0)                                             
      FR=0.1D7                                                        
      CRS=180.*3600./PI
      Write(*,*) 'Ficheiro de Coordenadas Iniciais:'
	read(*,*) entra
	Write(*,*) 'Ficheiro de Coordenadas Transformadas:'
	read(*,*) sai

C	Abertura de ficheiros de entrada e saida
	Open(unit=1,file=entra,status='old')
	Open(unit=2,file=sai,status='unknown')

	WRITE(2,*) '    Nome                     Latitude (º ´ ´´)  ',
	1   'Longitude (º ´ ´´) h topo (m)'
C  LE tipo das coordenadas de entrada (CART. OU GEOD.)
      READ(1,*) TIPO                                                       
C  LE 'DATA' E PARAMETROS DOS ELIPSOIDES                                
      READ(1,*)ELIP1,A1,E1                                            
      READ(1,*)ELIP2,A2,E2                                            

      READ(1,*)N1                                                    
C  LE COORDS. CART. OU GEOD. (E TRANSF. EM CART.) DOS PONTOS COMUNS NOS 2 DATA    
      DO 20 I=1,N1                                                    
         READ(1,'(A20)')NOME
         IF (TIPO.EQ.'CART') THEN
          READ(1,*) X1, Y1, Z1
          READ(1,*) 
         ELSE                               
           READ(1,*)IG1,M1,S1,IG2,M2,S2,HE                               
           CALL DEGTOR(IG1,M1,S1,FI)                                      
           CALL DEGTOR(IG2,M2,S2,AL)                                   
           CALL GEOR(A1,E1,FI,AL,HE,X1,Y1,Z1)            
	     READ(1,*)
	   END IF
	   X2=PA(1)+(1.D0+PA(4)/FR)*(X1+(PA(7)*Y1-PA(6)*Z1)/CRS)     
         Y2=PA(2)+(1.D0+PA(4)/FR)*(Y1+(-PA(7)*X1+PA(5)*Z1)/CRS)    
         Z2=PA(3)+(1.D0+PA(4)/FR)*(Z1+(PA(6)*X1-PA(5)*Y1)/CRS) 
         CALL BOWRING (PI,A2,E2,X2,Y2,Z2,FI,AL,HE) 
         CALL RADTOD(FI,IG1,M1,S1,ND)                                      
         CALL RADTOD(AL,IG2,M2,S2,ND)   
	   WRITE(2,10)NOME,IG1,ABS(M1),ABS(S1),IG2,ABS(M2),ABS(S2),HE
20    CONTINUE
                                                        
10    FORMAT(A29,2(2I5,F9.4),F10.2)
      CLOSE(1)
	CLOSE(2)

1000  STOP                                                            
      END                                                             

      SUBROUTINE GEOR(A,E2,FI,AL,HE,X,Y,Z)
C  PROGRAMA PARA CONVERSAO DE COORDENADAS GEODESICAS EM CARTESIANAS
C  (TRIEDRO DIRECTO CENTRADO COM O ELIPSOIDE
C  E COM O EIXO DOS XX NO MERIDIANO DE GREENWICH)
C  PERMITINDO A TRANSF. DE QUALQUER NO. DE  PONTOS
	IMPLICIT REAL*8 (A-H,O-Z)
	S = DSIN(FI)
	W = DSQRT (1.D0 - E2 * S * S)
	RN = A / W
	V = (RN + HE) * DCOS(FI)
	X = V * DCOS(AL)
	Y = V * DSIN(AL)
	Z = ((1.D0 - E2) * RN + HE) * S
	RETURN
	END

	SUBROUTINE DEGTOR(M,N,S,ANG)
	IMPLICIT REAL*8(A-H,O-Z)
	PI=4.D0*DATAN(1.D0)
	ANG=(IABS(M)+(N/60.D0)+(S/3600.D0))*(PI/180.D0)
	IF(M.GE.0)GOTO 5
	ANG=-ANG
    5 CONTINUE
	RETURN
	END

C   SUBROTINA PARA CONVERTER RADIANOS EM GRAUS, MINUTOS E SEGUNDOS
C
C   ANG = ANGULO EM RADIANOS; ID = GRAUS; M = MINUTOS; S = SEGUNDOS;
C   ND = NUMERO DE DECIMAIS EXACTOS DESEJADO NOS SEGUNDOS.
C
C   SUBROTINA NECESSARIA DO SISTEMA : DATAN
C
C   INPUT :	   ANG , ND
C   OUTPUT :	   ID , M, S

      SUBROUTINE RADTOD(ANG,ID,M,S,ND)
      IMPLICIT REAL*8(A-H,O-Z)
      PI=4.D0*DATAN(1.D0)
      G=180.D0/PI
      ALPHA=ANG*G
      ID=ALPHA
      RM=(ALPHA-ID)*60.D0
      M=RM
      S=(RM-M)*60.D0+5.D0*10.D0**(-ND-1)
      IF(S.LT.60.D0)GOTO 5
      M=M+1
      S=0
      IF(M.LT.60)GOTO 5
      ID=ID+1
      M=0
    5 CONTINUE
      RETURN
      END
C  Subrotina para calculo de coordendas cartesianas a partir de geodesicas
C  elipsoidais
      SUBROUTINE BOWRING (PI,A,E2,X,Y,Z,FI,AL,HE)
      IMPLICIT REAL*8(A-H,O-Z)            
        AL=DATAN(Y/X)                                                    
        IF(X.GT.0)GOTO 13                                               
        IF(Y)12,11,11                                                  
11      AL=AL+PI                                                        
        GOTO 13                                                         
12      AL1=AL1-PI                                                      
13      PE=DSQRT(X*X+Y*Y)                                               
        ER=DSQRT(1.D0-E2)                                               
        U=DATAN(Z/(PE*ER))                                             
        S=DSIN(U)                                                       
        S2=S*S                                                          
        S=S*S2                                                          
        CO=DCOS(U)                                                     
        CO2=CO*CO                                                      
        CO=CO*CO2                                                     
        AM=E2*A                                                         
        FI=DATAN((Z+AM*S/ER)/(PE-AM*CO))                                
        HE=PE/DCOS(FI)-A/DSQRT(1.D0-E2*DSIN(FI)**2)                          
        RETURN
        END