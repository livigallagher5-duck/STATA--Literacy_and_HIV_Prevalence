****************
*import cleaned HIV data
import delimited "/Users/livigallagher/Desktop/Econ/Econometrics/research prj 2/aids clean.csv", varnames(1) clear
*drop variables we don't need
drop countrycode indicatorcode indicatorname
*rename
forvalues x=5(1)67{
local y = `x'+1955
rename v`x' HIV`y' 
}
*reshape data
reshape long HIV, i(countryname) j(year)
sort countryname year
browse
count if HIV!=.
save "aidsWB.dta", replace

****************
*import cleaned life expectancy at birth data
import delimited "/Users/livigallagher/Desktop/Econ/Econometrics/research prj 2/life expectancy clean.csv", varnames(1) clear 
*drop variables we don't need
drop indicatorname indicatorcode countrycode
*rename
forvalues x=5(1)67{
local y = `x'+1955
rename v`x' life`y' 
}
*reshape data
reshape long life, i(countryname) j(year)
keep countryname year life 
save "lifeexpectancyWB.dta", replace

****************
*import cleaned literacy rate
import delimited "/Users/livigallagher/Desktop/Econ/Econometrics/research prj 2/literacy rate clean.csv", varnames(1) clear 
*drop variables we don't need
drop indicatorname indicatorcode countrycode
*rename
forvalues x=5(1)67{
local y = `x'+1955
rename v`x' lit`y' 
}
*reshape
reshape long lit, i(countryname) j(year)
keep countryname year lit 
save "literacyrateWB.dta", replace

*merg all together
merge 1:1 countryname year using "aidsWB.dta"
keep if _merge==3
drop _merge
merge 1:1 countryname year using "lifeexpectancyWB.dta"
keep if _merge==3
drop _merge
merge 1:1 countryname year using "literacyrateWB.dta"
keep if _merge==3
drop _merge

drop if countryname=="Early-demographic dividend" | countryname=="East Asia & Pacific (IDA & IBRD countries)" | countryname=="East Asia & Pacific (excluding high income)" | countryname=="Europe & Central Asia (IDA & IBRD countries)" | countryname=="Europe & Central Asia (excluding high income)" | countryname=="Fragile and conflict affected situations" | countryname=="Heavily indebted poor countries (HIPC)" | countryname=="High income" | countryname=="IBRD only" | countryname=="IDA & IBRD total" | countryname=="IDA blend" | countryname=="IDA only" |countryname=="IDA total" | countryname=="Lao PDR" | countryname=="Late-demographic dividend" | countryname=="Latin America & Caribbean (excluding high income)" | countryname=="Latin America & the Caribbean (IDA & IBRD countries)" | countryname=="Least developed countries: UN classifications" | countryname=="Low and middle income" | countryname=="Low income" | countryname=="Middle East & North Africa (IDA & IBRD countries)" | countryname=="Low income" | countryname=="Middle East & North Africa (excluding high income)" | countryname=="Not classified" | countryname=="OECD members" | countryname=="Other small states" | countryname=="Post-demographic dividend" | countryname=="Pre-demographic dividend" | countryname=="Small states" | countryname=="South Asia (IDA & IBRD)" | countryname=="Sub-Saharan Africa (IDA & IBRD countries)" | countryname=="Sub-Saharan Africa (excluding high income)" | countryname=="Upper middle income" | countryname=="World" | countryname=="Africa Eastern and Southern" | countryname=="Africa Western and Central" | | countryname=="Arab World" | countryname=="Caribbean small states" | countryname=="Central Europe and the Baltics" | countryname=="East Asia & Pacific" | countryname=="Euro area" | countryname=="Europe & Central Asia" | countryname=="European Union" | countryname=="Latin America & Caribbean" | countryname=="Least developed countries: UN classification" | countryname=="Low & middle income" | countryname=="Lower middle income" | countryname=="Middle East & North Africa" | countryname=="Middle income" | countryname=="North America" | countryname=="Pacific island small states" | countryname=="Sub-Saharan Africa" | countryname=="Least developed countries: UN classification" | countryname=="Africa Eastern and Southern" | countryname=="Africa Western and Central" | countryname=="Arab World" | countryname=="Caribbean small states" | countryname=="Central Europe and the Baltics" | countryname=="East Asia & Pacific" | countryname=="Euro area" | countryname=="Europe & Central Asia" | countryname=="European Union" | countryname=="Latin America & Caribbean" | countryname =="Low & middle income" | countryname =="Lower middle income" | countryname =="Middle East & North Africa" |countryname=="Middle income" | countryname=="Pacific island small states"

*We will look at years 2000 and beyond
keep if year >= 2000
*make sure there is more than 100 data points-yes we have 761
count if HIV!=. & lit!=.
*scatter 
scatter lit highHIV if highHIV!=. & lit!=.
*range of years is 2000 to 2021
summ year if HIV!=. & lit!=.
*to make our y variable of HIV binary
summ HIV, d
*median is 0.4 (1=HIV>0.4 or . while 0=HIV<0.4)
gen highHIV= (HIV>0.4)
replace highHIV = . if HIV==.

*for our naieve regression:
reg highHIV lit, robust
predict y_hat1
twoway scatter highHIV lit || line y_hat1 lit, sort
*coefficient on lit is -0.01731, standard error is 0.004, p-val is 0, constant/intercept is 3.078 w/SE of 0.416 and p-val of 0 aswell

*for second, polynomial regression:
generate lit_sq = lit^2
reg highHIV lit lit_sq, robust
predict y_hat2
twoway scatter highHIV lit || line y_hat2 lit, sort
*coefficient on lit is 0.1972 w/SE of 0.0467 and p-val of 0. Coeff on lit_sq is -0.001 w/SE of 0.0003 and p-val of 0. Constant/intercept is -4.06, w/SE of 1.467 and p-val of 0.006.

*for third, probit reg:
probit highHIV lit, robust
predict y_hat3
twoway scatter highHIV lit || line y_hat3 lit, sort
*coefficient on lit is -0.0278 w/SE of 0.0032 and p-val of 0. Constant/intercept is 2.54 w/SE of 0.302 and p-val of 0.

*Fourth reg: Fixed effects. Fixing for country since we're all ready looking betweeen 2000 to 2021
egen countrynameid = group(countryname), label lname(countryname)
reg highHIV lit life i.countrynameid i.year, cluster(countrynameid)
*coefficient on lit is -0.0048 w/SE of 0.0034 and p-val of 0.159.Coefficient on life is -0.026 w/SE of 0.011 and constant of 1.708 w/SE of 0.703

* Don't forget to save the final dataset once you are done! You will need to submit this file with your research paper on Brightspace
save "finaldata.dta", replace


