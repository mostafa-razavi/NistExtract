# NistExtract
A wrapper to extract data from NIST Webbook database for a given compound
How to run:

	$sh NistExtractor.sh casn type (constant) low increment high
	
Arguments:

	casn:	CASN

	type:	IT for	Isotherm
		IB for	Isobar
		IC for	Isochore
		SP for  Satration properties - temperature increment
		ST for  Satration properties - pressure increment 

	constant:
		IT: Temperature
		IB: Pressure
		IC: Density
		SP: NA
		ST: NA

	low increment high:
		IT: P-low P-inc P-high
		IB: T-low T-inc T-high
		IC: T-low T-inc T-high
		SP: T-low T-inc T-high
		ST: P-low P-inc P-high

For example:

	$sh NistExtract.sh 74-82-8 IT 100 0.0 1 10

Output: 

NistExtractor outputs a CSV file in the current directory containing downloaded information about the requested conpound at specified conditions.
