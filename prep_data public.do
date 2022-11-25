//global dir "C:\Users\Craig\Dropbox\Foreigners"
global dir "C:\Users\The Econ Of\Dropbox\Foreigners"
global data "$dir\data"
global results "$dir\results"

***********************************
* NYT Articles - Haiti
***********************************
insheet using "$data\NYT_proquest_headlines.csv", clear
drop if year==1921
replace month = regexr(month, "[ye]", "")
destring month, replace
save "$data\NYT_headlines", replace

insheet using "$data\NYT_proquest_headlines_1910.csv", clear
append using "$data\NYT_headlines"

duplicates drop link, force

duplicates tag headline, gen(dupe)
drop if dupe>0
drop if regexm(headline, "No Title")


drop if regexm(headline, "SHIPP.*MAIL")
drop if regexm(headline, "Shipp.*Mail")
drop if regexm(headline, "ARRIVAL OF BUYERS")
drop if regexm(headline, "TOPICS OF ")

save "$data\NYT_headlines", replace

gen no_articles = 1
collapse (sum) no_articles, by(year)

save "$data\NYT_by_year", replace

***********************************
insheet using "$data\occupation_codes_v2.csv", n clear
duplicates drop
save "$data\occupation_codes", replace

********************************
* Merge matched data
********************************
use "$data\foreigners_clean", clear

*Check on final merge
merge 1:1 license_id using "$data/panel_match"
drop _merge

egen nation_id = group(nationalites)
bys unique_bizid: egen nationalities_harmonized = mode(clean_nat)

sort license_year license_id
replace residence = residence[_n-1] if regexm(residence, "dodo") & license_year==license_year[_n-1]

replace residence = "Cap Haitien" if ustrregexm(residence, "Cap", 1)
replace residence = "Arcahaie" if ustrregexm(residence, "Ar.+aie", 1)
replace residence = "Gonaives" if ustrregexm(residence, "Gon", 1)
replace residence = "Grande Riviere du Nord" if ustrregexm(residence, "G.+Nord", 1) | ustrregexm(residence, "G.+Riv.+N", 1)
replace residence = "Jacmel" if ustrregexm(residence, "Jacmel", 1)
replace residence = "Petit Riviere de Nippes" if ustrregexm(residence, "P.+Riv.+Nip", 1)
replace residence = "Petit Trou de Nippes" if ustrregexm(residence, "P.+Tr.+Nip", 1)
replace residence = "Cayes" if ustrregexm(residence, "Cayes", 1)
replace residence = "Saint Marc" if ustrregexm(residence, "Saint.Marc", 1)
replace residence = "Miragoane" if ustrregexm(residence, "Miragoane", 1)

replace professions = regexr(professions, "^ +", "")
drop industry
merge m:1 professions using "$data/occupation_codes"

save "$data\foreigners_matched", replace


****************************************
* Import Data
****************************************

insheet using "$data/bt_price_index.csv", clear
save "$data/bt_price_index", replace

insheet using "$data/exports_imports_1912_1923.csv", clear
merge m:1 year using "$data/bt_price_index", keep(3) nogen

rename year license_year
drop exports
save "$data/imports_1912_1923", replace