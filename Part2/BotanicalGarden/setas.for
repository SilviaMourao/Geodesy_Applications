      program setas

	implicit real*8 (a-h,o-z)
      pi = 4.d0*datan(1.d0)

      open(1,file='setasJB6.prn')
	

      open (2, file = 'desvios06.dxf')

      write (2, '(i3)') 0
      write (2, '(a7)') 'SECTION'
      write (2, '(i3)') 2
      write (2, '(a8)') 'ENTITIES'

      zero=0.0
	DO I=1,13
	  READ(1,*)NP,DM,DP,AM,AP
	  AM0=AM-DM
	  AP0=AP-DP
	  D=DSQRT(DM**2+DP**2)
	  TET=DATAN2(DP,DM)
	  IF (TET.LT.0.D0) TET=TET+2*PI
        AM=AM0+1000*D*DCOS(TET)
	  AP=AP0+1000*D*DSIN(TET)
        write (2, fmt = '(a3)') '  0'
        write (2, fmt = '(a4)') 'LINE'
        write (2, fmt = '(a3)') '  8'
        write (2, fmt = '(a4)') 'LAYER1'
        write (2, fmt = '(a3)') ' 10'
        write (2, 20) AM0
        write (2, fmt = '(a3)') ' 20'
        write (2, 20) AP0
        write (2, fmt = '(a3)') ' 30'
        write (2, 20) zero
        write (2, fmt = '(a3)') ' 11'
        write (2, 20) AM
        write (2, fmt = '(a3)') ' 21'
        write (2, 20) AP
        write (2, fmt = '(a3)') ' 31'
        write (2, 20) zero

	  esc=0.5
	  tet1=tet+pi/6+pi
	  AM1=AM+esc*DCOS(TET1)
	  AP1=AP+esc*DSIN(TET1)
        write (2, fmt = '(a3)') '  0'
        write (2, fmt = '(a4)') 'LINE'
        write (2, fmt = '(a3)') '  8'
        write (2, fmt = '(a4)') 'LAYER1'
        write (2, fmt = '(a3)') ' 10'
        write (2, 20) AM
        write (2, fmt = '(a3)') ' 20'
        write (2, 20) AP
        write (2, fmt = '(a3)') ' 30'
        write (2, 20) zero
        write (2, fmt = '(a3)') ' 11'
        write (2, 20) AM1
        write (2, fmt = '(a3)') ' 21'
        write (2, 20) AP1
        write (2, fmt = '(a3)') ' 31'
        write (2, 20) zero

        tet2=tet-pi/6+pi
	  AM2=AM+esc*DCOS(TET2)
	  AP2=AP+esc*DSIN(TET2)
        write (2, fmt = '(a3)') '  0'
        write (2, fmt = '(a4)') 'LINE'
        write (2, fmt = '(a3)') '  8'
        write (2, fmt = '(a4)') 'LAYER1'
        write (2, fmt = '(a3)') ' 10'
        write (2, 20) AM
        write (2, fmt = '(a3)') ' 20'
        write (2, 20) AP
        write (2, fmt = '(a3)') ' 30'
        write (2, 20) zero
        write (2, fmt = '(a3)') ' 11'
        write (2, 20) AM2
        write (2, fmt = '(a3)') ' 21'
        write (2, 20) AP2
        write (2, fmt = '(a3)') ' 31'
        write (2, 20) zero

	ENDDO
20    FORMAT(F10.5)

100   write (2, '(i3)') 0
      write (2, '(a6)') 'ENDSEC'
      write (2, '(i3)') 0
      write (2, '(a3)') 'EOF'

      close(1)

	close(2)


      end
