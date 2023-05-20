* DID
clear all
use "national_data.dta"

* c)
gen logall_tot = ln(all_tot)

gen logmmr = ln(mmr)
gen loginpn = ln(influenza_pneumonia_total)
gen logscar = ln(scarlet_fever_tot)
gen logmeni = ln(meningitis_total)

gen logtuber = ln(tuberculosis_total)

gen logcancer = ln(cancer_total)
gen logdiab = ln(diabetes_total)
gen logheart = ln(heart_total)

* weird diabetes record
gen logdiab_trunc = logdiab
replace logdiab_trunc = . if logdiab < 2.71

twoway connected logall_tot year

quietly twoway connected logmmr year, saving(mmr_gr)
quietly twoway connected loginpn year, saving(inpn_gr)
quietly twoway connected logscar year, saving(scar_gr)
quietly twoway connected logmeni year, saving(meni_gr)

gr combine mmr_gr.gph inpn_gr.gph scar_gr.gph meni_gr.gph

twoway connected logtuber year

twoway connected logcancer logheart year, yaxis(1) || connected logdiab_trunc year, yaxis(2)

* d)

sort year
gen post1937 = 0
replace post1937 = 1 if year > 1936
gen year1937 = year - 1937
gen yearpost1937 = year1937*post1937

newey logall_tot year1937 post1937 if year < 1944 & year > 1924 , lag(2)
newey logall_tot year1937 post1937 yearpost1937  if year < 1944 & year > 1924 , lag(2)

newey logtuber year1937 post1937 if year < 1944 & year > 1924 , lag(2)
newey logtuber year1937 post1937 yearpost1937  if year < 1944 & year > 1924 , lag(2)

newey logmmr year1937 post1937 if year < 1944 & year > 1924 , lag(2)
newey logmmr year1937 post1937 yearpost1937  if year < 1944 & year > 1924 , lag(2)

newey loginpn year1937 post1937 if year < 1944 & year > 1924 , lag(2)
newey loginpn year1937 post1937 yearpost1937  if year < 1944 & year > 1924 , lag(2)

newey logscar year1937 post1937 if year < 1944 & year > 1924 , lag(2)
newey logscar year1937 post1937 yearpost1937  if year < 1944 & year > 1924 , lag(2)

* e)

drop if year > 1943 | year < 1925
rename tuberculosis_total d1
rename mmr d2
rename scarlet_fever_tot d3
rename influenza_pneumonia_total d4
reshape long d, i(year) j(disease) 
gen treated = 1
replace treated = 0 if disease == 1
rename d mortality
gen logmortality = ln(mortality)

gen treatedxpost1937 = treated*post1937
gen treatedxyear = treated*year1937
gen treatxpostxyear = treated*post1937*year1937

** Panel A

reg logmortality post1937 year1937 treated treatedxpost1937 treatedxyear if disease == 1|disease == 2, robust

reg logmortality post1937 year1937 treated treatedxpost1937 treatedxyear treatxpostxyear if disease == 1|disease == 2, robust

reg logmortality post1937 year1937 treated treatedxpost1937 treatedxyear if disease == 1|disease == 4, robust

reg logmortality post1937 year1937 treated treatedxpost1937 treatedxyear treatxpostxyear if disease == 1|disease == 4, robust

reg logmortality post1937 year1937 treated treatedxpost1937 treatedxyear if disease == 1|disease == 3, robust

reg logmortality post1937 year1937 treated treatedxpost1937 treatedxyear treatxpostxyear if disease == 1|disease == 3, robust

** Panel B

clear all
use "state_data"

drop if year > 1943 | year < 1925
rename tb_rate d1
rename mmr d2
rename scarfever_rate d3
rename infl_pneumonia_rate d4

reshape long d, i(state year) j(disease) 
gen treated = 1
replace treated = 0 if disease == 1
rename d mortality
gen logmortality = ln(mortality)

gen year1937 = year - 1937
gen post1937 = 0
replace post1937 = 1 if year > 1936

gen treatedxyear = treated*year1937
gen treatedxpost1937 = treated*post1937
gen treatxpostxyear = treated*post1937*year1937

egen stapost1937=group(state post1937)
xi i.stapost1937*year1937
egen diseaseyear=group(disease year1937)

xi: areg logmortality year1937 treated treatedxpost1937 treatedxyear if disease == 1|disease == 2, absorb(stapost1937) cluster(diseaseyear)

xi: reg logmortality i.stapost1937*year1937 treated treatedxpost1937 treatedxyear treatxpostxyear if disease == 1|disease == 2, cluster(diseaseyear)

xi: areg logmortality year1937 treated treatedxpost1937 treatedxyear if disease == 1|disease == 4, absorb(stapost1937) cluster(diseaseyear)

xi: reg logmortality i.stapost1937*year1937 treated treatedxpost1937 treatedxyear treatxpostxyear if disease == 1|disease == 4, cluster(diseaseyear)

xi: areg logmortality year1937 treated treatedxpost1937 treatedxyear if disease == 1|disease == 3, absorb(stapost1937) cluster(diseaseyear)

xi: reg logmortality i.stapost1937*year1937 treated treatedxpost1937 treatedxyear treatxpostxyear if disease == 1|disease == 3, cluster(diseaseyear)

** Panel C

clear all
use "state_data"

drop if year > 1943 | year < 1925
drop if year >= 1935 & year <= 1937
rename tb_rate d1
rename mmr d2
rename scarfever_rate d3
rename infl_pneumonia_rate d4

reshape long d, i(state year) j(disease) 
gen treated = 1
replace treated = 0 if disease == 1
rename d mortality
gen logmortality = ln(mortality)

gen year1937 = year - 1937
gen post1937 = 0
replace post1937 = 1 if year > 1936

gen treatedxyear = treated*year1937
gen treatedxpost1937 = treated*post1937
gen treatxpostxyear = treated*post1937*year1937

egen stapost1937=group(state post1937)
xi i.stapost1937*year1937
egen diseaseyear=group(disease year1937)

xi: areg logmortality year1937 treated treatedxpost1937 treatedxyear if disease == 1|disease == 2, absorb(stapost1937) cluster(diseaseyear)

xi: reg logmortality i.stapost1937*year1937 treated treatedxpost1937 treatedxyear treatxpostxyear if disease == 1|disease == 2, cluster(diseaseyear)

xi: areg logmortality year1937 treated treatedxpost1937 treatedxyear if disease == 1|disease == 4, absorb(stapost1937) cluster(diseaseyear)

xi: reg logmortality i.stapost1937*year1937 treated treatedxpost1937 treatedxyear treatxpostxyear if disease == 1|disease == 4, cluster(diseaseyear)

xi: areg logmortality year1937 treated treatedxpost1937 treatedxyear if disease == 1|disease == 3, absorb(stapost1937) cluster(diseaseyear)

xi: reg logmortality i.stapost1937*year1937 treated treatedxpost1937 treatedxyear treatxpostxyear if disease == 1|disease == 3, cluster(diseaseyear)

* f)
clear all
use "national_data.dta"

gen logmmr_w = ln(mmr_w)
gen logmmr_b = ln(mmr_nw)
gen loginpn_w = ln(influenza_pneumonia_w)
gen loginpn_b = ln(influenza_pneumonia_nw)
gen logscar_w = ln(scarlet_fever_w)
gen logscar_b = ln(scarlet_fever_nw)
gen logtuber_w = ln(tuberculosis_w)
gen logtuber_b = ln(tuberculosis_nw)

quietly twoway connected logmmr_w logmmr_b year, saving(mmrr_gr)
quietly twoway connected loginpn_w loginpn_b year, saving(inpnr_gr)
quietly twoway connected logscar_w logscar_b year, saving(scarr_gr)
quietly twoway connected logtuber_w logtuber_b year, saving(tuber_gr)

gr combine mmrr_gr.gph inpnr_gr.gph scarr_gr.gph tuber_gr.gph
