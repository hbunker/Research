***MAIN FILE******************************

****************************************
***BUNKER AND CHEN
***GRAD SCHOOL EARNING PREMIUM VSP
***October, 2020
******************************************

***MACROS*********************************
*alter this dir if needed
*need subfolders called raw and code (where this file is)
local maindir ~/Documents/UCSD20-21/Econ250/VeryShortPaper
cd `maindir'
local raw `maindir'/raw
local code `maindir'/code
******************************************

***DO*************************************
*Setup
do `code'/datasetup_HB.do
*Analysis
do `code'/EstimationCommands_HB_11_11.do

*Plot
clear 
import excel `raw'/ma_attainment.xlsx, firstrow
lab var MA_Attain "Percent of US with Masters Degree or Above"
twoway scatter MA_Attain Year

