// Load Dataset
import delimited "/Users/andyxin/Desktop/ECON135/FinalProject/ipeds.csv", clear

save "/Users/andyxin/Desktop/ECON135/FinalProject/ipeds.dta", replace

use "/Users/andyxin/Desktop/ECON135/FinalProject/ipeds.dta", clear

describe

// Rename Variables. Used AI to assist, ensure truncated variable names match intended ones.

* applicants
rename applcnadm2024    applicants2024
rename applcnadm2023~v  applicants2023
rename applcnadm2022~v  applicants2022
rename applcnadm2021~v  applicants2021
rename applcnadm2020~v  applicants2020
rename applcnadm2019~v  applicants2019
rename applcnadm2018~v  applicants2018
rename applcnadm2017~v  applicants2017
rename applcnadm2016~v  applicants2016
rename applcnadm2015~v  applicants2015

* admits
rename admssnadm2024    admits2024
rename admssnadm2023~v  admits2023
rename admssnadm2022~v  admits2022
rename admssnadm2021~v  admits2021
rename admssnadm2020~v  admits2020
rename admssnadm2019~v  admits2019
rename admssnadm2018~v  admits2018
rename admssnadm2017~v  admits2017
rename admssnadm2016~v  admits2016
rename admssnadm2015~v  admits2015

* enrolled
rename enrltadm2024     enrolled2024
rename enrltadm2023_rv  enrolled2023
rename enrltadm2022_rv  enrolled2022
rename enrltadm2021_rv  enrolled2021
rename enrltadm2020_rv  enrolled2020
rename enrltadm2019_rv  enrolled2019
rename enrltadm2018_rv  enrolled2018
rename enrltadm2017_rv  enrolled2017
rename enrltadm2016_rv  enrolled2016
rename enrltadm2015_rv  enrolled2015

* SAT math 75th
rename satmt75adm2024   sat_math2024
rename satmt75adm~3_rv  sat_math2023
rename satmt75adm~2_rv  sat_math2022
rename satmt75adm~1_rv  sat_math2021
rename satmt75adm~0_rv  sat_math2020
rename satmt75adm~9_rv  sat_math2019
rename satmt75adm~8_rv  sat_math2018
rename satmt75adm~7_rv  sat_math2017
rename satmt75adm~6_rv  sat_math2016
rename satmt75adm~5_rv  sat_math2015

* SAT verbal 75th
rename satvr75adm2024   sat_verbal2024
rename satvr75adm~3_rv  sat_verbal2023
rename satvr75adm~2_rv  sat_verbal2022
rename satvr75adm~1_rv  sat_verbal2021
rename satvr75adm~0_rv  sat_verbal2020
rename satvr75adm~9_rv  sat_verbal2019
rename satvr75adm~8_rv  sat_verbal2018
rename satvr75adm~7_rv  sat_verbal2017
rename satvr75adm~6_rv  sat_verbal2016
rename satvr75adm~5_rv  sat_verbal2015

* tuition (total price, out-of-state on campus)
rename cotsondrvc~2024  tuition2024
rename cotsondrvic2023  tuition2023
rename cotsondrvic2022  tuition2022
rename cotsondrvic2021  tuition2021
rename cotsondrvic2020  tuition2020
rename cotsondrvic2019  tuition2019
rename cotsondrvic2018  tuition2018
rename cotsondrvic2017  tuition2017
rename cotsondrvic2016  tuition2016
rename cotsondrvic2015  tuition2015

* retention rate
rename ret_pcfef2024d   retention2024
rename ret_pcfef2023~v  retention2023
rename ret_pcfef2022~v  retention2022
rename ret_pcfef2021~v  retention2021
rename ret_pcfef2020~v  retention2020
rename ret_pcfef2019~v  retention2019
rename ret_pcfef2018~v  retention2018
rename ret_pcfef2017~v  retention2017
rename ret_pcfef2016~v  retention2016
rename ret_pcfef2015~v  retention2015

* student-to-faculty ratio
rename stufacref2024d   student_faculty_ratio2024
rename stufacref2023~v  student_faculty_ratio2023
rename stufacref2022~v  student_faculty_ratio2022
rename stufacref2021~v  student_faculty_ratio2021
rename stufacref2020~v  student_faculty_ratio2020
rename stufacref2019~v  student_faculty_ratio2019
rename stufacref2018~v  student_faculty_ratio2018
rename stufacref2017~v  student_faculty_ratio2017
rename stufacref2016~v  student_faculty_ratio2016
rename stufacref2015~v  student_faculty_ratio2015

* % financial aid (2015-2023, no 2024)
rename uagrntpsfa2324   pct_finaid2023
rename uagrntpsfa222~v  pct_finaid2022
rename uagrntpsfa212~v  pct_finaid2021
rename uagrntpsfa202~v  pct_finaid2020
rename uagrntpsfa192~v  pct_finaid2019
rename uagrntpsfa181~v  pct_finaid2018
rename uagrntpsfa171~v  pct_finaid2017
rename uagrntpsfa161~v  pct_finaid2016
rename uagrntpsfa151~v  pct_finaid2015

rename institutionname school

// Reshape long
reshape long ///
    applicants admits enrolled ///
    sat_math sat_verbal tuition retention ///
    student_faculty_ratio pct_finaid, ///
    i(unitid school) j(year)

// Combine some variables to find acceptance & yield rate, sum SAT scores
gen acceptance_rate = admits / applicants
gen yield_rate      = enrolled / admits
gen sat75 = sat_math + sat_verbal

// Drop Unnecessary Variables
drop admits
drop enrolled
drop sat_math
drop sat_verbal

save "/Users/andyxin/Desktop/ECON135/FinalProject/ipeds.dta", replace

import excel using "/Users/andyxin/Desktop/ECON135/FinalProject/d3schools.xlsx", firstrow clear

save "/Users/andyxin/Desktop/ECON135/FinalProject/d3schools.dta", replace

use "/Users/andyxin/Desktop/ECON135/FinalProject/ipeds.dta"

merge m:1 school using "/Users/andyxin/Desktop/ECON135/FinalProject/d3schools.dta"

keep if _merge == 3
drop _merge

save "/Users/andyxin/Desktop/ECON135/FinalProject/d3_ipeds.dta", replace

use "/Users/andyxin/Desktop/ECON135/FinalProject/d3_ipeds.dta", clear

// Drop unused U St. Thomas (moved to DII)
drop if unitid == 174914

// Rename some schools

replace school = "Westminster College (Pennsylvania)" if unitid == 216807
replace school = "Westminster College (Missouri)" if unitid == 179946

replace school = "Penn State Abington" if unitid == 214801
replace school = "Penn State Altoona" if unitid == 214689
replace school = "Penn State Berks" if unitid == 214704
replace school = "Penn State Brandywine" if unitid == 214731
replace school = "Penn State Behrend" if unitid == 214591
replace school = "Penn State Harrisburg" if unitid == 214713
replace school = "Penn College" if unitid == 366252

replace school = "SUNY Cortland" if unitid == 196149
replace school = "SUNY New Paltz" if unitid == 196176
replace school = "SUNY Oswego" if unitid == 196194
replace school = "SUNY Plattsburgh" if unitid == 196246
replace school = "Wheaton College (Illinois)" if unitid == 149781

replace school = "SUNY Canton" if unitid == 196015
replace school = "SUNY Delhi" if unitid == 196024
replace school = "SUNY Cobleskill" if unitid == 196033
replace school = "SUNY Geneseo" if unitid == 196167
replace school = "SUNY Potsdam" if unitid == 196200

drop B
drop C
drop D
drop E
drop F

save "/Users/andyxin/Desktop/ECON135/FinalProject/d3_ipeds.dta", replace

// Used AI to help with rapidfuzz matching on school names in Python. After manually checking, I merged sport data with ipeds

import delimited "/Users/andyxin/Desktop/ECON135/FinalProject/d3_ipeds_with_sports.csv", clear

save "/Users/andyxin/Desktop/ECON135/FinalProject/d3_ipeds_with_sports.dta", replace

use "/Users/andyxin/Desktop/ECON135/FinalProject/d3_ipeds_with_sports.dta", clear

// Replace missing values = 0 (team did not qualify)

foreach v of varlist baseball_confchamp baseball_ncaa ///
                     softball_confchamp softball_ncaa ///
                     mbb_confchamp mbb_ncaa ///
                     wbb_confchamp wbb_ncaa ///
                     mlax_confchamp mlax_ncaa ///
                     wlax_confchamp wlax_ncaa ///
                     msoc_confchamp msoc_ncaa ///
                     wsoc_confchamp wsoc_ncaa {
	replace `v' = 0 if missing(`v')
}
	
// Create lagged athletics success variables

// Specify structure

xtset unitid year

// Conference Championships
gen baseball_confchamp_lag = L2.baseball_confchamp
gen mbb_confchamp_lag      = L2.mbb_confchamp
gen mlax_confchamp_lag     = L2.mlax_confchamp
gen msoc_confchamp_lag     = L2.msoc_confchamp
gen softball_confchamp_lag = L2.softball_confchamp
gen wbb_confchamp_lag      = L2.wbb_confchamp
gen wlax_confchamp_lag     = L2.wlax_confchamp
gen wsoc_confchamp_lag     = L2.wsoc_confchamp

// NCAA Tournament Appearances
gen baseball_ncaa_lag = L2.baseball_ncaa
gen mbb_ncaa_lag      = L2.mbb_ncaa
gen mlax_ncaa_lag     = L2.mlax_ncaa
gen msoc_ncaa_lag     = L2.msoc_ncaa
gen softball_ncaa_lag = L2.softball_ncaa
gen wbb_ncaa_lag      = L2.wbb_ncaa
gen wlax_ncaa_lag     = L2.wlax_ncaa
gen wsoc_ncaa_lag     = L2.wsoc_ncaa

save "/Users/andyxin/Desktop/ECON135/FinalProject/d3_ipeds_with_sports.dta", replace

// Merge Spending (Revenue and CSV)

import delimited "/Users/andyxin/Desktop/ECON135/FinalProject/expenses.csv", clear
drop school
save "/Users/andyxin/Desktop/ECON135/FinalProject/expenses.dta", replace

use "/Users/andyxin/Desktop/ECON135/FinalProject/d3_ipeds_with_sports.dta", clear

merge 1:1 unitid year using "/Users/andyxin/Desktop/ECON135/FinalProject/expenses.dta"
drop _merge

// Lag Expenses

xtset unitid year

gen baseball_expenses_lag = L2.baseball_expenses
gen mbb_expenses_lag      = L2.mbb_expenses
gen mlax_expenses_lag     = L2.mlax_expenses
gen msoc_expenses_lag     = L2.msoc_expenses
gen softball_expenses_lag = L2.softball_expenses
gen wbb_expenses_lag      = L2.wbb_expenses
gen wlax_expenses_lag     = L2.wlax_expenses
gen wsoc_expenses_lag     = L2.wsoc_expenses

// Create variables for a school having any team win/qualify

gen any_confchamp_lag = (baseball_confchamp_lag == 1 | ///
                         mbb_confchamp_lag == 1      | ///
                         mlax_confchamp_lag == 1     | ///
                         msoc_confchamp_lag == 1     | ///
                         softball_confchamp_lag == 1 | ///
                         wbb_confchamp_lag == 1      | ///
                         wlax_confchamp_lag == 1     | ///
                         wsoc_confchamp_lag == 1)    ///
                         if !missing(mbb_confchamp_lag)

gen any_ncaa_lag = (baseball_ncaa_lag == 1 | ///
                    mbb_ncaa_lag == 1      | ///
                    mlax_ncaa_lag == 1     | ///
                    msoc_ncaa_lag == 1     | ///
                    softball_ncaa_lag == 1 | ///
                    wbb_ncaa_lag == 1      | ///
                    wlax_ncaa_lag == 1     | ///
                    wsoc_ncaa_lag == 1)    ///
                    if !missing(mbb_ncaa_lag)
					
gen any_confchamp = (baseball_confchamp == 1 | ///
                         mbb_confchamp == 1      | ///
                         mlax_confchamp == 1     | ///
                         msoc_confchamp == 1     | ///
                         softball_confchamp == 1 | ///
                         wbb_confchamp == 1      | ///
                         wlax_confchamp == 1     | ///
                         wsoc_confchamp == 1)

gen any_ncaa = (baseball_ncaa == 1 | ///
                    mbb_ncaa == 1      | ///
                    mlax_ncaa == 1     | ///
                    msoc_ncaa == 1     | ///
                    softball_ncaa == 1 | ///
                    wbb_ncaa == 1      | ///
                    wlax_ncaa == 1     | ///
                    wsoc_ncaa == 1)
					
// Adjust tuition for inflation
gen cpi = .
replace cpi = 233.0 if year == 2013
replace cpi = 236.7 if year == 2014
replace cpi = 237.0 if year == 2015
replace cpi = 240.0 if year == 2016
replace cpi = 245.1 if year == 2017
replace cpi = 251.1 if year == 2018
replace cpi = 255.7 if year == 2019
replace cpi = 258.8 if year == 2020
replace cpi = 271.0 if year == 2021
replace cpi = 292.7 if year == 2022
replace cpi = 304.7 if year == 2023
replace cpi = 313.7 if year == 2024

gen tuition_adj = tuition * (255.7 / cpi)
gen ln_tuition_adj = ln(tuition_adj)

gen ln_applicants = ln(applicants)

save "/Users/andyxin/Desktop/ECON135/FinalProject/d3_ipeds_with_sports.dta", replace

// Pre-Trends Analysis (Yield Rate)
did_multiplegt_dyn yield_rate unitid year any_ncaa_lag, ///
    effects(3) placebo(3) ///
    cluster(unitid)
	
graph save "Graph" "/Users/andyxin/Desktop/ECON135/FinalProject/pretrendsyield.gph", replace
graph use "/Users/andyxin/Desktop/ECON135/FinalProject/pretrendsyield.gph"
graph export "/Users/andyxin/Desktop/ECON135/FinalProject/pretrendsyield.png", replace

// Pre-Trends Analysis (Applicants)

did_multiplegt_dyn applicants unitid year any_ncaa_lag, ///
    effects(3) placebo(3) ///
    cluster(unitid)
	
graph save "Graph" "/Users/andyxin/Desktop/ECON135/FinalProject/pretrendsapplicants.gph", replace
graph use "/Users/andyxin/Desktop/ECON135/FinalProject/pretrendsapplicants.gph"
graph export "/Users/andyxin/Desktop/ECON135/FinalProject/pretrendsapplicants.png", replace

// Summary Statistics

estpost summarize yield_rate acceptance_rate applicants tuition_adj retention student_faculty_ratio pct_finaid sat75
esttab using "/Users/andyxin/Desktop/ECON135/FinalProject/admission_summary.tex", ///
cells("mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
title("Summary Statistics: Academics and Admissions") replace

// Performance Data

preserve

keep if year >= 2013 & year <= 2022

// School-Level
bys unitid year: egen conf_any = max(any_confchamp)
bys unitid year: egen ncaa_any = max(any_ncaa)
keep unitid year conf_any ncaa_any
duplicates drop

// Collapse sums

collapse (sum) conf_any ncaa_any (count) unitid, by(year)
rename conf_any n_conf
rename ncaa_any n_ncaa
rename unitid n_schools

// Create pct

gen pct_conf = 100 * n_conf / n_schools
gen pct_ncaa = 100 * n_ncaa / n_schools
list year n_schools pct_conf pct_ncaa

// Summary Table
estpost summarize pct_conf pct_ncaa if year >= 2013 & year <= 2022

esttab using "/Users/andyxin/Desktop/ECON135/FinalProject/athletic_summary.tex", ///
    replace ///
    title("Percent of Schools with Athletic Success per Year") ///
	cells("mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
    label

restore

// Baseline DiD Regressions

preserve

// Canonical

reghdfe yield_rate any_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store base_did_yield

reghdfe ln_applicants any_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store base_did_applicants

// C + H

did_multiplegt_stat yield_rate unitid year any_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)

did_multiplegt_stat ln_applicants unitid year any_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
	
restore
	
// Regression tables were not compiling so I asked AI to write up the table (in LaTeX) given the regression results. This goes for all did_multiplegt_stat regressions as well.

// Regressions by Sport

preserve

// Baseball
reghdfe yield_rate baseball_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store yield_baseball

// Men's Basketball
reghdfe yield_rate mbb_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store yield_mbb

// Men's Lacrosse
reghdfe yield_rate mlax_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store yield_mlax

// Men's Soccer
reghdfe yield_rate msoc_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store yield_msoc

// Softball
reghdfe yield_rate softball_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store yield_softball

// Women's Basketball
reghdfe yield_rate wbb_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store yield_wbb

// Women's Lacrosse
reghdfe yield_rate wlax_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store yield_wlax

// Women's Soccer
reghdfe yield_rate wsoc_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store yield_wsoc

esttab yield_baseball yield_mbb yield_mlax yield_msoc yield_softball yield_wbb yield_wlax yield_wsoc ///
    using "/Users/andyxin/Desktop/ECON135/FinalProject/base_yield_sport.tex", ///
    title("Regression of Yield Rate on Treatment by Sport (Canonical)") ///
    keep(*_ncaa_lag) ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    b(4) se(4) ///
    scalars("N Observations" "r2 R-squared") ///
    label replace booktabs

restore

// CH Yield Rate by Sport

preserve

did_multiplegt_stat yield_rate unitid year baseball_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
matrix AS = e(AS)
scalar cdh_yield_baseball_coef = AS[1,1]
scalar cdh_yield_baseball_se   = AS[1,2]
scalar cdh_yield_baseball_n    = e(N)

did_multiplegt_stat yield_rate unitid year mbb_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
matrix AS = e(AS)
scalar cdh_yield_mbb_coef = AS[1,1]
scalar cdh_yield_mbb_se   = AS[1,2]
scalar cdh_yield_mbb_n    = e(N)

did_multiplegt_stat yield_rate unitid year mlax_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
matrix AS = e(AS)
scalar cdh_yield_mlax_coef = AS[1,1]
scalar cdh_yield_mlax_se   = AS[1,2]
scalar cdh_yield_mlax_n    = e(N)

did_multiplegt_stat yield_rate unitid year msoc_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
matrix AS = e(AS)
scalar cdh_yield_msoc_coef = AS[1,1]
scalar cdh_yield_msoc_se   = AS[1,2]
scalar cdh_yield_msoc_n    = e(N)

did_multiplegt_stat yield_rate unitid year softball_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
matrix AS = e(AS)
scalar cdh_yield_softball_coef = AS[1,1]
scalar cdh_yield_softball_se   = AS[1,2]
scalar cdh_yield_softball_n    = e(N)

did_multiplegt_stat yield_rate unitid year wbb_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
matrix AS = e(AS)
scalar cdh_yield_wbb_coef = AS[1,1]
scalar cdh_yield_wbb_se   = AS[1,2]
scalar cdh_yield_wbb_n    = e(N)

did_multiplegt_stat yield_rate unitid year wlax_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
matrix AS = e(AS)
scalar cdh_yield_wlax_coef = AS[1,1]
scalar cdh_yield_wlax_se   = AS[1,2]
scalar cdh_yield_wlax_n    = e(N)

did_multiplegt_stat yield_rate unitid year wsoc_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
matrix AS = e(AS)
scalar cdh_yield_wsoc_coef = AS[1,1]
scalar cdh_yield_wsoc_se   = AS[1,2]
scalar cdh_yield_wsoc_n    = e(N)

restore

// Applicants by Sport

preserve

// Baseball
reghdfe ln_applicants baseball_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store applicants_baseball

// Men's Basketball
reghdfe ln_applicants mbb_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store applicants_mbb

// Men's Lacrosse
reghdfe ln_applicants mlax_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store applicants_mlax

// Men's Soccer
reghdfe ln_applicants msoc_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store applicants_msoc

// Softball
reghdfe ln_applicants softball_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store applicants_softball

// Women's Basketball
reghdfe ln_applicants wbb_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store applicants_wbb

// Women's Lacrosse
reghdfe ln_applicants wlax_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store applicants_wlax

// Women's Soccer
reghdfe ln_applicants wsoc_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store applicants_wsoc

esttab applicants_baseball applicants_mbb applicants_mlax applicants_msoc applicants_softball applicants_wbb applicants_wlax applicants_wsoc ///
    using "/Users/andyxin/Desktop/ECON135/FinalProject/base_app_sport.tex", ///
    title("Regression of Applicants on Treatment by Sport (Canonical)") ///
    mtitles("Baseball" "MBB" "MLax" "MSoc" "Softball" "WBB" "WLax" "WSoc") ///
    keep(*_ncaa_lag) ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    b(4) se(4) ///
    scalars("N Observations" "r2 R-squared") ///
    label replace booktabs
	
restore
	
	
// CH Applicants by Sport

preserve

did_multiplegt_stat ln_applicants unitid year baseball_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
matrix AS = e(AS)
scalar cdh_app_baseball_coef = AS[1,1]
scalar cdh_app_baseball_se   = AS[1,2]
scalar cdh_app_baseball_n    = e(N)

did_multiplegt_stat ln_applicants unitid year mbb_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
matrix AS = e(AS)
scalar cdh_app_mbb_coef = AS[1,1]
scalar cdh_app_mbb_se   = AS[1,2]
scalar cdh_app_mbb_n    = e(N)

did_multiplegt_stat ln_applicants unitid year mlax_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
matrix AS = e(AS)
scalar cdh_app_mlax_coef = AS[1,1]
scalar cdh_app_mlax_se   = AS[1,2]
scalar cdh_app_mlax_n    = e(N)

did_multiplegt_stat ln_applicants unitid year msoc_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
matrix AS = e(AS)
scalar cdh_app_msoc_coef = AS[1,1]
scalar cdh_app_msoc_se   = AS[1,2]
scalar cdh_app_msoc_n    = e(N)

did_multiplegt_stat ln_applicants unitid year softball_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
matrix AS = e(AS)
scalar cdh_app_softball_coef = AS[1,1]
scalar cdh_app_softball_se   = AS[1,2]
scalar cdh_app_softball_n    = e(N)

did_multiplegt_stat ln_applicants unitid year wbb_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
matrix AS = e(AS)
scalar cdh_app_wbb_coef = AS[1,1]
scalar cdh_app_wbb_se   = AS[1,2]
scalar cdh_app_wbb_n    = e(N)

did_multiplegt_stat ln_applicants unitid year wlax_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
matrix AS = e(AS)
scalar cdh_app_wlax_coef = AS[1,1]
scalar cdh_app_wlax_se   = AS[1,2]
scalar cdh_app_wlax_n    = e(N)

did_multiplegt_stat ln_applicants unitid year wsoc_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)
matrix AS = e(AS)
scalar cdh_app_wsoc_coef = AS[1,1]
scalar cdh_app_wsoc_se   = AS[1,2]
scalar cdh_app_wsoc_n    = e(N)

restore
	
// Regressions by Gender

gen men_ncaa_lag = (baseball_ncaa_lag == 1 | ///
                     mbb_ncaa_lag == 1      | ///
                     mlax_ncaa_lag == 1     | ///
                     msoc_ncaa_lag == 1)
					 
gen women_ncaa_lag = (softball_ncaa_lag == 1 | ///
                       wbb_ncaa_lag == 1      | ///
                       wlax_ncaa_lag == 1     | ///
                       wsoc_ncaa_lag == 1)

// Men's					   

preserve

reghdfe yield_rate men_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, ///
    absorb(unitid year) vce(cluster unitid)
estimates store twfe_yield_men

reghdfe ln_applicants men_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, ///
    absorb(unitid year) vce(cluster unitid)
estimates store twfe_app_men

// Women's
reghdfe yield_rate women_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, ///
    absorb(unitid year) vce(cluster unitid)
estimates store twfe_yield_women

reghdfe ln_applicants women_ncaa_lag ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, ///
    absorb(unitid year) vce(cluster unitid)
estimates store twfe_app_women

esttab twfe_yield_men twfe_app_men twfe_yield_women twfe_app_women using "/Users/andyxin/Desktop/ECON135/FinalProject/base_yield_gender.tex", replace ///
	title("Regression of Treatment by Gender (Canonical)") ///
    mtitles("Yield" "Log Applicants" "Yield" "Log Applicants")      ///
    mgroups("Men" "Women", pattern(1 0 1 0))                        ///
    keep(men_ncaa_lag women_ncaa_lag)                               ///
    cells(b(star fmt(4)) se(par fmt(4)))                            ///
    stats(N r2_a, labels("Observations" "Adj. R²"))                 ///
    starlevels(* 0.10 ** 0.05 *** 0.01)                             ///
    label
	
restore

// CH Yield by Gender

preserve

// Men
did_multiplegt_stat yield_rate unitid year men_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)

matrix AS = e(AS)
scalar cdh_yield_men_coef = AS[1,1]
scalar cdh_yield_men_se   = AS[1,2]
scalar cdh_yield_men_n    = e(N)
scalar cdh_yield_men_sw   = AS[1,5]

// Women
did_multiplegt_stat yield_rate unitid year women_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)

matrix AS = e(AS)
scalar cdh_yield_women_coef = AS[1,1]
scalar cdh_yield_women_se   = AS[1,2]
scalar cdh_yield_women_n    = e(N)
scalar cdh_yield_women_sw   = AS[1,5]

// CH Applicants by Gender

// Men
did_multiplegt_stat ln_applicants unitid year men_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)

matrix AS = e(AS)
scalar cdh_app_men_coef = AS[1,1]
scalar cdh_app_men_se   = AS[1,2]
scalar cdh_app_men_n    = e(N)
scalar cdh_app_men_sw   = AS[1,5]

// Women
did_multiplegt_stat ln_applicants unitid year women_ncaa_lag, cluster(unitid) ///
    controls(ln_tuition_adj retention student_faculty_ratio pct_finaid sat75)

matrix AS = e(AS)
scalar cdh_app_women_coef = AS[1,1]
scalar cdh_app_women_se   = AS[1,2]
scalar cdh_app_women_n    = e(N)
scalar cdh_app_women_sw   = AS[1,5]

restore

// Robustness check: Expenses

// Log Expenses

gen ln_baseball_expenses_lag = ln(baseball_expenses_lag)
gen ln_mbb_expenses_lag = ln(mbb_expenses_lag)
gen ln_mlax_expenses_lag = ln(mlax_expenses_lag)
gen ln_msoc_expenses_lag = ln(msoc_expenses_lag)
gen ln_softball_expenses_lag = ln(softball_expenses_lag)
gen ln_wbb_expenses_lag = ln(wbb_expenses_lag)
gen ln_wlax_expenses_lag = ln(wlax_expenses_lag)
gen ln_wsoc_expenses_lag = ln(wsoc_expenses_lag)

// Base Yield Expenses

preserve

reghdfe yield_rate baseball_ncaa_lag ln_baseball_expenses_lag c.baseball_ncaa_lag#c.ln_baseball_expenses_lag ///
ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store expense_baseball

reghdfe yield_rate mbb_ncaa_lag ln_mbb_expenses_lag c.mbb_ncaa_lag#c.ln_mbb_expenses_lag ///
ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store expense_mbb

reghdfe yield_rate mlax_ncaa_lag ln_mlax_expenses_lag c.mlax_ncaa_lag#c.ln_mlax_expenses_lag ///
ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store expense_mlax

reghdfe yield_rate msoc_ncaa_lag ln_msoc_expenses_lag c.msoc_ncaa_lag#c.ln_msoc_expenses_lag ///
ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store expense_msoc

reghdfe yield_rate softball_ncaa_lag ln_softball_expenses_lag c.softball_ncaa_lag#c.ln_softball_expenses_lag ///
ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store expense_softball

reghdfe yield_rate wbb_ncaa_lag ln_wbb_expenses_lag c.wbb_ncaa_lag#c.ln_wbb_expenses_lag ///
ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store expense_wbb

reghdfe yield_rate wlax_ncaa_lag ln_wlax_expenses_lag c.wlax_ncaa_lag#c.ln_wlax_expenses_lag ///
ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store expense_wlax

reghdfe yield_rate wsoc_ncaa_lag ln_wsoc_expenses_lag c.wsoc_ncaa_lag#c.ln_wsoc_expenses_lag ///
ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store expense_wsoc

esttab expense_baseball expense_mbb expense_mlax expense_msoc expense_softball expense_wbb expense_wlax expense_wsoc ///
using "/Users/andyxin/Desktop/ECON135/FinalProject/base_yield_expense.tex", replace ///
keep(*#c*) ///
se star(* 0.10 ** 0.05 *** 0.01) ///
title("NCAA × Expenses on Yield Rate")
	
restore

// Base Applicants Expenses

preserve

reghdfe ln_applicants baseball_ncaa_lag ln_baseball_expenses_lag c.baseball_ncaa_lag#c.ln_baseball_expenses_lag ///
ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store app_baseball

reghdfe ln_applicants mbb_ncaa_lag ln_mbb_expenses_lag c.mbb_ncaa_lag#c.ln_mbb_expenses_lag ///
ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store app_mbb

reghdfe ln_applicants mlax_ncaa_lag ln_mlax_expenses_lag c.mlax_ncaa_lag#c.ln_mlax_expenses_lag ///
ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store app_mlax

reghdfe ln_applicants msoc_ncaa_lag ln_msoc_expenses_lag c.msoc_ncaa_lag#c.ln_msoc_expenses_lag ///
ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store app_msoc

reghdfe ln_applicants softball_ncaa_lag ln_softball_expenses_lag c.softball_ncaa_lag#c.ln_softball_expenses_lag ///
ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store app_softball

reghdfe ln_applicants wbb_ncaa_lag ln_wbb_expenses_lag c.wbb_ncaa_lag#c.ln_wbb_expenses_lag ///
ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store app_wbb

reghdfe ln_applicants wlax_ncaa_lag ln_wlax_expenses_lag c.wlax_ncaa_lag#c.ln_wlax_expenses_lag ///
ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store app_wlax

reghdfe ln_applicants wsoc_ncaa_lag ln_wsoc_expenses_lag c.wsoc_ncaa_lag#c.ln_wsoc_expenses_lag ///
ln_tuition_adj retention student_faculty_ratio pct_finaid sat75, absorb(unitid year) vce(cluster unitid)
estimates store app_wsoc

esttab app_baseball app_mbb app_mlax app_msoc app_softball app_wbb app_wlax app_wsoc ///
using "/Users/andyxin/Desktop/ECON135/FinalProject/base_app_expense.tex", replace ///
keep(*#c*) ///
se star(* 0.10 ** 0.05 *** 0.01) ///
title("NCAA × Expenses on Applicants")
	
restore

save "/Users/andyxin/Desktop/ECON135/FinalProject/d3_ipeds_with_sports.dta", replace
