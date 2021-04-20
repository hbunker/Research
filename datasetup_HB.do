*****************************************
***BUNKER AND CHEN
***GRAD SCHOOL EARNING PREMIUM VSP
******Updated: December 9, 2020
******************************************


***STATA SETUP****************************
cap log close
clear all
set more off
******************************************

***MACROS*********************************
*alter this dir if needed
*need subfolders called raw and code (where this file is)
local maindir ~/Documents/UCSD20-21/Econ250/VeryShortPaper
cd `maindir'

local raw `maindir'/raw
local code `maindir'/code
cap mkdir output
cap mkdir logs
local output `maindir'/output
local logs `maindir'/logs
******************************************
log using "`logs'/log_bc_1.log", replace

***DATA SETUP*****************************
use `raw'/bc_2.dta

***Gen variables
quietly{
	gen log_wage = ln(incwage)
	lab var log_wage "log of wage income"
	
	*education dummies
	gen grad_educ_dummy = (educ == 123 | educ == 124 | educ == 125)
	lab var grad_educ_dummy "indicator for graduate education"
	gen high_school_dummy = (educ == 73)
	lab var high_school_dummy "indicator for high school only"
	gen high_school_dropout = (educ < 73 & educ != 1)
	lab var high_school_dropout "less than high school"
	gen some_college = (educ > 73 & educ < 111)
	lab var some_college "Some college or AA degree"
	
	*years of experience
	gen years_school = .
	lab var years_school "Years of schooling"
	replace years_school = 11 if high_school_dropout == 1
	replace years_school = 12 if high_school_dummy == 1
	replace years_school = 14 if some_college == 1
	replace years_school = 16 if educ == 111 /*bachelors only*/
	replace years_school = 18 if educ == 123 /*Masters*/
	replace years_school = 19 if educ == 124 /*approx. MD, JD length at least for course work*/
	replace years_school = 21 if educ == 125 /*5 year PhD*/
	
	gen experience = .
	lab var experience "Total work experience"
	*replace for valid values of years of schooling
	*don't allow years of experience to be negative
	replace experience = max(age - 6 - years_school,0) if years_school !=.
	gen experience_sq = .
	replace experience_sq = experience^2 if experience !=.

	gen male = (sex == 1)
	lab var male "indicator for male"
	
	gen own_house = (ownershp == 10)
	lab var own_house "own or buying dwelling"
	
	gen lf_dummy = (empstat !=0 & empstat <30)
	lab var lf_dummy "Labor force dummy (includes military)"
	

	gen full_time_dummy = (wkstat == 10 | wkstat == 11 | wkstat == 14 | wkstat == 15)
	lab var full_time_dummy "full time worker for any reason"

	*hours worked
	gen hours = uhrsworkt 
	replace hours =. if (uhrsworkt == 997 | uhrsworkt == 999)
	lab var hours "cleaned hours worked for those working"


	***Race + ethnicity dummies
	gen black = (race == 200)
	lab var black "Black/African American"
	gen amer_indian = (race == 300)
	lab var amer_indian "Alaskan or American Indian"
	gen asian = (race == 650 | race == 651)
	lab var asian "Asian or Pacific Islander"
	gen hispan_dummy = .
	replace hispan_dummy = 1 if (hispan >= 100 & hispan < 900)
	replace hispan_dummy = 0 if (hispan == 0)
	lab var hispan_dummy "Hispanic status"

}
******************************************

***Summary Statistics
preserve

keep log_wage grad_educ_dummy male black hispan_dummy amer_indian asian age own_house nchild lf_dummy experience experience_sq hours full_time_dummy
sum *
eststo clear
estpost sum * if grad_educ_dummy == 1
disp "-----"
estpost sum * if grad_educ_dummy == 0
*esttab using sumstats_gradschool.tex, compress title(OLS results) nonumbers mtitles("Advanced Degree Holders" "Those without advanced degree")
esttab using sumstats_gradschool.tex, cells("mean(fmt(%8.2f))") tex replace
eststo clear


restore


save `output'/bc_cleaned.dta, replace
******************************************

log close
