      program setas

	implicit real*8 (a-h,o-z)
      pi = 4.d0*datan(1.d0)

      open(1,file='setas10gb.prn')
      open (2, file = 'setas10gb.dxf')

      write (2, '(i3)') 0
      write (2, '(a7)') 'SECTION'
      write (2, '(i3)') 2
      write (2, '(a8)') 'ENTITIES'

      zero=0.0
	esc1=10.0
	esc2=0.05
	DO I=1,119
	  READ(1,*)NP,AP,AM,DP,DM,DH
	  AM0=AM
	  AP0=AP
	  D=DH/10.D0
	  IF (DH.GE.0.D0) THEN 
	   TET=PI/2.D0
         AM=AM0+esc1*D*DCOS(TET)
	   AP=AP0+esc1*D*DSIN(TET)
	  ELSE
	   TET=3*PI/2.D0
         AM=AM0-esc1*D*DCOS(TET)
	   AP=AP0-esc1*D*DSIN(TET)
	  ENDIF

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


	  tet1=tet+pi/6+pi
	  AM1=AM+esc2*DCOS(TET1)
	  AP1=AP+esc2*DSIN(TET1)
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
	  AM2=AM+esc2*DCOS(TET2)
	  AP2=AP+esc2*DSIN(TET2)
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
