	FUNCTION MV_IE32  ( n, valin, valout )
C************************************************************************
C* MV_IE32								*
C*									*
C* This function converts an array of IBM 32-bit real numbers to	*
C* IEEE 32-bit real numbers.  The input and output arrays may be	*
C* the same.								*
C*									*
C* INTEGER MV_IE32  ( N, VALIN, VALOUT )				*
C*									*
C* Input parameters:							*
C*	N		INTEGER		Number of values to convert	*
C*	VALIN (N)	REAL		Input data			*
C*									*
C* Output parameters:							*
C*	VALOUT (N)	REAL		Converted data			*
C*	MV_IE32		INTEGER		Return code			*
C*					 0 = normal return		*
C*					>0 = # of invalid inputs	*
C**									*
C* Log:									*
C* R. Jones/NMC		07/90						*
C* K. Brill/NMC		02/91		Removed GOTO's; cleaned up	*
C************************************************************************
	INTEGER		valin (*), valout (*)
C*
	INTEGER		SIGN
C*
	DATA  		INFIN   / Z'7F800000' /
	DATA  		MASKFR  / Z'007FFFFF' /
	DATA  		MASKSN  / Z'7FFFFFFF' /
	DATA  		MASK21  / Z'00200000' /
	DATA  		MASK22  / Z'00400000' /
	DATA  		MASK23  / Z'00800000' /
	DATA  		SIGN    / Z'80000000' /
C-----------------------------------------------------------------------
	MV_IE32 = 0
C*
	DO  i = 1, n
	    isign = 0
	    itemp = valin (i)
C
C*	    Test the sign bit.
C
	    IF  ( itemp .eq. 0 )  THEN 
C
C*		Set underflow value to zero.
C
		valout (i)   =  0
	      ELSE 
C*
		IF ( itemp .lt. 0 ) THEN 
C*
 		    isign = SIGN
C
C*		    Set the sign bit to zero.
C
		    itemp = IAND ( itemp, MASKSN )
		END IF
C
C*		Convert IBM exponent to IEEE exponent.
C
		ieeexp = (ISHFT ( itemp, -24) - 64) * 4 + 126
C*
		k = 0
C
C*		Test bits 23, 22 and 21.
C*		Find number of zero bits in front of ibm370 fraction.
C
		it23 = IAND ( itemp, MASK23 )
		it22 = IAND ( itemp, MASK22 )
		it21 = IAND ( itemp, MASK21 )
		IF ( it23 .eq. 0 ) k = k + 1
		IF ( it23 .eq. 0 .and. it22 .eq. 0 ) k = k + 1
		IF ( ( it23 .eq. 0 .and. it22 .eq. 0 ) .and.
     +		     it21 .eq. 0 ) k = k + 1
C
C*		subtract zero bits from exponent
C
		ieeexp = ieeexp - k
C
C*		Test for overflow.
C
		IF ( ieeexp .gt. 254 )	THEN
C
C*		    If overflow, set output to ieee infinity; 
C*		    add 1 to overflow counter.
C
		    MV_IE32  = MV_IE32 + 1
		    valout (i) = IOR ( INFIN, isign )
C*
		  ELSE IF ( ieeexp .lt. 1 )  THEN
C
C*		    Underflow condition exists.
C
		    	    valout (i)   =  0
C*
		  ELSE
C
C*		    Shift ieee exponent to bits 1 to 8.
C
		    ltemp = ISHFT ( ieeexp, 23 )
C
C*		    Shift IBM fraction left K bits, masking out bits
C*		    0--8.  OR the exponent and fraction, and then OR
C*		    the result with the sign bit.
C
		    valout (i)  = IOR ( IOR ( IAND ( ISHFT
     +				  ( itemp, k ), MASKFR ), ltemp ),
     +				    isign )
C*
		END IF
	   END IF
	END DO
C*
	RETURN
	END
