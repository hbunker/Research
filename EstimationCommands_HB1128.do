***ANALYSIS*******************************
***BUNKER AND CHEN
***GRAD SCHOOL EARNING PREMIUM VSP
***November  4,  2020
******************************************

***SETUP**********************************
cap log close
clear all

cap ssc install leebounds

******************************************

***MACROS*********************************
*alter this dir if needed
*need subfolders called raw and code (where this file is)
local maindir D:/Econ250_Labor_Economics_A/Main
cd `maindir'
local raw `maindir'/raw
local code `maindir'/code
cap mkdir output
cap mkdir logs
local output `maindir'/output
local logs `maindir'/logs
log using "`logs'/analysis.log", replace

*local X male black hispan_dummy asian amer_indian own_house
*baseline covariates
local X male black hispan_dummy asian amer_indian
*including experience
local W male black hispan_dummy asian amer_indian experience experience_sq
*unsure if we should include own_house because that seems endogeneous to earnings
*this makes bachelor degree holders the comparison group
local X_educ high_school_dummy high_school_dropout some_college
******************************************

***SWITCHES*******************************
local lee = 1
local heckit = 0
local ols = 0
******************************************


***PRELIM*******************************
*Open data
use `output'/bc_cleaned.dta
***Drop those not in labor force
drop if lf_dummy == 0 
*HB: I don't think this is the right variable: this drops all those who aren't employed

***Dummy for unemployed people***
gen unemployed_dummy = (empstat == 21 | empstat ==22)

replace incwage = . if unemployed_dummy == 1
replace log_wage = . if unemployed_dummy == 1
******************************************

***MODELS*********************************

if `lee' == 1{
***LEE BOUNDS*****************************

***The logic here is that we cannot observe wage if he/she is unemployed.***

***Overall effect with confidence interval***
leebounds log_wage grad_educ_dummy, cie
leebounds log_wage grad_educ_dummy, cie tight(male)
leebounds log_wage grad_educ_dummy, cie tight(male black amer_indian asian)
***I am not sure about the exact procedure, but I believe it's somewhat doing Lee-bound separately depending on male/female. Then take weighted-average.
***Also, we can add more category variables or dummies to make more cells.


*leebounds log_wage grad_educ_dummy, cie tight(`W') if year == 1997

***Effect in different years.***
local years 1997 2007 2017 2020
drop if high_school_dropout==1
drop if high_school_dummy==1
drop if some_college==1
foreach y of local years{
	display "--------------------------------------"
	display "Lee bounds for year `y'"
	preserve
	keep if year == `y'
	eststo: leebounds log_wage grad_educ_dummy, cie tight(male black amer_indian asian)
	restore
}
esttab using LeeBoundCollege.tex,se compress label title(Lee Bounds results) nonumbers mtitles("1997" "2007" "2017" "2020")
eststo clear
***My feeling is that they don't differ that much either with years being different or with more control variables.*** T
***HB: the values go down over time which matched my prior knowledge and intuition. The premium is shrinking.

******************************************
}

if `heckit' == 1{
	***HECKIT*********************************
	***If you wanna do heckit.***
	local years 1997 2007 2017 2020
	foreach y of local years{
		display "--------------------------------------"
		display "Heckit for year `y'"
		eststo: heckman log_wage grad_educ_dummy `W' `X_educ', select(grad_educ_dummy male black amer_indian asian), if year == `y'
	}
*esttab using HeckModel.tex,se compress label title(Heck Selection Model results) nonumbers mtitles("1997" "2007" "2017" "2020")
*eststo clear
	***Feel free to change the specification. I know it's somewhat flawed since I uese exactly the same explanatory variables in the two stages.
	***The effect is somewhere between the Lee interval, as projected. In the second stage, interestingly, we observe positive coefficient of male, suggesting somewhat wage discrimination here. Also, the coefficient of own_house is also positive. I am not sure whether there is reverse-casuality here since some people buy houses since they are richer.
	***I don't have a good explanation for those race variables.
	***Point estimation of return of graduate eduation is falling as time goes by. It's somewhat reasonable since more and more people get into graduate school.

	******************************************
}

if `ols' == 1{
	*local X male black hispan_dummy asian amer_indian own_house
	*local W male black hispan_dummy asian amer_indian
	*unsure if we should include own_house because that seems endogeneous to earnings
	*this makes bachelor degree holders the comparison group
	*local X_educ high_school_dummy high_school_dropout some_college

	***OLS************************************
	*sum `X'
	local years 1997 2007 2017 2020
		foreach y of local years{
		disp "OLS Results for Year `y'"
		reg log_wage grad_educ_dummy `X' `X_educ' if year == `y', r 

		disp "With experience"
		eststo: reg log_wage grad_educ_dummy `W' `X_educ' if year == `y', r
		disp "---"
	}
esttab using OLS.tex,se compress label title(OLS results) nonumbers mtitles("1997" "2007" "2017" "2020")
eststo clear

	disp "With time trends"
	reg log_wage grad_educ_dummy i.year `W' `X_educ', r 

	***Here the coefficient on grad_educ_dummy is 0.825, whereas the coefficient is smaller, 0.77, in Heckman model. I would say this results from a positive selection effect. That is, when people receive graduate education, they are more likely to be employed and hence be observed.

	***There's a little problem : many "employed" individual have income 0. I don't know what happened here like working for no money. But I would say we probably can ignore it. The direction of effects are basically what we expected.
	******************************************
	}

******************************************
*TODO:
*need to dump output in LaTex
*Want graphs of coefficients over time with bounds
*full regression (triangle) tables at least for the full specification maybe with time dummies

***END PROGRAM****************************
cap log close
******************************************
