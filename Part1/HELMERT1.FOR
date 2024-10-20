C     PROGRAMA HELMERT1.FOR                                              
C  CALCULA ESTIMATIVAS DOS PARAMETROS (3 COMPONENTES DUMA               
C  TRANSLACAO OBRIGATORIA + 3 ROTACOES E UM FACTOR DE ESCALA            
C  OPCIONAIS) DE UMA TRANSFORMACAO ENTRE 2 SISTEMAS GEODE-              
C  SICOS ('DATA'), COM O MÁXIMO DE 150 PONTOS                                                      
        IMPLICIT REAL*8(A-H,O-Z)                                        
        DIMENSION A(450,8),L1(7)                                         
        DIMENSION X1(150),Y1(150),Z1(150),X2(150),Y2(150),Z2(150)             
        DIMENSION HE(150),B(450,8),C(8,7),D(7,8),V(450),W(7),T(7)          
        DIMENSION S1(16),C1(7,7),E(7,8),FI(150),AL(150)                   
        CHARACTER*20 ELIP1,ELIP2,PA(7),entra,sai
	  CHARACTER*28 P(150)
        CHARACTER*5 TIPO                                         
C  NUMERO DE CASAS DECIMAIS EXACTAS DESEJADAS NOS SEGUNDOS              
        ND=5                                                            
        PI=4.D0*DATAN(1.D0)                                             
        PA(1)='DX(m)'                                                  
        PA(2)='DY(m)'                                                   
        PA(3)='DZ(m)'                                                   
        PA(4)='ALFA(ppm)'                                               
        PA(5)='EX(seg)'                                             
        PA(6)='EY(seg)'                                              
        PA(7)='EZ(seg)'                                              
        FR=0.1D7                                                        
        CRS=180.*3600./PI
      Write(*,*) 'Nome do ficheiro de entrada:'
	read(*,*) entra
	Write(*,*) 'Nome do ficheiro de saida:'
	read(*,*) sai

C	Abertura de ficheiros de entrada e saida
	Open(unit=1,file=entra,status='old')
	Open(unit=2,file=sai,status='unknown')
C  LE tipo das coordenadas de entrada (CART. OU GEOD.)
        READ(1,*) TIPO                                                       
C  LE 'DATA' E PARAMETROS DOS ELIPSOIDES                                
        READ(1,*)ELIP1,A1,E1                                            
        READ(1,*)ELIP2,A2,E2                                            
        NP=0                                                                                                 
        WRITE(2,720)ELIP1,ELIP2                                         
        WRITE(2,730)                                                    
        WRITE(2,740)A1,E1,A2,E2                                        
C  ANULA TODOS OS COEFICIENTES DAS INCOGNITAS                           
        READ(1,*)N1                                                    
        N3=3*N1                                                         
        DO 15 I=1,N3                                                    
        DO 10 J=1,7                                                    
        A(I,J)=0.0                                                     
10      CONTINUE                                                        
15      CONTINUE                                                        
        L1(1)=1                                                         
        L1(2)=2                                                         
        L1(3)=3                                                         
C  LE COORDS. CART. OU GEOD. (E TRANSF. EM CART.) DOS PONTOS COMUNS NOS 2 DATA    
35      WRITE(2,*)
        DO 20 I=1,N1                                                    
         READ(1,'(A20)')P(I)
         IF (TIPO.NE.'CART') goto 37
         READ(1,*) X1(I), Y1(I), Z1(I)
         READ(1,*) X2(I), Y2(I), Z2(I)
         CALL BOWRING (PI,A2,E2,X2(I),Y2(I),Z2(I),FI(I),AL(I),HE(I))                                    
         GOTO 20                               
 37      DO 8 K=1,2                                                     
          READ(1,*)NG,MI,S,NG1,MI1,S2,HE(I)                               
          CALL DEGTOR(NG,MI,S,FI(I))                                      
          CALL DEGTOR(NG1,MI1,S2,AL(I))                                   
          IF(K.EQ.2)GOTO 24                                               
          CALL GEOR(A1,E1,FI(I),AL(I),HE(I),X1(I),Y1(I),Z1(I))            
          GOTO 8                                                          
24        CALL GEOR(A2,E2,FI(I),AL(I),HE(I),X2(I),Y2(I),Z2(I))           
8        CONTINUE                                                        
20      CONTINUE                                                        
C  CALCULA TRANSLACAO MEDIA(1-->2) E SOMA-A 'AS COORDS. DATUM1           
        DX=0.D0                                                         
        DY=0.D0                                                         
        DZ=0.D0                                                         
        DO 32 I=1,N1                                                    
        DX=DX+X2(I)-X1(I)                                               
        DY=DY+Y2(I)-Y1(I)                                              
        DZ=DZ+Z2(I)-Z1(I)                                               
32      CONTINUE   
C  COMPONENTES NO DATUM2 DO CENTRO DO ELIP. DATUM1                      
        DX=DX/N1                                                       
        DY=DY/N1                                                       
        DZ=DZ/N1                                                        
        DO 34 I=1,N1                                                   
        X1(I)=X1(I)+DX                                                  
        Y1(I)=Y1(I)+DY                                                
        Z1(I)=Z1(I)+DZ                                                  
34      CONTINUE                                                       
C  FORMA O SISTEMA DE EQUACOES DA TRANSFORMACAO                        
26      L=0                                                             
        DO 28 I=1,N1                                                    
        L=L+1                                                         
        A(L,1)=1.D0                                                     
        A(L,4)=X1(I)/FR                                                
        A(L,6)=-Z1(I)/CRS                                               
        A(L,7)=Y1(I)/CRS                                                
        A(L,8)=X2(I)-X1(I)                                             
        L=L+1                                                           
        A(L,2)=1.D0                                                     
        A(L,4)=Y1(I)/FR                                                 
        A(L,5)=Z1(I)/CRS                                               
        A(L,7)=-X1(I)/CRS                                               
        A(L,8)=Y2(I)-Y1(I)                                             
        L=L+1                                                          
        A(L,3)=1.D0                                                    
        A(L,4)=Z1(I)/FR                                               
        A(L,5)=-Y1(I)/CRS                                            
        A(L,6)=X1(I)/CRS                                                
        A(L,8)=Z2(I)-Z1(I)                                              
28      CONTINUE                                                        
c        READ(1,*)NALT 
C Nº de Alternativas - Calcula só uma alternativa
        NALT=1                                                 
45      DO 520 JC=1,NALT                                                
        DO 470 I=1,7                                                    
        DO 460 J=I,7                                                    
        D(I,J)=0.D0                                                    
460     CONTINUE                                                        
470     CONTINUE                                                        
C  COPIA PARA B AS 3 PRIMEIRAS COLUNAS DE A                             
        DO 490 L=1,N3                                                   
        DO 480 K=1,3                                                    
        B(L,K)=A(L,K)                                                   
480     CONTINUE                                                        
490     CONTINUE                                                        
C        READ(1,*)NPALT 
C Nº de parâmetros para além das 3 translações 
        NPALT=4                                                 
495     IF(NPALT.NE.0)GOTO 25                                           
        M=3                                                            
        GOTO 512                                                        
25      DO 510 J=1,NPALT                                                
        M=J+3                                                           
c        READ(1,*)L1(M)
c   Posição dos parâmetros  
        L1(M)=M                                             
C  COPIA PARA B AS RESTANTES COLUNAS A CONSIDERAR EM A                 
498     DO 500 L=1,N3                                                  
        B(L,M)=A(L,L1(M))                                               
500     CONTINUE                                                       
510     CONTINUE                                                        
512     K2=M+1                                                         
C  FORMA O SISTEMA DE EQUACOES NORMAIS                                  
        DO 60 I=1,N3                                                    
          DO 50 J=1,M                                                     
            DO 40 K=J,M                                                    
                D(J,K)=D(J,K)+B(I,J)*B(I,K)                                     
40          CONTINUE                                                        
50        CONTINUE                                                        
60      CONTINUE                                                       
C  ALGORITMO DE CHOLESKY PARA INVERSAO DAS EQS. NORMAIS                 
        K1=M-1                                                          
        DO 125 I1=M,1,-1                                                
          DO 63 L=1,M                                                     
            DO 62 K=L,M                                                     
               E(L,K)=D(L,K)                                                   
62          CONTINUE                                                        
63        CONTINUE                                                        
C  ANULA TODOS OS TERMOS INDEPENDENTES DAS EQS. NORMAIS                
          DO 65 K=1,M                                                    
            E(K,K2)=0.D0                                                    
65        CONTINUE                                                        
         E(I1,K2)=1.D0                                                   
          DO 90 I=1,K1                                                    
            E(I,I)=DSQRT(E(I,I))                                           
           DO 70 K=I+1,K2                                                 
              E(I,K)=E(I,K)/E(I,I)                                            
70         CONTINUE                                                        
           DO 80 J=I+1,M                                                   
            DO 75 K=J,K2                                                    
              E(J,K)=E(J,K)-E(I,J)*E(I,K)                                     
75          CONTINUE                                                        
80         CONTINUE                                                        
90        CONTINUE                                                        
C  DETERMINA INVERSA DE AT.A (COLUNA A COLUNA)                          
100     C1(M,I1)=E(M,K2)/E(M,M)                                         
          DO 120 I=K1,1,-1                                                
            S=E(I,K2)                                                       
            J=I+1                                                           
           DO 110 K=M,J,-1                                                 
             S=S-E(I,K)*C1(K,I1)                                             
110        CONTINUE                                                        
            C1(I,I1)=S/E(I,I)                                               
120       CONTINUE                                                        
125     CONTINUE                                                        
C  CALCULA ESTIMATIVA DOS PARAMETROS DA TRANSFORMACAO                   
128        DO 140 L=1,M                                                    
          S=0.D0                                                          
          DO 130 K=1,N3                                                   
             S=S+B(K,L)*A(K,8)                                               
130       CONTINUE                                                        
          W(L)=S                                                          
140     CONTINUE                                                        
        DO 155 L=1,M                                                    
        S=0.D0                                                          
        DO 150 K=1,M                                                    
        S=S+C1(L,K)*W(K)                                                
150     CONTINUE                                                        
        T(L)=S                                                          
155     CONTINUE                                                        
C  REORDENACAO DOS PARAMETROS                                           
        DO 160 K=4,7                                                    
        C(JC,K)=0.D0                                                    
160     CONTINUE                                                        
        DO 156 K=1,M                                                   
        C(JC,L1(K))=T(K)                                                
156     CONTINUE                                                        
C  CALCULA COMPONENTES DA TRANSLACAO TOTAL 1-->2                        
        T(1)=T(1)+DX                                                    
        T(2)=T(2)+DY                                                    
        T(3)=T(3)+DZ                                                    
C  DETERMINA RESIDUOS E VARIANCIA DA UNIDADE DE PESO                    
165     S=0.D0                                                          
        N2=1                                                            
        WRITE(2,920)                                                    
        WRITE(2,925)                                                    
        DO 185 K=1,N1                                                   
        WRITE(2,700)P(K)                                                
        N3=3*K                                                          
        DO 180 I=N2,N3                                                  
        V(I)=-A(I,8)                                                    
        DO 170 J=1,M                                                    
        V(I)=V(I)+B(I,J)*C(JC,L1(J))                                    
170     CONTINUE                                                        
        WRITE(2,930)V(I)                                               
        S=S+V(I)*V(I)                                                   
180     CONTINUE                                                        
        N2=N3+1                                                         
185     CONTINUE                                                       
        NGL=N3-M                                                        
        WRITE(2,680)S                                                   
        S=S/NGL                                                        
C  CALCULA E.M.Q. DA UNIDADE DE PESO                                    
        S1(JC)=DSQRT(S)                                                 
        WRITE(2,940)NGL                                                 
        WRITE(2,950)S1(JC)                                              
C  CALCULA MATRIZ DAS VARIANCIAS-COVARIANCIAS                           
C        WRITE(2,985)                                                   
        DO 200 I=1,M                                                   
        DO 190 J=1,I                                                   
        B(I,J)=S*C1(I,J)                                                
190     CONTINUE                                                       
C        WRITE(2,990)(B(I,J),J=1,I)                                      
200     CONTINUE                                                        
C  CALCULA MATRIZ DE CORRELACAO                                         
C        WRITE(2,980)                                                   
        DO 220 I=1,M                                                    
        DO 210 J=1,I                                                   
        D(I,J)=B(I,J)/DSQRT(B(I,I)*B(J,J))                              
210     CONTINUE                                                       
C        WRITE(2,990)(D(I,J),J=1,I)                                      
220     CONTINUE                                                        
C  CALCULA E.M.Q. DOS PARAMETROS DA TRANSFORMACAO                       
        WRITE (2,970)                                                   
        DO 230 I=1,M                                                    
        V(I)=DSQRT(B(I,I))                                              
        WRITE(2,820)PA(L1(I)),T(I),V(I)                                      
230     CONTINUE                                                        
C  ESCREVE LINHAS DA MATRIZ INVERSA DAS EQS. NORMAIS                    
C        WRITE(2,960)                                                    
C        DO 515 I=1,M                                                    
C        WRITE(2,910)(C1(I,J),J=1,I)                                     
C515     CONTINUE                                                       
235     L=JC                                                            
  1     I=N1+1                                                          
520     CONTINUE                                                        
680     FORMAT(/6X,'SOMA DOS QUADRADOS DOS RESIDUOS =',F12.3/)          
700     FORMAT(6X,A20)                                                  
720     FORMAT(2X,'DATUM 1  (',A10,')    --->  DATUM 2  (',A10,')'/)    
730     FORMAT(5X,'A1        Q. EXC1      A2        Q. EXC2')    
740     FORMAT(2(F12.1,F11.8)/)                                      
790     FORMAT(26X,'ALTERNATIVA',I2/)                                   
820     FORMAT(6X,A10,1X,'==>',F12.3,5X,F8.3/)                                  
905     FORMAT(16X,'ALTERNATIVA',I2,1X,'DE MENOR E.M.Q. =',F7.4/)       
910     FORMAT(6X,7F9.3)                                               
920     FORMAT(/6X,'N. DO PONTO',12X,'RESIDUOS (m)'/)           
925     FORMAT(29X,'(VX/VY/VZ)'/)                                       
930     FORMAT(27X,F10.3)                                               
940     FORMAT(6X,'N. GRAUS LIB. =',I3/)                                
950     FORMAT(6X,'E.M.Q. DA UNIDADE DE PESO =',F10.3/)                 
960     FORMAT(/16X,'LINHAS DA MATRIZ INVERSA DO SISTEMA NORMAL'/)     
970     FORMAT(//4X,'PARAMETROS DA TRANSF.',4X,'&',
     1  4X,'E.M.Q. DOS PARAMETROS'/)    
980     FORMAT(//16X,'LINHAS DA MATRIZ DE CORRELACAO'/)                 
985     FORMAT(//16X,'LINHAS DA MATRIZ DAS VARIANCIAS-COVARIANCIAS'/)  
990     FORMAT(6X,3F10.3,4F8.4)                                         
1000    STOP                                                            
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