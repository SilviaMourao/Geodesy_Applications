      Program System

      PARAMETER (numEquations = 14, numVariables = 4, MaxDimMt=13)

      real*8  A(numEquations,numVariables), B(numEquations)
	real*8  N(MaxDimMt, MaxDimMt)
      real*8  T(MaxDimMt), solution(MaxDimMt), an(5)
      real*8  max, auxl1, pi,lat, log, latRad, logRad
	real*8  sst, ssh, ondulacao, mss95, height, aux1, aux2, aux3
      integer numEquations, numVariables
      integer i, j, k, in
	character*30 f0,f1,f2


  	pi = 4*atan(1.d0)

	open (0,file='nadjust.in',status='old')
	read (0,*) f0
	read (0,*) numpt,in
	read (0,*) f1, f2
	close(0)

      open (10,file=f0,status='old')
      open (11,file=f1,status='old')
      open (12,file=f2)

	read (10,*)

      do i=1, numEquations
	   read(10,*) num,lat,log, ssh, an(1)
         ondulacao = an(in)
	   latrad= lat*pi/180.0
	   logRad= log*pi/180.0
	   a(i,1)= cos (latRad)*cos(logRad)
         a(i,2)= cos (latRad)*sin(logRad)
	   a(i,3)= sin (latRad)
	   a(i,4)= 1d0
	   b(i)  = ssh-ondulacao
	enddo

	close(10)


c  -******     Normalize System      ******- 

      do i=1, numVariables
       do j=i, numVariables
         auxl1=0.0d0
         do k=1, numEquations
          auxl1=auxl1 + a(k,i) * a(k,j)
	   enddo
         N(i,j)=auxl1
         N(j,i)=auxl1
	 enddo
       auxl1=0.0d0
       do k=1, numEquations
        auxl1 = auxl1 + a(k,i)*b(k)
	 enddo
       t(i)=auxl1;
      enddo

      do i=1, numVariables
	 n(i,numVariables+1)=t(i)
	enddo
 
c     -******  Resolution of the system N*X=T
  
 	call Cholesky (numVariables, N, T) 
	write (*,*) t(1), t(2), t(3), t(4)
     
      do i=1, numPt
       read(11,*) j,lat,log, ondulacao
	 latrad= lat*pi/180.0
       logRad= log*pi/180.0
	 auxl1 = t(1) * cos (latRad)*cos(logRad)
	 auxl1 = auxl1 + t(2) * cos (latRad)*sin(logRad)
	 auxl1 = auxl1 + t(3) * sin (latRad) + t(4)
	 write (12, 5001) j,lat, log, ondulacao, ondulacao+auxl1, auxl1
	enddo

	close(11)
	close(12)


c 5000  format(I10, 2f12.6, 5F8.2)
5001  format(i9, 2f12.6, 3F9.2)
	stop
	end

c     -******  Subroutine Cholesky A*X=C ******

      SUBROUTINE CHOLESKY(NT,N,T)
      PARAMETER (MaxDimMt=13, numVariables = 4)
	real*8  N(MaxDimMt,MaxDimMt)
      real*8  T(MaxDimMt), solution(MaxDimMt)
      real*8  max, auxl1, pivot
      integer i, j, k, nt,m

      DO 60 i=1,nt-1
        N(i,i)=DSQRT(N(i,i))
        DO 70 k=i+1,nt+1
         N(i,k)=N(i,k)/N(i,i)
   70   CONTINUE
        DO 60 j=i+1,nt
         DO 90 k=j,nt+1
   90     N(j,k)=N(j,k)-N(i,j)*N(i,k)
   60 CONTINUE
      T(nt)=N(nt,nt+1)/N(nt,nt)
      DO 100 i=1,nt-1
        m=nt-i
        DO 110 k=m+1,nt
  110    N(m,nt+1)=N(m,nt+1)-N(m,k)*T(k)
         T(m)=N(m,nt+1)/N(m,m)
  100   CONTINUE

      RETURN
      END



c matriz teste para o algoritmo de Cholesky
c a solução é 1, -4, 7
	
c	n(1,1) = 1
c      n(1,2) = -3
c	n(1,3) = 2
c	n(2,1) = -3
c	n(2,2) = 10
c	n(2,3) = -5
c	n(3,1) = 2
c	n(3,2) = -5
c	n(3,3) = 6

c	t(1) = 27
c	t(2) = -78
c	t(3) = 64










































