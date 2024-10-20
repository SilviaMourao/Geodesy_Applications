      program elipse

	implicit real*8 (a-h,o-z)
	DIMENSION IPT(100),AM(100),AP(100)
	character*12 file1,file2,file3
      pi = 4.d0*datan(1.d0)

      open(0,file='rede.in',status='old')
	read(0,*) scl
	read(0,*) file1
	read(0,*) file2
	read(0,*) file3
	close(0)

      open(1,file=file1)
      open(2,file=file2)
      open(3,file=file3)

      write (3, '(i3)') 0
      write (3, '(a7)') 'SECTION'
      write (3, '(i3)') 2
      write (3, '(a8)') 'ENTITIES'

      READ(1,'(2/)')
	READ(1,*) NL,NF,ND,NC,NA
	DO I=1,NL+NF
	 READ(1,*) IPT(I),AM(I),AP(I)
	ENDDO

	DO I=1,ND
	  READ(2,*) N1,N2
	  DO J=1,NL+NF
	     IF (N1.EQ.IPT(J)) N1=J
	  ENDDO
	  DO J=1,NL+NF
	     IF (N2.EQ.IPT(J)) N2=J
	  ENDDO
 	  CALL LINE(AM(N1),AP(N1),AM(N2),AP(N2))
	ENDDO


	DD=0.05*scl
	DO I=1,NC
	  READ(2,*) N1,N2
	  R12=DATAND((AM(N2)-AM(N1))/(AP(N2)-AP(N1)))
	  X1=AM(N1)+DD*DSIND(R12-90)
	  Y1=AP(N1)+DD*DCOSD(R12-90)
	  X2=AM(N2)+DD*DSIND(R12-90)
	  Y2=AP(N2)+DD*DCOSD(R12-90)
	  CALL LINE(X1,Y1,X2,Y2)
	  X1=AM(N1)+DD*DSIND(R12+90)
	  Y1=AP(N1)+DD*DCOSD(R12+90)
	  X2=AM(N2)+DD*DSIND(R12+90)
	  Y2=AP(N2)+DD*DCOSD(R12+90)
	  CALL LINE(X1,Y1,X2,Y2)
	ENDDO

	ANG=145
	dd=0.5*scl
      DO I=1,NA
	  READ(2,*) N1,N2,NG,NM,S
	  D1=DSQRT((AM(N2)-AM(N1))**2+(AP(N2)-AP(N1))**2)/5
	  R12=NG+NM/60+S/3600
	  XP=AM(N1)+D1*DSIND(R12)
	  YP=AP(N1)+D1*DCOSD(R12)

	  RD=R12+ANG
	  IF(RD.GT.360.0) RD=RD-360
	  X1=XP+dd*DSIND(RD)
	  Y1=YP+dd*DCOSD(RD)
	  CALL LINE(XP,YP,X1,Y1)
	  RE=R12-ANG
	  IF(RE.LT.0.0) RE=RE+360
	  X2=XP+dd*DSIND(RE)
	  Y2=YP+dd*DCOSD(RE)
	  CALL LINE(XP,YP,X2,Y2)

	  CALL LINE(X1,Y1,X2,Y2)

	ENDDO


100   write (3, '(i3)') 0
      write (3, '(a6)') 'ENDSEC'
      write (3, '(i3)') 0
      write (3, '(a3)') 'EOF'

      close(1)
	close(2)
	CLOSE(3)

      end


	SUBROUTINE LINE(X1,Y1,X2,Y2)
	implicit real*8 (a-h,o-z)
      zero=0.0
      write (3, fmt = '(a3)') '  0'
      write (3, fmt = '(a4)') 'LINE'
      write (3, fmt = '(a3)') '  8'
      write (3, fmt = '(a5)') 'LAYER'
      write (3, fmt = '(a3)') ' 10'
      write (3, 20) X1
      write (3, fmt = '(a3)') ' 20'
      write (3, 20) Y1
      write (3, fmt = '(a3)') ' 30'
      write (3, 20) zero
      write (3, fmt = '(a3)') ' 11'
      write (3, 20) X2
      write (3, fmt = '(a3)') ' 21'
      write (3, 20) Y2
      write (3, fmt = '(a3)') ' 31'
      write (3, 20) zero
20    FORMAT(F12.2)


	RETURN
	END