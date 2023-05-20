*** Matching
clear all
* data

use "Dataset_Bowling_Replication_JPE.dta"

gen lnpop = ln(pop25)

summarize pcNSentry
gen stanpcNSentry = (pcNSentry - .0698501)/.052533

teffects psmatch (pcNSentry_std) (clubs_pc_AM lnpop, probit), atet nn(1) vce(robust, nn(2))

teffects psmatch (pcNSentry_std) (clubs_pc_AM lnpop, probit), atet nn(3) vce(robust, nn(2))

teffects psmatch (pcNSentry_std) (clubs_pc_AM lnpop share_cath25 bcollar25, hetprobit(lnpop share_cath25 bcollar25)), atet nn(3) 

* teffects psmatch (pcNSentry_std) (clubs_pc_AM lnpop share_cath25 bcollar25 latitude longitude, probit), atet nn(3) 

* teffects psmatch (pcNSentry_std) (clubs_pc_AM lnpop share_cath25 bcollar25 share_jew25 unemp33 in_welfare_per1000 war_per1000 sozialrentner_per1000 logtaxpers logtaxprop hitler_speech_per1000 DNVP_votes_avg DVP_votes_avg SPD_votes_avg KPD_votes_avg latitude longitude, probit), atet nn(3) 

*c)



