# Analysis of Collegiate Athletics Success on Admissions Outcomes at Division III Level
Andy Xin, ECON135, Swarthmore College

# Overview
This paper examines whether NCAA tournament qualification is associated with changes in yield rate and number of applicants at Division III schools. Using a balanced panel dataset of 425 Division III schools across 8 sports from 2013–2022, I employ a Differences-in-Differences framework with two-way fixed effects, including the modernized Chaisemartin & D'Haultfœuille approach. Results indicate a statistically insignificant association between athletic success and both admissions outcomes, with the magnitude near zero.

# Primary Files & Data Collection/Sources
/Users/andyxin/Desktop/ECON135/FinalProject/

ipeds.csv                       IPEDS data, downloaded from IPEDS
d3schools.xlsx                  List of Division III schools, downloaded from NCSA
expenses.csv                    Expenses for each team per school per year, downloaded from EADA

8 sports: baseball, men's basketball, men's lacrosse, men's soccer, softball, women's basketball, women's lacrosse, women's soccer
`sport'.xlsx                    NCAA tournament qualification data. Copy-pasted from individual NCAA tournament field announcements
`sport'.py                      Python files using rapidfuzz algorithm to match school names in `sport'.csv to school names in ipeds.csv
merge_sports.py                 Merge file

d3_ipeds_with_sports.csv        Master dataset with everything merged
ECON135FP.do                    Do file

# Variables 
year                            Year
school                          School Name
unitid                          6-digit id uniquely assigned to each school
applicants                      # of applicants. Logged (ln_applicants)
tuition                         Out-of-state price to attend. Logged (ln_tuition_adj)
retention                       Retention Rate
student_faculty_ratio           Student-Faculty Ratio
pct_finaid                      Percentage of first-year students receiving some sort of financial aid
acceptance_rate                 Acceptance Rate. Admits / applicants (admits dropped at end)
yield_rate                      Yield Rate. Enrolled / admits (enrolled dropped at end)
sat75                           75th percentile of SAT exam score

`sport'_confchamp               Binary indicator for whether a school's `sport' team won a conference championship. 
`sport'_ncaa                    Binary indicator for whether a school's `sport' team qualified for the NCAA tournament. 
`sport'_expenses                Amount of money spent on each team per school per year.
These were lagged two years. Sports in year t [(t - t+1) academic year] would potentially influence applications and decisions for students applying in the fall of t + 1 or spring of t + 2. Applications and enrollment are captured by the t + 2 cohort in IPEDS. So sports in year t -> IPEDSS in year t + 2

Note: I adjusted tuition for inflation, but realize year fixed effects partial it out

# Construction of Data - Assumptions
Schools that transitioned from Division III to another division, or closed during this time period were excluded to maintain the balanced nature of the panel
Treatment is non-absorbing; schools can qualify one year, miss out the next, and qualify again another year
As mentioned previously, admissions outcomes are lagged 2 years relative to NCAA tournament appearances

Code sections that I used AI for assistance are labeled