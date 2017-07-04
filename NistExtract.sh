#!bin/sh
casn=$1
type=$2
const=$3
low=$4
inc=$5
high=$6

if [ "$1" = "man" ]; then
echo '
How to use:

	$bash NistExtractor.sh casn type (constant) low increment high
	
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

Example:

	$bash NistExtract.sh 74-82-8 IT 100 0.0 1 10
'
exit
fi

TUnit="K"		#	K	C	F	R 	
PUnit="MPa"		#	MPa	bar	atm	torr	psia	
DUnit="g%2Fml"		#	mol%2Fl	mol%2Fm3	g%2Fml	kg%2Fm3	lb-mole%2Fft3	lbm%2Fft3
HUnit="kcal%2Fmol"	#	kJ%2Fmol	kJ%2Fkg	kcal%2Fmol	Btu%2Flb-mole	kcal%2Fg	Btu%2Flbm
WUnit="m%2Fs"		#	m%2Fs	ft%2Fs	mph			
VisUnit="uPa*s"		#	uPa*s	Pa*s	cP	lbm%2Fft*s		
STUnit="N%2Fm"		#	N%2Fm	dyn%2Fcm	lb%2Fft	lb%2Fin	


findLimitsOfIsoTherm () {
rangeT=$(awk -v var="<input type=\"text\" name=\"T\" /> (Acceptable range:" '$0 == var {j=1;next};j && j++ <= 1' temp.txt)"\t" 
minT=$(echo $rangeT| cut -d " " -f 1)
#echo $minT
maxT=$(echo $rangeT| cut -d " " -f 3)
#echo $maxT
minP=$(awk '/min value:/ {print $3}' temp.txt)
#echo $minP
maxP=$(awk -v var="<ul>" '$0 == var {j=1;next};j && j++ <= 1' temp.txt)"\t" 
maxP=$(echo $maxP| cut -d " " -f 2)
#echo $maxP

}



findLimitsOfIsoBar () {
rangeP=$(awk -v var="<input type=\"text\" name=\"P\" /> (Acceptable range:" '$0 == var {j=1;next};j && j++ <= 1' temp.txt)"\t" 
#echo $rangeP
minP=$(echo $rangeP| cut -d " " -f 1)
#echo $minP
maxP=$(echo $rangeP| cut -d " " -f 3)
#echo $maxP
maxT=$(awk '/max value:/ {print $3}' temp.txt)
#echo $maxT
minT=$(awk -v var="<ul>" '$0 == var {j=1;next};j && j++ <= 1' temp.txt)"\t" 
minT=$(echo $minT| cut -d " " -f 2)
#echo $minT

}

findLimitsOfIsoChor () {
rangeD=$(awk -v var="<input type=\"text\" name=\"D\" /> (Acceptable range:" '$0 == var {j=1;next};j && j++ <= 1' temp.txt)"\t" 
minD=$(echo $rangeD| cut -d " " -f 1)
#echo $minD
maxD=$(echo $rangeD| cut -d " " -f 3)
#echo $maxD
maxT=$(awk '/max value:/ {print $3}' temp.txt)
#echo $maxT
minT=$(awk -v var="<ul>" '$0 == var {j=1;next};j && j++ <= 1' temp.txt)"\t" 
minT=$(echo $minT| cut -d " " -f 2)
#echo $minT

}

findLimitsOfSatP () {
minT=$(awk '/min value:/ {print $3}' temp.txt)
#echo $minT
maxT=$(awk '/max value:/ {print $3}' temp.txt)
#echo $maxT

}

findLimitsOfSatT () {
minP=$(awk '/min value:/ {print $3}' temp.txt)
#echo $minP
maxP=$(awk '/max value:/ {print $3}' temp.txt)
#echo $maxP

}


ID=$(echo "C""$casn" | tr -d -)

if [ "$type" = "IT" ] ; then
	Type="IsoTherm"
elif [ "$type" = "IB" ] ; then
	Type="IsoBar"
elif [ "$type" = "IC" ] ; then
	Type="IsoChor" 
elif [ "$type" = "SP" ] ; then
	Type="SatP"
elif [ "$type" = "ST" ] ; then
	Type="SatT"
fi

Wide="on"
Digits="5"
RefState="DEF"

Action="Page"
a0="http://webbook.nist.gov/cgi/fluid.cgi?"
a1="Action=$Action&Wide=$Wide&ID=$ID&Type=$Type&Digits=$Digits&RefState=$RefState"
a2="&TUnit=$TUnit&PUnit=$PUnit&DUnit=$DUnit&HUnit=$HUnit&WUnit=$WUnit&VisUnit=$VisUnit&STUnit=$STUnit"
wget -q "$a0$a1$a2" -O temp.txt

if [ "$type" = "IT" ] ; then
	echo "IT option was selcted"
	Type="IsoTherm"
	PHigh=$high
	PLow=$low
	PInc=$inc
	T=$const
	findLimitsOfIsoTherm
	if [ $(echo $T'<'$minT | bc -l) -eq 1 ] || [ $(echo $T'>'$maxT | bc -l) -eq 1  ]; then
		echo "Temperature is out of ranage "
		echo "Accepable temperature range:\t $minT to $maxT $TUnit"
		echo "Accepable pressure range:\t $minP to $maxP $PUnit" 
		rm temp.txt
		echo "Exiting..."
		exit
	fi
	if [ $(echo $PHigh'<'$minP | bc -l) -eq 1 ] || [ $(echo $PHigh'>'$maxP | bc -l) -eq 1  ] || [ $(echo $PLow'<'$minP | bc -l) -eq 1 ] || [ $(echo $PLow'>'$maxP | bc -l) -eq 1  ] || [ $(echo $PInc'>'$maxP | bc -l) -eq 1  ]; then
		echo "Temperature is out of ranage "
		echo "Accepable temperature range:\t $minT to $maxT $TUnit"
		echo "Accepable pressure range:\t $minP to $maxP $PUnit" 
		rm temp.txt
		echo "Exiting..."
		exit
	fi
Action="Data"
a1="Action=$Action&Wide=$Wide&ID=$ID&Type=$Type&Digits=$Digits&RefState=$RefState"
a3="&PHigh=$PHigh&PLow=$PLow&PInc=$PInc&THigh=$THigh&TLow=$TLow&TInc=$TInc&T=$T&P=$P&D=$D"
wget -q "$a0$a1$a2$a3" -O $1_$2_$3${TUnit}_$4${PUnit}_$5${PUnit}_$6${PUnit}.csv
cat $1_$2_$3${TUnit}_$4${PUnit}_$5${PUnit}_$6${PUnit}.csv
echo
echo "Data was successfully saved in "$1_$2_$3${TUnit}_$4${PUnit}_$5${PUnit}_$6${PUnit}.csv

elif [ "$type" = "IB" ] ; then
	echo "IB option was selcted"
	Type="IsoBar"
	THigh=$high	
	TLow=$low
	TInc=$inc
	P=$const
	findLimitsOfIsoBar
	if [ $(echo $P'<'$minP | bc -l) -eq 1 ] || [ $(echo $P'>'$maxP | bc -l) -eq 1  ]; then
		echo "Pressure is out of ranage "
		echo "Accepable temperature range:\t $minT to $maxT $TUnit"
		echo "Accepable pressure range:\t $minP to $maxP $PUnit" 
		rm temp.txt
		echo "Exiting..."
		exit
	fi
	if [ $(echo $THigh'<'$minT | bc -l) -eq 1 ] || [ $(echo $THigh'>'$maxT | bc -l) -eq 1  ] || [ $(echo $TLow'<'$minT | bc -l) -eq 1 ] || [ $(echo $TLow'>'$maxT | bc -l) -eq 1  ] || [ $(echo $TInc'>'$maxT | bc -l) -eq 1  ]; then
		echo "Temperature is out of ranage "
		echo "Accepable temperature range:\t $minT to $maxT $TUnit"
		echo "Accepable pressure range:\t $minP to $maxP $PUnit" 
		rm temp.txt
		echo "Exiting..."
		exit
	fi
Action="Data"
a1="Action=$Action&Wide=$Wide&ID=$ID&Type=$Type&Digits=$Digits&RefState=$RefState"
a3="&PHigh=$PHigh&PLow=$PLow&PInc=$PInc&THigh=$THigh&TLow=$TLow&TInc=$TInc&T=$T&P=$P&D=$D"
wget -q "$a0$a1$a2$a3" -O $1_$2_$3${PUnit}_$4${TUnit}_$5${TUnit}_$6${TUnit}.csv
cat $1_$2_$3${PUnit}_$4${TUnit}_$5${TUnit}_$6${TUnit}.csv
echo
echo "Data was successfully saved in "$1_$2_$3${PUnit}_$4${PUnit}_$5${PUnit}.csv

elif [ "$type" = "IC" ] ; then
	echo "IC option was selcted"
	Type="IsoChor"
	THigh=$high	
	TLow=$low
	TInc=$inc
	D=$const
	findLimitsOfIsoChor
	if [ $(echo $D'<'$minD | bc -l) -eq 1 ] || [ $(echo $D'>'$maxD | bc -l) -eq 1  ]; then
		echo "Pressure is out of ranage "
		echo "Accepable temperature range:\t $minT to $maxT $TUnit"
		echo "Accepable density range:\t $minD to $maxD $DUnit" 
		rm temp.txt
		echo "Exiting..."
		exit
	fi
	if [ $(echo $THigh'<'$minT | bc -l) -eq 1 ] || [ $(echo $THigh'>'$maxT | bc -l) -eq 1  ] || [ $(echo $TLow'<'$minT | bc -l) -eq 1 ] || [ $(echo $TLow'>'$maxT | bc -l) -eq 1  ] || [ $(echo $TInc'>'$maxT | bc -l) -eq 1  ]; then
		echo "Temperature is out of ranage "
		echo "Accepable temperature range:\t $minT to $maxT $TUnit"
		echo "Accepable density range:\t $minD to $maxD $DUnit" 
		rm temp.txt
		echo "Exiting..."
		exit
	fi 
Action="Data"
a1="Action=$Action&Wide=$Wide&ID=$ID&Type=$Type&Digits=$Digits&RefState=$RefState"
a3="&PHigh=$PHigh&PLow=$PLow&PInc=$PInc&THigh=$THigh&TLow=$TLow&TInc=$TInc&T=$T&P=$P&D=$D"
wget -q "$a0$a1$a2$a3" -O $1_$2_$3${DUnit}_$4${TUnit}_$5${TUnit}_$6${TUnit}.csv
cat $1_$2_$3${PUnit}_$4${PUnit}_$5${PUnit}.csv
echo "Data was successfully saved in "$1_$2_$3${PUnit}_$4${PUnit}_$5${PUnit}.csv

elif [ "$type" = "SP" ] ; then
	echo "SP option was selcted"
	Type="SatP"

	low=$3
	inc=$4
	high=$5

	THigh=$high	
	TLow=$low
	TInc=$inc
	findLimitsOfSatP
	if [ $(echo $THigh'<'$minT | bc -l) -eq 1 ] || [ $(echo $THigh'>'$maxT | bc -l) -eq 1  ] || [ $(echo $TLow'<'$minT | bc -l) -eq 1 ] || [ $(echo $TLow'>'$maxT | bc -l) -eq 1  ] || [ $(echo $TInc'>'$maxT | bc -l) -eq 1  ]; then
		echo "Temperature is out of ranage "
		echo "Accepable temperature range:\t $minT to $maxT $TUnit"
		rm temp.txt
		echo "Exiting..."
		exit
	fi 
Action="Data"
a1="Action=$Action&Wide=$Wide&ID=$ID&Type=$Type&Digits=$Digits&RefState=$RefState"
a3="&PHigh=$PHigh&PLow=$PLow&PInc=$PInc&THigh=$THigh&TLow=$TLow&TInc=$TInc&T=$T&P=$P&D=$D"
wget -q "$a0$a1$a2$a3" -O $1_$2_$3${TUnit}_$4${TUnit}_$5${TUnit}.csv
cat $1_$2_$3${TUnit}_$4${TUnit}_$5${TUnit}.csv
echo
echo "Data was successfully saved in "$1_$2_$3${PUnit}_$4${PUnit}_$5${PUnit}.csv

elif [ "$type" = "ST" ] ; then
	echo "ST option was selcted"
	Type="SatT"

	low=$3
	inc=$4
	high=$5

	PHigh=$high	
	PLow=$low
	PInc=$inc
	findLimitsOfSatT
	if [ $(echo $PHigh'<'$minP | bc -l) -eq 1 ] || [ $(echo $PHigh'>'$maxP | bc -l) -eq 1  ] || [ $(echo $PLow'<'$minP | bc -l) -eq 1 ] || [ $(echo $PLow'>'$maxP | bc -l) -eq 1  ] || [ $(echo $PInc'>'$maxP | bc -l) -eq 1  ]; then
		echo "Pressure is out of ranage "
		echo "Accepable pressure range:\t $minP to $maxP $PUnit" 
		rm temp.txt
		echo "Exiting..."
		exit
	fi
Action="Data"
a1="Action=$Action&Wide=$Wide&ID=$ID&Type=$Type&Digits=$Digits&RefState=$RefState"
a3="&PHigh=$PHigh&PLow=$PLow&PInc=$PInc&THigh=$THigh&TLow=$TLow&TInc=$TInc&T=$T&P=$P&D=$D"
wget -q "$a0$a1$a2$a3" -O $1_$2_$3${PUnit}_$4${PUnit}_$5${PUnit}.csv
cat $1_$2_$3${PUnit}_$4${PUnit}_$5${PUnit}.csv
echo
echo "Data was successfully saved in "$1_$2_$3${PUnit}_$4${PUnit}_$5${PUnit}.csv

fi


rm temp.txt





