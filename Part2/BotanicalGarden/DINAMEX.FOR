   	PROGRAM DINAMEX
C  VERS√O EVOLUIDA DO PROGRAMA DINAM. INCLUI A SOBROTINA DE C¡LCULO DE COVARI¬NCIAS
C  COMPENSA REDES GEOD…SICAS NO PLANO CARTOGR¡FICO, COM OS SISTEMAS DE 
C  PROJEC«√O DE GAUSS OU UTM, SOBRE OS ELIPS”IDES HAYFORD OU WGS84.
C
C  MODO INTERACTIVO: PARA USAR ESTE MODO … NECESS¡RIO ACTIVAR RESPECTIVOS
C                    COMANDOS E DESACTIVAR A LEITURA DO [DINAMIT].[IN]
C
C  OP«’ES: NOP1=0,1,2 (NULO,GAUSS/UTM); 
C          NOP2=0,1,2 (NULO,HAYFORD/WGS84)
C          OP=s,n (CRIAR OU N√O O FICHEIRO DE COEFICIENTES EM DINAMCOE.DAT)
C          OP=e,ef,f (RESÕDUOS NO ECRAN, NO ECRAN E FICHEIRO, OU NO FICHEIRO)
C          LC=l,c (COMPENSA«√O LIVRE OU CONSTRANGIDA)
C          SCL= MODULO DA ESCALA PARA AS ELIPSES DE ERRO (EX:10000)
C          ESC= FACTOR DE CONFIAN«AS DAS ELIPSES (PARA ELIPSES DE ERRO =1.0)
C  FICH.COORDS: Linha1= DESIGNA«√O DA REDE
C               Linha2= LAT E LON DO PONTO CENTRAL DE PROJEC«√O
C               Linha3= NOME DO DATUM
C               Linha4= N∫PTS LIVRES, N∫PTS FIXOS, N∫DIR., N∫COMP. E N∫AZIM
C               Linha5(...)= V…RTICE E COORDENADAS (m,p); PTS FIXOS FICAM NO FIM
C  FICH.OBSERV: Linha1..N∫DIR= PE, PV, DIREC«’ES, PESO
C               LinhaN∫DIR+1...= PE, PV, COMPRIMENTO, PESO
C               LinhaN∫COMP+1...= PE, PV, AZIMUTE, LAT. E LONG. DA ESTA«√O, PESO
C
C  … FORMADO UM FICHEIRO COM A MATRIZ TRIANGULAR INFERIOR DA MATRIZ NORMAL

      IMPLICIT REAL*8 (a-h,o-z)
      CHARACTER  nome*60,op*4

c      CALL opcao(nop1,nop2)
      OPEN(1,FILE='DINAM.IN',STATUS='OLD')
      READ(1,*)NOP1,NOP2

C      WRITE(*,*) 'FICHEIRO DE COORDENADAS:'
      READ(1,'(A14)') nome
      OPEN(15,FILE=nome,STATUS='old')

C      WRITE(*,'(/,A25)') ' FICHEIRO DE OBSERVAÄôES:'
      READ(1,'(A14)') nome
      OPEN(16,FILE=nome,STATUS='old')
      OPEN(18,FILE='DINAM.DAT',STATUS='unknown')
      OPEN(19,FILE='NORMAL.DAT',STATUS='unknown')
C	OPEN(19,STATUS='scratch')
      OPEN(20,STATUS='scratch')

C      WRITE(*,'(/,A32)') ' NOME PARA O FICHEIRRO DE SAãDA:'
      READ(1,'(A14)') nome
      OPEN(21,FILE=nome,STATUS='unknown')
      OPEN(22,FILE='COORDS.DAT',STATUS='unknown')

C      WRITE(6,'(A1,//)') ' '
C      WRITE(6,*) 'PRETENDE VERIFICAR OS COEFICIENTES DAS EQUAÄôES DE OBS
C     1EVAÄéO (s/n) ?'
C      WRITE(6,*) '(se sim, o programa apenas cria o ficheiro, se nÑo, el
C     1e ser† extinguido e o    programa corrrer† atÇ ao fim)'
      READ(1,'(A2)') op
      IF (op.EQ.'s'.OR.op.EQ.'S') THEN
        OPEN(17,FILE='DINAMCOE.DAT',STATUS='unknown')
      ELSE
        open(17,STATUS='scratch')
      ENDIF
      WRITE(6,'(//,20X,A28)') '**** DINAMF EM EXECUÄéO ****'

      CALL dinamf(nop1,nop2)

      WRITE(*,'(//,21X,A26)') '**** DINAMF TERMINADO ****'
      DO 10 i=15,19
        REWIND(i)
10    CONTINUE

      IF (op.NE.'s'.AND.op.NE.'S') THEN
         WRITE(6,'(//,20X,A28)') '**** NORMF EM EXECUÄéO ****'

         CALL normf

         WRITE(*,'(//,21X,A26)') '**** NORMF TERMINADO ****'
         DO 20 i=15,20
           REWIND(i)
20       CONTINUE
         WRITE(6,'(//,21X,A27)') '**** TERMF EM EXECUÄéO ****'

         CALL termf(nop1,var)

         WRITE(*,'(//,21X,A25,/)') '**** TERMF TERMINADO ****'

         OPEN(23,FILE='VARCOV.OUT')
         OPEN(24,FILE='COVAR.OUT')

         WRITE(6,'(//,21X,A27)') '**** COVAR EM EXECUÄéO ****'

         CALL COVAR(VAR)

         WRITE(*,'(//,21X,A25,/)') '**** COVAR TERMINADO ****'

         WRITE(6,'(//,20X,A,/)') '**** ELIPSES EM EXECUÄéO ****'

         CALL ELIPSES

         WRITE(*,'(//,21X,A,//)') '**** ELIPSES TERMINADO ****'

         WRITE(*,*) 'NOTA1: SAIU [coords].[dat] COM AS COMPENSADAS E COM 
     1 MESMO FORMATO DE ENTRADA.'
         WRITE(*,*) 'NOTA2: SAIRAM AS ELIPSES ABSOLUTAS EM [elipses].[ou
     1t] E [elipses].[dxf]' 

      ELSE
         WRITE(*,'(/)')
         WRITE(*,*) 'NOTA: OS COEFICIENTES ENCONTRAM-SE NO FICHEIRO [din
     1amcoe].[dat]'
      ENDIF


      CLOSE(1)
      DO 30 i=15,24
        CLOSE(i)
30    CONTINUE

      READ(*,*)
      END
C   *************************  SUBROTINA OPC√O  ***********************
      SUBROUTINE opcao(nop1,nop2)
      WRITE(*,'(14(/),10X,A49,//)') 'COMPENSAÄéO DE UMA REDE GEOD
     1êSICA SOBRE'
      WRITE(*,'(29X,A20,//)') 'O PLANO CARTOGRÜFICO'
      WRITE(*,'(21X,A36,/)') 'TIPO DE COORDENADAS CARTOGRÜFICAS :'
      WRITE(*,'(31X,A9,/,31X,A9)') '1 - GAUSS','2 - U.T.M.'
      READ(*,*) nop1
      WRITE(*,'(//,25X,A23,/)') 'ELIPS‡IDE CONSIDERADO :'
      WRITE(*,'(31X,A11,/,31X,A9)') '1 - HAYFORD','2 - WGS84'
      READ(*,*) nop2
      WRITE(*,'(A1,///)') ' '
      RETURN
      END
C   *************************  SUBROTINA DINAMF  **********************
      SUBROUTINE dinamf(nop1,nop2)

      IMPLICIT INTEGER (i-n)
      IMPLICIT REAL*8 (a-h,o-z)
      REAL*8 K0
      CHARACTER nomes*35,datum*16,elip*10,scoord*10
      LOGICAL flag,marca
      INTEGER an(100)
      DIMENSION am(100),ap(100),c(300),s(300)
      DATA am,ap,c,s,an/100*0.d0,100*0.d0,300*0.d0,300*0.d0,100*0/
C    ELIPS”IDE DE HAYFORD
      DATA semh,e2h/6378388.d0,0.00672267002233d0/
C    ELIPS”IDE WGS84
      DATA semw,e2w/6.378137d6,0.006694379980678d0/

      IF (nop2 .EQ. 1) THEN
         sem=semh
         e2=e2h
         elip='HAYFORD'
      ELSE IF (nop2 .EQ. 2) THEN
         sem=semw
         e2=e2w
         elip='WGS84'
	ELSE 
         sem=0.D0
         e2=0.D0
         elip='NULO'
      ENDIF
      READ(15,'(A30)') nomes
      WRITE(21,100) nomes
      WRITE(*,100) nomes
      IF (nop1 .EQ. 1) THEN
        scoord='GAUSS'
        READ(15,*) alatpc,alonpc
        k0=1.d0
      ELSE IF (nop1 .EQ. 2) THEN
        scoord='U.T.M.'
        READ(15,*) alatpc,alonpc,alonmc,nfuso
        CALL graud(alonmc,ngr,min,seg)
        k0=0.9996d0
	ELSE
        scoord='NULA'
        READ(15,*) alatpc,alonpc
        k0=1.d0
      ENDIF
      READ(15,'(A16)') datum
      CALL graud(alatpc,ngr,min,seg)
      pi=DACOS(-1.D0)
      alatpc=alatpc*pi/180.d0
      aux=1.d0-e2*DSIN(alatpc)*DSIN(alatpc)
      rm2=(k0*k0*sem*sem*(1.d0-e2))/(aux*aux)
      WRITE(21,'(11X,A8,A16,3X,A12,A8,/)') 'DATUM : ',datum,'ELIPS”IDE
     1: ',elip
      WRITE(*,'(11X,A8,A16,3X,A12,A8,/)') 'DATUM : ',datum,'ELIPSOIDE :
     1 ',elip
      WRITE(21,'(16X,A28,A6,/)') 'PROJEC«√O CARTOGR¡FICA : ',scoord
      WRITE(*,'(16X,A28,A6,/)') 'PROJECÄéO CARTOGRÜFICA : ',scoord
      WRITE(21,101) ngr,min,seg
      WRITE(*,101) ngr,min,seg
      CALL graud(alonpc,ngr,min,seg)
      WRITE(21,'(39X,I4,1X,I2,1X,F6.3,/)') ngr,min,seg
      WRITE(*,'(39X,I4,1X,I2,1X,F6.3,/)') ngr,min,seg
      IF (nop1 .EQ. 2) THEN
        WRITE(21,'(28X,A7,I2)') 'FUSO : ',nfuso
        WRITE(*,'(28X,A7,I2)') 'FUSO : ',nfuso
      ENDIF
      READ(15,*) np,nf,nd0,nc0,na0
      WRITE(21,200) np,nf
      WRITE(*,200) np,nf
      WRITE(21,400) nd0,nc0,na0
      WRITE(*,400) nd0,nc0,na0
      np1=2*np+1
      np2=np1+1
      nt=np+nf
      READ(15,*) (an(i),am(i),ap(i), i=1,nt)
      mt=1
      n=0
      nd=0
      nt0=0
      flag=.TRUE.
C    ///////////// EQUA«’ES DE DIREC«√O /////////////
      IF (nd0 .NE. 0) THEN
1000     IF (flag) THEN
            READ(16,*) me,mv,g,sm,s1,w
            c(np2)=w
            n=n+1
            nu=1
1001        IF (me .NE. an(nu))  THEN
                nu=nu+1
                GOTO 1001
            ENDIF
            me=nu
            nu=1
1002        IF (mv .NE. an(nu))  THEN
               nu=nu+1
               GOTO 1002
            ENDIF
            mv=nu
            IF (n .EQ. 1) THEN
               w0=w
               me0=me
            ENDIF
            marca=.FALSE.
            IF (nop1 .EQ. 1) amu=2.d0*am(me)+am(mv)
	      IF (nop1 .EQ. 2) amu=2.d0*(am(me)-5.d5)+(am(mv)-5.d5)
	      apu=ap(me)-ap(mv)

C     CORREC«√O TANGENTE-CORDA ¿S DIREC«’ES
            IF (rm2.ne.0.d0) then
	        c1=amu*apu/(6.d0*rm2)*(1.d0-amu*amu/(27.d0*rm2))
	      ELSE
		   c1=0.d0
	      ENDIF
            al=g+sm/60.d0+s1/3600.d0+c1*1.8d2/pi
         ELSE
           flag=.TRUE.
           me0=me
           w0=w
         ENDIF
         IF  ((me .EQ. me0) .AND. (w .EQ. w0))  THEN
            nd=nd+1
            am1=am(mv)-am(me)
            ap1=ap(mv)-ap(me)
            s1=DSQRT(am1**2+ap1**2)
            IF  (ap1 .NE. 0.d0)  THEN
               r=DATAN(am1/ap1)*57.29577951d0
               IF (ap1 .LE. 0.d0) r=r+180.d0
            ELSE
               IF (am(mv) .GT. am(me)) THEN
                 r=90.d0
               ELSE
                 r=270.d0
               ENDIF
            ENDIF
            IF ((n .EQ. 1) .OR. marca) THEN
               r0=r-al
               me0=me
            ENDIF
            c1=r0+al-r
1003        IF (DABS(c1) .GE. 180.D0) THEN
               c1=c1-360.d0*(DABS(c1)/c1)
               GOTO 1003
            ENDIF
            c(np1)=c1*3600.d0
            r=r*1.745329252d-2
            IF (me .LE. np) THEN
              c(2*me-1)=-206265.d0*DCOS(r)/s1
              c(2*me)=206265.d0*DSIN(r)/s1
            ENDIF
            IF (mv .LE. np) THEN
               c(2*mv-1)=206265.d0*DCOS(r)/s1
               c(2*mv)=-206265.d0*DSIN(r)/s1
            ENDIF
            DO 125 l=1,np2
125           IF (c(l) .NE. 0.d0) WRITE(17,776)mt,l,c(l)
            mt=mt+1
            DO 130 i=1,np1
               s(i)=s(i)+c(i)
130         CONTINUE
            IF (n .NE. nd0) THEN
               DO 140 i=1,np2
                  c(i)=0.d0
140            CONTINUE
            ELSE
               s(np2)=-w0/FLOAT(nd)
               DO 135 l=1,np2
135              IF (s(l) .NE. 0.d0) WRITE(17,776)mt,l,s(l)
               mt=mt+1
               nt0=nt0+1
            ENDIF
         ELSE
            flag=.FALSE.
            marca=.TRUE.
            s(np2)=-w0/FLOAT(nd)
            DO 145 l=1,np2
145            IF (s(l) .NE. 0.d0) WRITE(17,776)mt,l,s(l)
            mt=mt+1
            nt0=nt0+1
            IF (n .NE. nd0) THEN
              DO 170 i=1,np1
                s(i)=0.d0
170           CONTINUE
            ENDIF
            nd=0
         ENDIF
         IF (n .LT. nd0) GOTO 1000
      ENDIF
C   //////////// EQUA«’ES DE COMPRIMENTO ////////////
      IF (nc0 .NE. 0) THEN
        DO 301 i=1,nc0
          DO 191 k=1,np1
             c(k)=0.d0
191       CONTINUE
	  IF (nop1.EQ.0 .OR. nop1.EQ.1) THEN
            READ(16,*) me,mv,comp,w
	  ELSE
            READ(16,*) me,mv,comp,w,fim
	      CALL graud(fim,ngr,min,seg)
	  ENDIF
          nu=1
1004      IF (me .NE. an(nu)) THEN
             nu=nu+1
             GOTO 1004
          ENDIF
          me=nu
          nu=1
1005      IF (mv .NE. an(nu)) THEN
            nu=nu+1
            GOTO 1005
          ENDIF
          mv=nu
          am1=am(mv)-am(me)
          ap1=ap(mv)-ap(me)
          s1=DSQRT(am1**2+ap1**2)

C     CORREC«√O DE FACTOR DE ESCALA AOS COMPRIMENTOS
	  IF (nop1 .EQ. 1) THEN
	    comp=comp*factor_k(k0,alatpc,am(me),am(mv),sem,e2)
	  ELSE IF (nop1 .EQ. 2) THEN
	    amu1=am(me)-5.d5
	    amu2=am(mv)-5.d5
	    comp=comp*factor_k(k0,fim,amu1,amu2,sem,e2)
	  ELSE
	    comp=comp
	  ENDIF
          r=DATAN(am1/ap1)
          IF (ap1 .LE. 0.d0) r=r+pi
          c(np2)=w
          c(np1)=comp-s1
          IF (me .LE. np) THEN
             c(2*me-1)=-DSIN(r)
             c(2*me)=-DCOS(r)
          ENDIF
          IF (mv .LE. np) THEN
             c(2*mv-1)=DSIN(r)
             c(2*mv)=DCOS(r)
          ENDIF
          DO 155 l=1,np2
155          IF (c(l) .NE. 0.d0) WRITE(17,776) mt,l,c(l)
          mt=mt+1
301     CONTINUE
      ENDIF
C   /////////// EQUA«’ES DE AZIMUTE ///////////
      IF (na0 .NE. 0) THEN
         DO 19 i=1,na0
            DO 197 k=1,np1
              c(k)=0.d0
197         CONTINUE
            if (nop1 .ne. 0) then
             READ(16,*) me,mv,g,sm,s1,alat,alon,w
             CALL graud(alat,ngr,min,seg)
             CALL graud(alon,ngr,min,seg)
	      else
             READ(16,*) me,mv,g,sm,s1,w
	       alat=0.d0
	       alon=0.d0
	      endif
            nu=1
1006        IF (me .NE. an(nu)) THEN
               nu=nu+1
               GOTO 1006
            ENDIF
            me=nu
            nu=1
1007        IF (mv .NE. an(nu)) THEN
              nu=nu+1
              GOTO 1007
            ENDIF
            mv=nu
            alat=alat*pi/1.8d2
	      aux=1.d0-e2*DSIN(alat)*DSIN(alat)
	      rm2=(k0*k0*sem*sem*(1.d0-e2))/(aux*aux)
            IF (nop1 .EQ. 1) amu=2.d0*am(me)+am(mv)
	      IF (nop1 .EQ. 2) amu=2.d0*(am(me)-5.d5)+(am(mv)-5.d5)
	      apu=ap(me)-ap(mv)
	 
C     CORREC«√O TANGENTE-CORDA AOS AZIMUTES
            IF (rm2.ne.0.d0) then
	        c1=amu*apu/(6.d0*rm2)*(1.d0-amu*amu/(27.d0*rm2))
	      ELSE
		   c1=0.d0
	      ENDIF
	      r1=g+sm/60.d0+s1/3600.d0+c1*180.d0/pi
            am1=am(mv)-am(me)
            ap1=ap(mv)-ap(me)
            s1=DSQRT(am1**2+ap1**2)
            r=DATAN(am1/ap1)*57.29577951d0

C     CORREC«√O DA CONVERG NCIA DE MERIDIANOS AOS AZIMUTES
            IF (nop1 .EQ. 0) cm=0.d0
            IF (nop1 .EQ. 1) cm=(alonpc-alon)*DSIN(alat)
            IF (nop1 .EQ. 2) cm=(alonmc-alon)*DSIN(alat)
            IF (ap1 .LE. 0.d0) r=r+180.d0
            c1=r1-r+cm
1008        IF (DABS(c1) .GE. 180.d0) THEN
              c1=c1-360.d0*(DABS(c1)/c1)
              GOTO 1008
            ENDIF
            c(np1)=c1*3600.d0
            r=r*1.745329252d-2
            IF (me .LE. np) THEN
               c(2*me-1)=-206265.d0*DCOS(r)/s1
               c(2*me)=206265.d0*DSIN(r)/s1
            ENDIF
            IF (mv .LE. np) THEN
               c(2*mv-1)=206265.d0*DCOS(r)/s1
               c(2*mv)=-206265*DSIN(r)/s1
            ENDIF
            c(np2)=w
            DO 165 l=1,np2
              IF (c(l) .NE. 0.d0) WRITE(17,776) mt,l,c(l)
165         CONTINUE
            mt=mt+1
19       CONTINUE
      ENDIF
      WRITE(18,900) np,nf,nd0,nc0,na0,nt0
      WRITE(17,776) mt,l,c(l)
      RETURN

100   FORMAT(/,15X,'COMPENSA«√O GEODESICA DA REDE : ',A35)
101   FORMAT(15X,'PARA O PONTO CENTRAL DE ',I4,' ',I2,' ',F6.3)
200   FORMAT(/,14X,I4,' PONTOS LIVRES',8X,I4,' PONTOS FIXOS',/)
400   FORMAT(10X,I4,' DIREC«’ES',3X,I4,' COMPRIMENTOS',3X,I4,
     1' AZIMUTES',/)
776   FORMAT(3X,I4,3X,I4,5X,F16.4)
900   FORMAT(2X,6(I4,2X))
      END
C  ***************** SUBRUTINA GRAUD **************************
      SUBROUTINE graud(ang,ngr,min,seg)
      IMPLICIT REAL*8(a-h,o-z)
      ang1=DABS(ang)
      ngr=IDINT(ang1)
      gm=(ang1-ngr)*1.d2
      min=IDINT(gm)
      IF ((gm-IDINT(gm)) .GT. 9.999999d-1) min=min+1.d0
      seg=(gm-min)*1.d2
      ang2=ngr+min/6.d1+seg/3.6d3
      IF (ang .LT. 0.d0) THEN
        ang2=-ang2
        ngr=-ngr
      ENDIF
      ang=ang2
      RETURN
      END
C   ******************** FUN«√O FACTOR_K **********************
	REAL*8 FUNCTION factor_k(k0,fim,m1,m2,a,e2)
	IMPLICIT REAL*8 (a-h,o-z)
	REAL*8 k0,fim,m1,m2,a,e2,nu
	pi=DACOS(-1.d0)
	eu2=m1**2+m1*m2+m2**2
	wd=DSQRT(1.d0-e2*(DSIN(fim*pi/1.8d2))**2)
	ro=a*(1.d0-e2)/wd**3
	nu=a/wd
	r2=ro*nu*k0**2
	factor_k=k0*(1.d0+eu2/(6.d0*r2)*(1.d0+eu2/(36.d0*r2)))
	RETURN
	END
C   ******************** SUBRUTINA NORMF **********************
      SUBROUTINE normf

      IMPLICIT INTEGER (i-n)
      IMPLICIT REAL*8 (a-h,o-z)
      DIMENSION a(100,100),c(300),n(300)
      DATA a,c,n/10000*0.d0,300*0.d0,300*0/
      READ(18,700) np,nf,nd0,nc0,na0,nt0
      nt=2*np
      np1=nt+1
      np2=np1+1
      n0=nd0+nc0+na0+nt0
      WRITE(19,*) nt
      aux=0.d0
      k1=1
      l=1
      DO 5 i=1,50
        DO 5 j=1,50
          a(i,j)=0.d0
5     CONTINUE
      DO 10 i=1,n0
         k2=k1
1000     IF (k1.EQ.k2) THEN
            c(l)=aux
            READ(17,776)k1,l,aux
            GOTO 1000
         ENDIF
         nz=0
         DO 30 j=1,nt
            IF (c(j).NE.0.d0) THEN
               nz=nz+1
               n(nz)=j
            ENDIF
30       CONTINUE
         IF (nz.NE.0) THEN
            n(nz+1)=np1
            DO 15 j=1,nz
               DO 40 k=j,nz+1
40                a(n(j),n(k))=a(n(j),n(k))+c(n(j))*c(n(k))*c(np2)
15             CONTINUE
         ENDIF
         DO 50 ij=1,np2
           c(ij)=0.d0
50       CONTINUE
10    CONTINUE
      DO 8 i=1,nt
         DO 8 j=1,i
            a(i,j)=a(j,i)
            WRITE(19,*) a(i,j)
8     CONTINUE
      DO 60 i=1,nt-1
         IF (a(i,i).LT.0.d0) THEN
	     WRITE(*,'(/,12X,A30,I3,A10)') 
	1          'SISTEMA IMPOSSIVEL: Elemento ',i,' Negativo'
	     READ(*,*)
	     STOP
	   ELSE
           a(i,i)=DSQRT(a(i,i))
	   ENDIF
         DO 70 k=i+1,nt+1
            a(i,k)=a(i,k)/a(i,i)
70       CONTINUE
         DO 60 j=i+1,nt
            DO 90 k=j,nt+1
90             a(j,k)=a(j,k)-a(i,j)*a(i,k)
60    CONTINUE
      c(nt)=a(nt,nt+1)/a(nt,nt)
      DO 100 i=1,nt-1
         m=nt-i
         DO 110 k=m+1,nt
110         a(m,nt+1)=a(m,nt+1)-a(m,k)*c(k)
         c(m)=a(m,nt+1)/a(m,m)
100   CONTINUE
      DO 120 i=1,nt
         WRITE(20,*) c(i)
120   CONTINUE

      RETURN
700   FORMAT(2X,6(I4,2X))
776   FORMAT(3X,I4,3X,I4,5X,F16.4)
      END
C   ******************* SUBRUTINA TERMF ***********************
      SUBROUTINE termf(nop1,s)
      IMPLICIT INTEGER (i-n)
      IMPLICIT REAL*8 (a-h,o-z)
      DIMENSION c(100),x(100),v(20)
      CHARACTER datum*16,op*4,nomes*30,LC*4
      LOGICAL volta
      DATA c,x,v/100*0.d0,100*0.d0,20*0.d0/
      READ(18,700) np,nf,nd0,nc0,na0,nt0
      n0=2*np
      np2=n0+2
      s0=0.d0
      s=0.d0
      n=0
      nd=0
      READ(20,*) (x(i),i=1,n0)

C      WRITE(*,'(/,10X,A45)')'PRETENDE OS RESÕDUOS DAS OBSERVA«’ES NO ECR
C     1AN'
C      WRITE(*,'(10X,A36)')'E/OU NO FICHEIRO DE SAÕDA (e,ef,f) ?'
      READ(1,'(A2)') op
      IF (nd0.NE.0) THEN
         IF (op.EQ.'f'.OR.op.EQ.'F') THEN
            WRITE(21,1015)
         ELSE IF (op.EQ.'e'.OR.op.EQ.'E') THEN
            WRITE(*,1015)
         ELSE
            WRITE(21,1015)
            WRITE(*,1015)
         ENDIF
         aux=0.d0
         k1=1
         l=1
2000     IF (n .NE. nd0) THEN
            volta=.FALSE.
            k2=k1
2001        IF (k1.EQ.k2) THEN
               c(l)=aux
               READ(17,776) k1,l,aux
               GOTO 2001
            ENDIF
            IF (c(np2).GE.0.d0) THEN
               nd=nd+1
               v(nd)=-c(n0+1)
               DO 40 i=1,n0
40                v(nd)=v(nd)+c(i)*x(i)
               s0=s0+v(nd)
            ELSE
               volta=.TRUE.
            ENDIF
            IF (volta) THEN
               s0=s0/DBLE(nd)
               DO 60 i=1,nd
                  n=n+1
                  v(i)=v(i)-s0
                  IF (op.EQ.'f' .OR. op.EQ.'F') THEN
                     READ(16,*) me,mv
                     WRITE(21,1010) n,me,mv,v(i)
                  ELSE IF (op.EQ.'e' .OR. op.EQ.'E') THEN
                     READ(16,*) me,mv
                     WRITE(*,1010) n,me,mv,v(i)
                  ELSE
                     READ(16,*) me,mv
                     WRITE(21,1010) n,me,mv,v(i)
                     WRITE(*,1010) n,me,mv,v(i)
                  ENDIF
                  s=s-c(np2)*DBLE(nd)*v(i)**2
60             CONTINUE
               IF (n.NE.nd0) THEN
                  nd=0
                  s0=0.d0
               ENDIF
            ENDIF
            DO 50 ij=1,np2
50             c(ij)=0.d0
           GOTO 2000
         ENDIF
      ENDIF
      IF (nc0 .NE. 0) THEN

C         WRITE(*,'(/,10X,A47)')'PRETENDE OS RESÕDUOS DOS COMPRIMENTOS NO
C     1 ECRAN'
C         WRITE(*,'(11X,A36)')'E/OU NO FICHEIRO DE SAÕDA (e,ef,f) ?'
C         READ(*,'(A2)') op
         IF (op.EQ.'f'.OR.op.EQ.'F') THEN
            WRITE(21,1020)
         ELSE IF (op.EQ.'e'.OR.op.EQ.'E') THEN
            WRITE(*,1020)
         ELSE
            WRITE(21,1020)
            WRITE(*,1020)
         ENDIF
         n=0
         DO 90 k=1,nc0
           vs=0
           k2=k1
2003       IF (k1.EQ.k2) THEN
              c(l)=aux
              READ(17,776) k1,l,aux
              GOTO 2003
           ENDIF
           vs=-c(n0+1)
           DO 13 i=1,n0
              vs=vs+c(i)*x(i)
13         CONTINUE
           n=n+1
           IF (op.EQ.'f'.OR.op.EQ.'F') THEN
              READ(16,*) me,mv
              WRITE(21,1010) n,me,mv,vs
           ELSE IF (op.EQ.'e'.OR.op.EQ.'E') THEN
              READ(16,*) me,mv
              WRITE(*,1010) n,me,mv,vs
           ELSE
              READ(16,*) me,mv
              WRITE(21,1010) n,me,mv,vs
              WRITE(*,1010) n,me,mv,vs
           ENDIF
           s=s+c(np2)*vs**2
           DO 52 ij=1,np2
52            c(ij)=0.d0
90       CONTINUE
      ENDIF
      IF (na0 .NE. 0) THEN

C         WRITE(*,'(/,10X,A43)') 'PRETENDE OS RESDUOS DOS AZIMUTES NO EC
C     1RAN'
C         WRITE(*,'(11X,A36)') 'E/OU NO FICHEIRO DE SAÕDA (e,ef,f) ?'
C         READ(*,'(A2)') op
         IF (op.EQ.'f'.OR.op.EQ.'F') THEN
            WRITE(21,1040)
         ELSE IF (op.EQ.'e'.OR.op.EQ.'E') THEN
            WRITE(*,1040)
         ELSE
            WRITE(21,1040)
            WRITE(*,1040)
         ENDIF
         n=0
         DO 110 k=1,na0
            k2=k1
2004        IF (k1.EQ.k2) THEN
               c(l)=aux
               READ(17,776) k1,l,aux
               GOTO 2004
            ENDIF
            vs=-c(n0+1)
            DO 15 i=1,n0
               vs=vs+c(i)*x(i)
15          CONTINUE
            n=n+1
            IF (op.EQ.'f'.OR.op.EQ.'F') THEN
               READ(16,*) me,mv
               WRITE(21,1010) n,me,mv,vs
            ELSE IF (op.EQ.'e'.OR.op.EQ.'E') THEN
               READ(16,*) me,mv
               WRITE(*,1010) n,me,mv,vs
            ELSE
               READ(16,*) me,mv
               WRITE(21,1010) n,me,mv,vs
               WRITE(*,1010) n,me,mv,vs
            ENDIF
            s=s+c(np2)*vs**2
            DO 54 ij=1,np2
54             c(ij)=0.d0
110      CONTINUE
      ENDIF
      n=nd0+nc0+na0
      i=2*np+nt0
      ngl=n-i
      IF (ngl.NE.0) THEN
         s=s/DBLE(ngl)
         WRITE(21,1060) s
         WRITE(*,1060) s
         WRITE(21,1080) ngl
         WRITE(*,1080) ngl
      ENDIF
      READ(15,'(A30)') nomes
      WRITE(22,'(A30)') nomes
      IF (nop1.EQ.0 .OR. nop1.EQ.1) THEN
        READ(15,*) alatpc,alonpc
        WRITE(22,'(F12.7,3X,F12.7)') alatpc,alonpc
      ELSE
        READ(15,*) alatpc,alonpc,alonmc,nfuso
        WRITE(22,'(3(F12.7,3X),I2)')alatpc,alonpc,alonmc,nfuso
      ENDIF
      READ(15,'(A16)') datum
      WRITE(22,'(A16)') datum
      READ(15,*) j1,j2,nd0,nc0,na0
      WRITE(22,'(I4,3X,I2,3X,I5,3X,I2,3X,I2)') j1,j2,nd0,nc0,na0

C      WRITE(*,'(/,12X,A30)') 'LIVRE OU CONSTRNGIDA (L/C) ? '
      READ(1,'(A2)') LC
      IF (LC .EQ. 'c' .OR. LC .EQ. 'C') THEN
         WRITE(21,1100)
         WRITE(*,1100)
	 IF (nop1 .EQ. 1) THEN
           WRITE(21,1110)
           WRITE(*,1110)
	 ELSE
           WRITE(21,1111)
           WRITE(*,1111)
	 ENDIF
         DO 130 i=1,np
            READ(15,*) nu,am,ap
            am=am+x(2*i-1)
            ap=ap+x(2*i)
            WRITE(*,1120) nu,x(2*i-1),x(2*i),am,ap
            WRITE(21,1120) nu,x(2*i-1),x(2*i),am,ap
            WRITE(22,'(I4,3X,F13.4,2X,F13.4)') nu,am,ap
130     CONTINUE
        DO 131 i=1,nf
           READ(15,*) nu,am,ap
           WRITE(*,1121) nu,am,ap
           WRITE(21,1121) nu,am,ap
           WRITE(22,'(I4,3X,F13.4,2X,F13.4)') nu,am,ap
131     CONTINUE
      ENDIF

      RETURN
700   FORMAT(2X,6(I4,2X))
776   FORMAT(3X,I4,3X,I4,5X,F16.4)
1010  FORMAT(8X,I5,6X,I4,' -',I4,10X,F12.3)
1015  FORMAT(//,8X,'DIREC«√O',5X,'ME',3X,'MV',9X,'RESÕDUOS',/)
1020  FORMAT(//,6X,'COMPRIMENTO',4X,'ME',3X,'MV',10X,'RESÕDUOS',/)
1040  FORMAT(//,8X,'AZIMUTE',6X,'ME',3X,'MV',10X,'RESÕDUOS',/)
1060  FORMAT(//,12X,'VARIANCIA DA UNIDADE DE PESO = ',F6.3)
1080  FORMAT(/,12X,'NUMERO DE GRAUS DE LIBERDADE = ',I5)
1091  FORMAT(/,10X,'COMPENSA«√O LIVRE')
1100  FORMAT(//,18X,'COORDENADAS COMPENSADAS',//)
1110  FORMAT(6X,'PONTO',3X,'DELTA M',4X,'DELTA P',9X,'M',12X,'P',/)
1111  FORMAT(6X,'PONTO',3X,'DELTA E',4X,'DELTA N',9X,'E',12X,'N',/)
1120  FORMAT(7X,I4,4X,F7.4,3X,F7.4,3X,F12.4,2X,F12.4)
1121  FORMAT(7X,I4,4X,'PONTO FIXO',10X,F12.4,2X,F12.4)
      END

C    *************  SUBROTINA COVAR  ******************

      SUBROUTINE COVAR(VAR)

C      CALCULA A MATRIZ DE VARIANCIAS E COVARI¬NCIAS ¿ POSTERIORI	COM
C      INVERSéO DA MATRIZ NORLMAL APLICANDO O ALGORITMO DE RESOLUÄéO DE
C      EQUAÄôES LINEARES DE CROUT

      IMPLICIT INTEGER*4 (I-N)
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (NP=100)
      DIMENSION A(NP,NP),AINV(NP,NP),B(NP),INDX(NP)

	WRITE(*,'(//,A,/)')
     1'          CALCULO DAS VARIANCIAS E COVARIANCIAS A POSTERIORI'
      
      REWIND(19)

      READ(19,*)N
      DO 1 I=1,N
        DO 1 J=1,I
          READ(19,*)A(I,J)
	  A(J,I)=A(I,J)
1     CONTINUE

      CALL LUDCMP (A,N,NP,INDX,ND)

      DO 10 LP=1,N

        DO 2 K=1,N
          B(K)=0.D0
2       CONTINUE
        B(LP)=1.D0

C    ******************** LUBSKSB ******************************

        II=0
        DO 12 I=1,N
          LL=INDX(I)
          SUM=B(LL)
          B(LL)=B(I)
          IF (II .NE. 0) THEN
             DO 11 J=II,I-1
                SUM=SUM-A(I,J)*B(J)
11           CONTINUE
          ELSE IF (SUM .NE. 0.) THEN
             II=I
          ENDIF
          B(I)=SUM
12      CONTINUE

        DO 14 I=N,1,-1
          SUM=B(I)
          IF (I .LT. N) THEN
            DO 13 J=I+1,N
              SUM=SUM-A(I,J)*B(J)
13          CONTINUE
          ENDIF
          B(I)=SUM/A(I,I)
14      CONTINUE

        DO 3 J=1,N
          AINV(J,LP)=B(J)
3       CONTINUE

10    CONTINUE


      DO 30 I=1,N
       DO 30 J=1,i
         WRITE(23,*) VAR*AINV(I,J)
30    CONTINUE

      DO 50 I=1,INT(N/2)
	 I1=I*2-1
       WRITE(24,*) VAR*AINV(I1,I1)
       WRITE(24,*) VAR*AINV(I1+1,I1),VAR*AINV(I1+1,I1+1)
50    CONTINUE

      END

C    *************************** LUDCMP ******************************


C  ê DADA A MATRIZ A(N,N), COM DIMENSéO FãSICA NP. ESTA SUBROTINA
C  SUBSTITUI A MATRIZ DADA PELA SUA DECOMPOSIÄéO L*, COM PERMUTAÄéO
C  DE DETERMINADAS LINHAS DE SI PRüPRIA. [A] E N SéO ENTRADAS. [A] ê
C  TAMBêM OUTPUT, ORDENADA COMO NA EQ. (2.3.14) pag.34. INDX ê UM
C  VECTOR OUTPUT COM REGISTOS DAS LINHAS PERMUTADAS PELO PIVOT PARCIAL.
C  ND ê UM OUTPUT COM VALORES DE +1 OU -1, CONFORME O NñMERO DE LINHAS
C  PERMUTADAS SEJA PAR OU IMPER.
C  ESTA SUBROTINA ê USADA EM COMBINAÄéO COM A SUBROTINALUBKSB PARA
C  RESOLVER SISTEMAS DE EQUAÄôES LINEARES OU PARA INVERTER MATRIZES.


      SUBROUTINE LUDCMP(A,N,NP,INDX,ND)

      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (NMAX=100,TINY=1,OE=20)
      DIMENSION A(NP,NP),VV(NMAX), INDX(NP)

      ND=1
      DO 12 I=1,N
         AAMAX=0.
         DO 11 J=1,N
           IF ((ABS(A(I,J))) .GT. AAMAX) AAMAX=ABS(A(I,J))
11       CONTINUE
         IF (AAMAX .EQ. 0) PAUSE 'MATRIZ SINGULAR'
         VV(I)=1./AAMAX
12    CONTINUE
      DO 19 J=1,N
        DO 14 I=1,J-1
           SUM=A(I,J)
           DO 13 K=1,I-1
              SUM=SUM-A(I,K)*A(K,J)
13         CONTINUE
           A(I,J)=SUM
14      CONTINUE
        AAMAX=0.
        DO 16 I=J,N
          SUM=A(I,J)
          DO 15 K=1,J-1
            SUM=SUM-A(I,K)*A(K,J)
15        CONTINUE
          A(I,J)=SUM
          DUM=VV(I)*ABS(SUM)
          IF (DUM .GE. AAMAX) THEN
            IMAX=I
            AAMAX=DUM
          ENDIF
16      CONTINUE
        IF (J .NE. IMAX) THEN
          DO 17 K=1,N
            DUM=A(IMAX,K)
            A(IMAX,K)=A(J,K)
            A(J,K)=DUM
17        CONTINUE
          ND=-ND
          VV(IMAX)=VV(J)
        ENDIF
        INDX(J)=IMAX
        IF (A(J,J) .EQ. 0.) A(J,J)=TINY
        IF (J .NE. N) THEN
          DUM=1./A(J,J)
          DO 18 I=J+1,N
            A(I,J)=A(I,J)*DUM
18        CONTINUE
        ENDIF
19    CONTINUE

      RETURN
      END

C    *************  SUBROTINA ELIPSES  ******************

      SUBROUTINE ELIPSES

C   CALCULA OS ELEMENTOS DAS ELIPSES DE ERRO DA REDE
C   E EXPORTA AS ELIPSES PARA UM FICHEIRO [DXF]

      IMPLICIT INTEGER*4 (I-N)
      IMPLICIT REAL*8 (A-H,O-Z)
      pi = 4.d0*datan(1.d0)

   
	REWIND(15)
      REWIND(24)

C      WRITE(*,'(10X,A,\)')'FACTOR ESCALA DAS ELIPSES E ESCALA GR¡FICA?'
      READ(1,*) SCL,EGR
C      WRITE(*,'(10X,A,\)')'FACTOR DE CONFIANCA DA ELIPSE ?'
      READ(1,*) ESC
	ESC=SCL*ESC
      OPEN(3,FILE='ELIPSES.OUT')

C    HEADER OF FILE.DXF
      open(4,file='elipses.dxf')
      write (4, '(i3)') 0
      write (4, '(a7)') 'SECTION'
      write (4, '(i3)') 2
      write (4, '(a8)') 'ENTITIES'


      READ(15,'(2/)')
	READ(15,*) N

      XMIN=1.D32
	YMIN=1.D32
      DO I=1,N
        READ(15,*) NP, AM, AP
	  IF (XMIN.GT.AM) XMIN=AM
	  IF (YMIN.GT.AP) YMIN=AP
        READ(24,*) VA11
        READ(24,*) VA12,VA22
	  IF ((VA11-VA22).NE.0.D0) THEN
	    TETA=DATAND(2*VA12/(VA11-VA22))/2.D0
	    IF (TETA.LT.0.D0) TETA=TETA+180.D0
	  ELSE
	    TETA=0.D0
	  ENDIF
	  A=DSQRT((VA11+VA22+SQRT((VA11-VA22)**2+(2*VA12)**2))/2)
	  B=DSQRT((VA11+VA22-SQRT((VA11-VA22)**2+(2*VA12)**2))/2)
	  WRITE(3,200)NP,AM,AP,A,B,TETA
200     FORMAT(I4,2F12.2,2F10.4,F10.1)

C    DESENHO DAS ELIPSES EM DXF
	  C1=DCOSD(TETA)
	  S1=DSIND(TETA)
	  C2=DCOSD(TETA+90)
	  S2=DSIND(TETA+90)
        X1=ESC*(A*C1*DCOSD(0.D0)+B*S1*DSIND(0.D0))+AM
        Y1=ESC*(A*C2*DCOSD(0.D0)+B*S2*DSIND(0.D0))+AP
	  DO J=0,360,5
	    ALF=REAL(J)
	    X2=ESC*(A*C1*DCOSD(ALF)+B*S1*DSIND(ALF))+AM
	    Y2=ESC*(A*C2*DCOSD(ALF)+B*S2*DSIND(ALF))+AP
	    CALL LINE(X1,Y1,X2,Y2)
	    X1=X2
	    Y1=Y2
	  ENDDO
      ENDDO

	XMAX=XMIN+SCL*EGR
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

      CLOSE(3)
	CLOSE(4)

      END


C    *************  SUBROTINA LINE  ******************

	SUBROUTINE LINE(X1,Y1,X2,Y2)
C    DESENHA SEGMENTOS RECTA NO FICHEIRO [DXF]

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
