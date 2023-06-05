*** Matching
clear all
* data

use "Dataset_Bowling_Replication_JPE.dta"

* c)

gen lnpop = ln(pop25)

quietly teffects psmatch (pcNSentry_std) (clubs_pc_AM lnpop share_cath25 bcollar25, probit), atet 

tebalance summarize, baseline


* d)

*Dummies for size quintiles
xtile pop25_quintiles = pop25, nq(5)
tab  pop25_quintiles, gen(d_pop_quintile)

nnmatch pcNSentry_std clubs_pc_AM lnpop, m(1) robust(1) tc(att)
eststo
nnmatch pcNSentry_std clubs_pc_AM lnpop, m(3) robust(3) tc(att)
eststo
nnmatch pcNSentry_std clubs_pc_AM lnpop share_cath25 bcollar25, m(3) robust(3) tc(att)
eststo
nnmatch pcNSentry_std clubs_pc_AM lnpop share_cath25 bcollar25 latitude longitude, m(3) robust(3) tc(att)
eststo
nnmatch pcNSentry_std clubs_pc_AM lnpop share_cath25 bcollar25 latitude longitude, m(3) robust(3) tc(att) exact(pop25_quintiles landweimar_num)
eststo

* e)
reg pog20s pog1349 lnpop share_cath25 bcollar25 if exist1349==1, r beta 
eststo
nnmatch pog20s pog1349 lnpop share_cath25 bcollar25  latitude longitude if exist1349==1, m(3) robust(3) tc(att)
eststo
reg pcNSDAP285 pog1349 lnpop share_cath25 bcollar25 if exist1349==1, r beta 
eststo
nnmatch pcNSDAP285 pog1349 lnpop share_cath25 bcollar25  latitude longitude if exist1349==1, m(3) robust(3) tc(att)
eststo
reg clubs_all_pc pog1349 lnpop share_cath25 bcollar25 if exist1349==1, r beta 
eststo
nnmatch clubs_all_pc pog1349 lnpop share_cath25 bcollar25 latitude longitude if exist1349==1, m(3) robust(3) tc(att)
eststo

* f)

teffects ipw (pog20s) (pog1349 lnpop share_cath25 bcollar25 latitude longitude) if exist1349==1, atet vce(r)
eststo
teffects ipw (pcNSDAP285) (pog1349 lnpop share_cath25 bcollar25 latitude longitude) if exist1349==1, atet vce(r)
eststo
teffects ipw (clubs_all_pc) (pog1349 lnpop share_cath25 bcollar25 latitude longitude) if exist1349==1, atet vce(r)
eststo

* g)

quietly teffects psmatch (pcNSentry_std) (clubs_pc_AM lnpop share_cath25 bcollar25, probit), atet 

tebalance summarize

tebalance density lnpop, saving(lnpop_gr)
tebalance density share_cath25, saving(share_cath25_gr)
tebalance density bcollar25, saving(bcollar25_gr)

gr combine lnpop_gr.gph share_cath25_gr.gph bcollar25_gr.gph

* h)

blopmatch (pog20s lnpop share_cath25 bcollar25 latitude longitude) (pog1349) if exist1349==1, atet

blopmatch (pcNSDAP285 lnpop share_cath25 bcollar25 latitude longitude) (pog1349) if exist1349==1, atet

blopmatch (clubs_all_pc lnpop share_cath25 bcollar25 latitude longitude) (pog1349) if exist1349==1, atet

* i)

logit pog20s pog1349  if exist1349==1

margins, dydx(pog1349)