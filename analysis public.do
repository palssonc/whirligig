//global dir "C:\Users\Craig\Dropbox\Foreigners"
global dir "C:\Users\The Econ Of\Dropbox\Foreigners"
global data "$dir\data"
global results "$dir\results"



********************************
* License details
********************************

use "$data\foreigners_matched", clear

*This drops a pretty significant number. Is it right to drop them?
drop if regexm(nationalites, "Haitian")

egen unique_holders = group(unique_pid)

sum unique_holders
						
********************************
* Figure 1: Number of licenses for foreigners operating in Haiti by year, 1912-22
********************************
insheet using "$data/expose_licenses.csv", clear
rename licenses all_expose
rename year license_year
save "$data/expose_licenses", replace

use "$data\foreigners_matched", clear

drop if license_year==1928

gen all = 1
gen drop_haiti = 1 if !regexm(clean_nat, "Haiti")
collapse (sum) all drop_haiti, by(license_year)

merge 1:1 license_year using "$data/expose_licenses"

sort license_year

twoway (connected all_expose license_year if license_year<1910, col(gs3) m(D)) ///
		(connected all_expose license_year if license_year>1910, col(gs3) m(D)) ///
		(connected all_expose license_year if license_year>=1907 & license_year<=1914, col(gs3) lp(dash) m(D)) ///
		(connected drop_haiti license_year if license_year<1914, col(gs7) m(T)) ///
		(connected drop_haiti license_year if license_year>1916, col(gs7) m(T)) ///
		(connected drop_haiti license_year if license_year>=1913 & license_year<=1917, col(gs7) lp(dash) m(T)) ///
		(connected all license_year if license_year<1914, col(black)) ///
		(connected all license_year if license_year>1916, col(black)) ///
		(connected all license_year if license_year>=1913 & license_year<=1917, col(black) lp(dash)), ///
		xline(1915.5, lp(dash)) graphr(fc(white)) xtitle(Financial Year) ytitle(Licenses Registered) ///
		legend(label(1 "Expose") label(7 "List") label(4 "List, Excluding Haitians") order(1 7 4) ring(0) pos(10) c(1)) xlabel(1906(2)1922) ylabel(0(200)1000)
graph export "$results\total_year.png", replace

********************************
* Figure 2: Share of licenses held by nationality, 1912-22
********************************

use "$data\foreigners_matched", clear

drop if license_year==1928

drop if regexm(nationalities_harmonized, "Haitian")

gen nat_groups = nationalities_harmonized
replace nat_groups = "Other" if !inlist(nat_groups, "Americain", "Francais", "Allemand", "Syrian")
gen c = 1

collapse (sum) c, by(nat_groups license_year)

gen nat_ord = 1 if nat_groups=="Francais"
replace nat_ord = 2 if nat_groups=="Allemand"
replace nat_ord = 3 if nat_groups=="Americain"
replace nat_ord = 4 if nat_groups=="Syrian"
replace nat_ord = 5 if nat_groups=="Other"
drop nat_groups

reshape wide c, i(license_year) j(nat_ord)

egen row_tot = rowtotal(c*)
gen sub_total1 = c1/row_tot
gen sub_total2 = sub_total1 + c2/row_tot
gen sub_total3 = sub_total2 + c3/row_tot
gen sub_total4 = sub_total3 + c4/row_tot
gen sub_total5 = sub_total4 + c5/row_tot

twoway (area sub_total5 license_year, col(gs5)) ///
		(area sub_total4 license_year, col(gs3)) ///
		(area sub_total3 license_year, col(gs8)) ///
		(area sub_total2 license_year, col(gs11)) ///
		(area sub_total1 license_year, col(gs14)) ///
		(scatteri 0 1915.5 1 1915.5, recast(line) lp(dash) lc(red)), ///
		legend(off) graphr(c(white)) ylabel(0(.2)1) xtitle("") ytitle("Share of Licenses") ///
		text(.2 1913 "French", placement(e)) text(.5 1913 "German", placement(e)) text(.645 1913 "American", placement(e)) text(.55 1920 "Syrian") text(.8 1913 "Other", placement(e))
graph export "$results/nationality_shares.png", replace

********************************
* Figure 3: Time Series of NYT Articles Mentioning Haiti, 1905-1921
********************************
use "$data\NYT_headlines", clear

gen quarter = ceil(month/3)

gen n = 1

collapse (sum) n, by(quarter year)


gen year_q = year + (quarter-(1/3))/4

sort year_q
twoway (line n year_q, lc(black)), graphr(c(white)) xtitle("") ytitle("# NYT Articles Mentioning Haiti") xlabel(1905(2)1919) ylabel(0(20)80) ///
		text(68 1915.8 "Occupation" "Begins") ///
		text(50 1920.9 "Senate" "Inquiry") ///
		text(40 1911.7 "Leconte" "Coup") ///
		text(35 1914.2 "Zamor" "Coup") ///
		text(10 1919.7 "Péralte" "Death") ///
		text(30 1908.9 "Alexis" "Exile")
graph export "$results/NYT_timeseries.png", replace

********************************
* Figure 4: Monthly legislative acts, 1905-1917
********************************

import delimited using "$data/haiti_laws.csv", clear

replace date_prom = date_moniteur if missing(date_prom)

gen prom_edate = date(date_prom, "DMY", 1900)

gen president = ""
replace president = "Pierre Nord Alexis" if prom_edate>=mdy(12,21,1902) & prom_edate<mdy(12,2,1908)
replace president = "François C. Antoine Simon" if prom_edate>=mdy(12,6,1908) & prom_edate<mdy(8,3,1911)
replace president = "Cincinnatus Leconte" if prom_edate>=mdy(8,15,1911) & prom_edate<mdy(8,8,1912)
replace president = "Tancrède Auguste" if prom_edate>=mdy(8,8,1912) & prom_edate<mdy(5,2,1913)
replace president = "Michel Oreste" if prom_edate>=mdy(5,12,1913) & prom_edate<mdy(1,27,1914)
replace president = "Oreste Zamor" if prom_edate>=mdy(2,8,1914) & prom_edate<mdy(10,29,1914)
replace president = "Joseph Davilmar Théodore" if prom_edate>=mdy(11,7,1914) & prom_edate<mdy(2,22,1915)
replace president = "Vilbrun Guillaume Sam" if prom_edate>=mdy(2,25,1915) & prom_edate<mdy(7,28,1915)
replace president = "Philippe Sudré Dartiguenave" if prom_edate>=mdy(8,12,1915) & prom_edate<mdy(5,15,1922)

gen no_law = 1

collapse (sum) no_law, by(president)

gen days_office = .
// Actual term, but we don't see anything before 1905 or after 1916
// replace days_office = mdy(12,2,1908) - mdy(12,21,1902) if president == "Pierre Nord Alexis" 			
// replace days_office = mdy(5,15,1922) - mdy(8,12,1915)	if president == "Philippe Sudré Dartiguenave" 	
replace days_office = mdy(12,2,1908) - mdy(1,1,1905) if president == "Pierre Nord Alexis" 			
replace days_office = mdy(8,3,1911) - mdy(12,6,1908) if president == "François C. Antoine Simon" 	
replace days_office = mdy(8,8,1912) - mdy(8,15,1911) if president == "Cincinnatus Leconte" 			
replace days_office = mdy(5,2,1913) - mdy(8,8,1912) if president == "Tancrède Auguste" 				
replace days_office = mdy(1,27,1914) - mdy(5,12,1913) if president == "Michel Oreste" 				
replace days_office = mdy(10,29,1914) - mdy(2,8,1914)	if president == "Oreste Zamor" 					
replace days_office = mdy(2,22,1915) - mdy(11,7,1914)	if president == "Joseph Davilmar Théodore" 		
replace days_office = mdy(7,28,1915) - mdy(2,25,1915)	if president == "Vilbrun Guillaume Sam" 		
replace days_office = mdy(12,31,1917) - mdy(8,12,1915)	if president == "Philippe Sudré Dartiguenave" 	

gen laws_day = no_law/days_office

scatter laws_day days_office
scatter no_law days_office
********************************
* Time Series
********************************

import delimited using "$data/haiti_laws.csv", clear

replace date_prom = date_moniteur if missing(date_prom)

gen prom_edate = date(date_prom, "DMY", 1900)
gen month_law = month(prom_edate)
gen year_law = year(prom_edate)

gen president = ""
replace president = "Pierre Nord Alexis" if prom_edate>=mdy(12,21,1902) & prom_edate<mdy(12,2,1908)
replace president = "François C. Antoine Simon" if prom_edate>=mdy(12,6,1908) & prom_edate<mdy(8,3,1911)
replace president = "Cincinnatus Leconte" if prom_edate>=mdy(8,15,1911) & prom_edate<mdy(8,8,1912)
replace president = "Tancrède Auguste" if prom_edate>=mdy(8,8,1912) & prom_edate<mdy(5,2,1913)
replace president = "Michel Oreste" if prom_edate>=mdy(5,12,1913) & prom_edate<mdy(1,27,1914)
replace president = "Oreste Zamor" if prom_edate>=mdy(2,8,1914) & prom_edate<mdy(10,29,1914)
replace president = "Joseph Davilmar Théodore" if prom_edate>=mdy(11,7,1914) & prom_edate<mdy(2,22,1915)
replace president = "Vilbrun Guillaume Sam" if prom_edate>=mdy(2,25,1915) & prom_edate<mdy(7,28,1915)
replace president = "Philippe Sudré Dartiguenave" if prom_edate>=mdy(8,12,1915) & prom_edate<mdy(5,15,1922)

gen no_law = 1

collapse (sum) no_law, by(month_law year_law)

drop if year_law<1905 | year_law>1917

reshape wide no_law, i(year_law) j(month_law)
reshape long no_law, i(year_law) j(month_law)
replace no_law=0 if missing(no_law)

gen emonthyear = mdy(month_law, 28, year_law)

local Simon = mdy(12,6,1908)
local Leconte = mdy(8,15,1911)
local Auguste = mdy(8,8,1912)
local Oreste = mdy(5,12,1913)
local Zamor = mdy(2,8,1914)
local Theodore = mdy(11,7,1914)
local Sam = mdy(2,25,1915)
local Dartiguenave = mdy(8,12,1915)

local start = mdy(1,1,1905)
local end = mdy(12,31,1917)
//twoway (line no_law emonthyear), xline(`Simon' `Leconte' `Auguste' `Oreste' `Zamor' `Theodore' `Sam' `Dartiguenave')


twoway (function y=40,range(`Simon' `Leconte') recast(area) color(gs14) base(0)) ///
		(function y=40,range(`Auguste' `Oreste') recast(area) color(gs14) base(0)) ///
		(function y=40,range(`Zamor' `Theodore') recast(area) color(gs14) base(0)) ///
		(function y=40,range(`Sam' `Dartiguenave') recast(area) color(gs14) base(0)) ///
		(line no_law emonthyear, lc(black)), ///
		legend(off) graphr(color(white)) ///
		xlabel(-20061 "1905" -19331 "1907" -18600 "1909" -17870 "1911" -17139 "1913" -16409 "1915" -15678 "1917")
graph export "$results/laws_timeseries.png", replace

*********************************************
* Table 2: Legislation following the installment of a new president, 1905–1917
*********************************************
import delimited using "$data/haiti_laws.csv", clear

replace date_prom = date_moniteur if missing(date_prom)

gen date = date(date_prom, "DMY", 1900)

gen no_acts = 1
gen no_loi = regexm(type, "Loi")
gen no_arr = regexm(type, "Arr")
gen no_amnesty = regexm(title, "[Am]mnis")
gen no_fin = regexm(section, "Fin")
gen no_credit = ustrregexm(title, "[Cc]r.dit")
gen no_tax = regexm(title, "taxe") | regexm(title, "tarif") | regexm(title, "timbre") | regexm(title, "imposition.+direct") | regexm(title, "douane")

collapse (sum) no_acts no_loi no_arr no_tax no_amnesty no_credit no_fin, by(date)

save "$data/daily_laws", replace

clear

local days = mdy(12,31,1917)-mdy(1,1,1905)+1
set obs `days'

gen date = mdy(1,1,1905)+_n-1
gen month = month(date)
gen day = day(date)
gen year = year(date)

merge 1:1 date using "$data/daily_laws"
drop if _merge==2
drop _merge

gen pres_simon = mdy(12,6,1908)
gen pres_leconte = mdy(8,15,1911)
gen pres_auguste = mdy(8,8,1912)
gen pres_oreste = mdy(5,12,1913)
gen pres_zamor = mdy(2,8,1914)
gen pres_theodore = mdy(11,7,1914)
gen pres_sam = mdy(2,25,1915)
gen pres_dartiguenave = mdy(8,12,1915)

foreach X in simon leconte auguste oreste zamor theodore sam dartiguenave{
	gen days_`X' = date - pres_`X'
	replace days_`X' = 100000 if  days_`X'<0
}

egen closest_turnover = rowmin(days_*)

for X in any 30 60 90: gen revX = closest_turnover<=X
for X in any acts loi arr amnesty credit tax fin: replace no_X = 0 if missing(no_X)


gen day_week = dow(date)
drop if day_week==0 | day_week==6

cap erase "$results/laws_first90.txt"
foreach Y in no_acts no_loi no_arr  no_fin no_credit no_tax no_amnesty {
	foreach X in 90 60 30{
		sum `Y'
		local dvm = r(mean)
		reghdfe `Y' rev`X', a(month)
		outreg2 using "$results/laws_first90.txt", br addstat(Dep Var Mean, `dvm')
	}
}

********************************
* Figure 5: Share of licenses held by city, 1912-22
********************************

use "$data\foreigners_matched", clear

drop if license_year==1928

gen res_groups = residence
replace res_groups = "Other" if !inlist(res_groups, "Port-au-Prince", "Cap Haitien", "Cayes")
gen c = 1

collapse (sum) c, by(res_groups license_year)

gen res_ord = 1 if res_groups=="Port-au-Prince"
replace res_ord = 2 if res_groups=="Cap Haitien"
replace res_ord = 3 if res_groups=="Cayes"
replace res_ord = 4 if res_groups=="Other"
drop res_groups

reshape wide c, i(license_year) j(res_ord)

egen row_tot = rowtotal(c*)
gen sub_total1 = c1/row_tot
gen sub_total2 = sub_total1 + c2/row_tot
gen sub_total3 = sub_total2 + c3/row_tot
gen sub_total4 = sub_total3 + c4/row_tot

twoway 	(area sub_total4 license_year, col(gs5)) ///
		(area sub_total3 license_year, col(gs8)) ///
		(area sub_total2 license_year, col(gs11)) ///
		(area sub_total1 license_year, col(gs14)) ///
		(scatteri 0 1915.5 1 1915.5, recast(line) lp(dash) lc(red)), ///
		legend(off) graphr(c(white)) ylabel(0(.2)1) xtitle("") ytitle("Share of Licenses") ///
		text(.2 1913 "Port-au-Prince", placement(e)) text(.4 1913 "Cap-Haitien", placement(e)) text(.55 1913 "Cayes", placement(e)) text(.8 1913 "Other", placement(e))
graph export "$results/residence_shares.png", replace


********************************
* Figure 6: Share of licenses held by industry, 1912-22
********************************
use "$data\foreigners_matched", clear

gen c=1
drop if missing(industry) | license_year==1928

replace industry = "Manufacturing" if industry=="Agriculture"

collapse (sum) c, by(industry license_year)

gen ind_ord = 1 if industry=="Merchant"
replace ind_ord = 2 if industry=="Manufacturing"
replace ind_ord = 3 if industry=="Service"
replace ind_ord = 4 if industry=="Property"

drop industry

reshape wide c, i(license_year) j(ind_ord)

egen row_tot = rowtotal(c*)
gen sub_total1 = c1/row_tot
gen sub_total2 = sub_total1 + c2/row_tot
gen sub_total3 = sub_total2 + c3/row_tot
gen sub_total4 = sub_total3 + c4/row_tot

twoway 	(area sub_total4 license_year, col(gs5)) ///
		(area sub_total3 license_year, col(gs8)) ///
		(area sub_total2 license_year, col(gs11)) ///
		(area sub_total1 license_year, col(gs14)) ///
		(scatteri 0 1915.5 1 1915.5, recast(line) lp(dash) lc(red)), ///
		legend(off) graphr(c(white)) ylabel(0(.2)1) xtitle("") ytitle("Share of Licenses") ///
		text(.4 1913 "Merchant", placement(e)) text(.76 1913 "Manufacturing", placement(e)) text(.88 1913 "Services", placement(e)) text(.97 1913 "Property", placement(e))
graph export "$results/industry_shares.png", replace

**************************************
* Table 3: The relationship between imports and licenses by nationality, 1912–1922
**************************************

use "$data\foreigners_matched", clear

gen country = "Other"
replace country = "United States" if clean_nat=="Americain"
replace country = "United Kingdom" if clean_nat=="Anglais"
replace country = "France" if clean_nat=="Francais"

gen no_license = 1
//gen importer = regexm(professions, "Consig") | regexm(professions, "Commis")
gen importer = industry=="Merchant"

collapse (sum) no_license importer, by(country license_year)
replace license_year = 1914 if license_year==1915

merge 1:1 country license_year using "$data/imports_1912_1923"
keep if _merge==3

gen l_imports = log(imports/haiti_price_index*100)
gen l_no_licenses = log(no_license)
gen l_importer = log(importer)
gen l_notimporter = log(no_license-importer)

cap erase "$results/imports_licenses.txt"
foreach X in l_no_licenses l_importer {	
	reghdfe l_imports `X', a(license_year country)
	outreg2 using "$results/imports_licenses.txt", br auto(2)
	reghdfe l_imports `X' if license_year!=1920, a(license_year country)
	outreg2 using "$results/imports_licenses.txt", br auto(2)
}


********************************
* Appendix Figure A1: Reporting on Haiti in the New York Times and Licenses Issued in Haiti to Americans, 1912-22
********************************
use "$data\foreigners_matched", clear

gen no_license = 1
gen no_american = regexm(nationalities_harmonized, "Ameri")

collapse (sum) no_license no_american, by(license_year)

gen year = license_year-1
merge 1:1 year using "$data\NYT_by_year"

replace license_year = year+1 if missing(license_year)
sort year

twoway (scatter no_american no_articles, ml(license_year) col(black)), graphr(fc(white)) ///
		xtitle("# NYT Articles") ytitle("# Licenses Issued in Haiti to Americans") xlabel(0(20)80) ylabel(0(40)160) legend(off)
graph export "$results\NYT_licenses_american.png", replace

***************************************
* Additional Summary Statistics
***************************************

*********************
* Exploring HASCO
*********************

use "$data\foreigners_matched", clear

gen HASCO = ustrregexm(professions, "H.*A.*S.*C") | ustrregexm(nationalites, "H.*A.*S.*C")
bys unique_bizid: egen ever_hasco = max(HASCO)

sum ever_hasco
table license_year, stat(mean ever_hasco)


******************************
* How many acts are there?
******************************
import delimited using "$data/haiti_laws.csv", clear
gen no_act = 1
collapse (sum) no_act, by(year)
sum no_act
