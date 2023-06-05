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

twoway connected logall_tot year, xline(1937)

quietly twoway connected logmmr year, xline(1937) saving(mmr_gr)
quietly twoway connected loginpn year, xline(1937) saving(inpn_gr)
quietly twoway connected logscar year, xline(1937) saving(scar_gr)
quietly twoway connected logmeni year, xline(1937) saving(meni_gr)

gr combine mmr_gr.gph inpn_gr.gph scar_gr.gph meni_gr.gph

twoway connected logtuber year, xline(1937)

twoway connected logcancer logheart year, yaxis(1) || connected logdiab_trunc year, yaxis(2)

******** Table 2 *******************
keep if year>=1920 & year<=1950

log using Table2_results.log, replace
cap prog drop breaks
prog breaks
  args var
	cap drop break 
	cap drop sig 
	cap drop fstat 
	cap drop maxf
	
gen sig=.
gen fstat=.
tsset year

*test break
local i=33
while `i'<=42 {
cap drop y19`i' 
qui gen y19`i'=(year>=19`i')
qui newey d.`var' y19`i', lag(2)
qui replace fstat=e(F) if year==19`i'
qui test y19`i' 
qui replace sig=r(p) if year==19`i'
local i=`i' +1
}
qui egen maxf=max(fstat) 
qui gen break=year if fstat==maxf
list `var' year break fstat sig if break!=.

end
breaks logall_tot
breaks logmmr
breaks loginpn
breaks logscar
breaks logtuber

log close

************************************

****************** parallel tendencies *********************
quietly twoway connected logtuber logmmr year, xline(1937) saving(tmmr_gr)
quietly twoway connected logtuber loginpn year, xline(1937) saving(tinpn_gr)
quietly twoway connected logtuber logscar year, xline(1937) saving(tscar_gr)

gr combine tmmr_gr.gph tinpn_gr.gph tscar_gr.gph 

************************************************************
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

eststo

xi: reg logmortality i.stapost1937*year1937 treated treatedxpost1937 treatedxyear treatxpostxyear if disease == 1|disease == 2, cluster(diseaseyear)

eststo

xi: areg logmortality year1937 treated treatedxpost1937 treatedxyear if disease == 1|disease == 4, absorb(stapost1937) cluster(diseaseyear)

eststo

xi: reg logmortality i.stapost1937*year1937 treated treatedxpost1937 treatedxyear treatxpostxyear if disease == 1|disease == 4, cluster(diseaseyear)

eststo

xi: areg logmortality year1937 treated treatedxpost1937 treatedxyear if disease == 1|disease == 3, absorb(stapost1937) cluster(diseaseyear)

eststo

xi: reg logmortality i.stapost1937*year1937 treated treatedxpost1937 treatedxyear treatxpostxyear if disease == 1|disease == 3, cluster(diseaseyear)

eststo

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

eststo

xi: reg logmortality i.stapost1937*year1937 treated treatedxpost1937 treatedxyear treatxpostxyear if disease == 1|disease == 2, cluster(diseaseyear)

eststo

xi: areg logmortality year1937 treated treatedxpost1937 treatedxyear if disease == 1|disease == 4, absorb(stapost1937) cluster(diseaseyear)

eststo

xi: reg logmortality i.stapost1937*year1937 treated treatedxpost1937 treatedxyear treatxpostxyear if disease == 1|disease == 4, cluster(diseaseyear)

eststo

xi: areg logmortality year1937 treated treatedxpost1937 treatedxyear if disease == 1|disease == 3, absorb(stapost1937) cluster(diseaseyear)

eststo

xi: reg logmortality i.stapost1937*year1937 treated treatedxpost1937 treatedxyear treatxpostxyear if disease == 1|disease == 3, cluster(diseaseyear)

eststo

*  Real f)

use "state_race_data.dta", clear
keep state statenum year race mmr flupneu_rate sf_rate tb_rate
rename mmr d1
rename flupneu_rate d2
rename sf_rate d3
rename tb_rate d4
reshape long d, i(statenum year race) j(disease) 
label define disease 1"mmr" 2"influ_pneumonia" 3"scarlet_fever" 4"tb" 
label values disease disease
rename d m_rate
gen lnm_rate=ln(m_rate)
gen treated=(disease<4)
drop if year<1925|year>1943
gen post37=(year>=1937)
gen black=(race=="other")
gen year_c=year-1937
gen treatedXyear_c=treated*year_c
gen treatedXpost37=treated*post37
gen treatedXblack=treated*black
gen treatedXyear_cXpost37=treated*year_c*post37
gen treatedXyear_cXblack=treated*year_c*black
gen treatedXyear_cXpost37Xblack=treated*year_c*post37*black
gen treatedXpost37Xblack=treated*post37*black
gen year_cXblack=year_c*black
gen year_cXpost37=year_c*post37
gen blackXyear_cXpost37=black*year*post37
egen statepost = group (state post37)
egen blackstatepost = group(black statepost)
xi i.statepost*year
egen diseaseyear=group(disease year)

*/ Flag states to drop in scarlet fever model due to several state/year observations with zero mortality for blacks */
gen dropstate=(disease==3&(statenum==3|statenum==7|statenum==8|statenum==16|statenum==38|statenum==46))

* Panel A results - Whites only 

xi: areg lnm_rate treatedXyear_c treatedXpost37 treated year_c if race=="white"  & (disease==1|disease==4), absorb(statepost) cluster(diseaseyear)
eststo
xi: reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated i.statepost*year  if race=="white" & (disease==1|disease==4), cluster(diseaseyear)
eststo
xi: areg lnm_rate treatedXyear_c treatedXpost37 treated year_c if race=="white" & (disease==2|disease==4), absorb(statepost) cluster(diseaseyear)
eststo
xi: reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated i.statepost*year  if race=="white" & (disease==2|disease==4), cluster(diseaseyear)
eststo
xi: areg lnm_rate treatedXyear_c treatedXpost37 treated year_c if race=="white" & dropstate==0&(disease==3|disease==4), absorb(statepost) cluster(diseaseyear)
eststo
xi: reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated i.statepost*year  if race=="white" & dropstate==0 & (disease==3|disease==4), cluster(diseaseyear)
eststo

* Panel B results - Blacks only

xi: areg lnm_rate treatedXyear_c treatedXpost37 treated year_c if race=="other" & (disease==1|disease==4), absorb(statepost)  cluster(diseaseyear)
eststo
xi: reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated i.statepost*year if race=="other" & (disease==1|disease==4), cluster(diseaseyear)
eststo
xi: areg lnm_rate treatedXyear_c treatedXpost37 treated year_c if race=="other" & (disease==2|disease==4), absorb(statepost)  cluster(diseaseyear)
eststo
xi: reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated i.statepost*year if race=="other" & (disease==2|disease==4),  cluster(diseaseyear)
eststo
xi: areg lnm_rate treatedXyear_c treatedXpost37 treated year_c if race=="other"& dropstate==0 & (disease==3|disease==4), absorb(statepost) cluster(diseaseyear)
eststo
xi: reg lnm_rate treatedXyear_cXpost37 treatedXyear_c treatedXpost37 treated i.statepost*year if race=="other" & dropstate==0& (disease==3|disease==4),  cluster(diseaseyear)
eststo


* Panel C results - Fully interacted models 

areg lnm_rate treatedXyear_cXblack treatedXpost37Xblack treatedXblack treatedXpost37 year_cXblack treatedXyear_c treated year_c ///
if disease==1|disease==4, absorb(blackstatepost)  cluster(diseaseyear)
eststo
xi: reg lnm_rate treatedXyear_cXpost37Xblack treatedXyear_cXblack treatedXpost37Xblack treatedXblack blackXyear_cXpost37 treatedXyear_cXpost37 ///
treatedXpost37 treatedXyear_c treated i.blackstatepost*year if disease==1|disease==4, cluster(diseaseyear)
eststo
areg lnm_rate treatedXyear_cXblack treatedXpost37Xblack treatedXblack treatedXpost37 year_cXblack treatedXyear_c treated year_c ///
if disease==2|disease==4, absorb(blackstatepost)  cluster(diseaseyear)
eststo
xi: reg lnm_rate treatedXyear_cXpost37Xblack treatedXyear_cXblack treatedXpost37Xblack treatedXblack blackXyear_cXpost37 treatedXyear_cXpost37 ///
treatedXpost37 treatedXyear_c treated i.blackstatepost*year if disease==2|disease==4,  cluster(diseaseyear)
eststo
xi: areg lnm_rate treatedXyear_cXblack treatedXpost37Xblack treatedXblack treatedXpost37 year_cXblack treatedXyear_c treated year_c ///
if (disease==3|disease==4) & dropstate==0 , absorb(blackstatepost)  cluster(diseaseyear)
eststo
xi: reg lnm_rate treatedXyear_cXpost37Xblack treatedXyear_cXblack treatedXpost37Xblack treatedXblack blackXyear_cXpost37 treatedXyear_cXpost37 ///
treatedXpost37 treatedXyear_c treated i.blackstatepost*year if (disease==3|disease==4 ) & dropstate==0 ,  cluster(diseaseyear)
eststo


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
