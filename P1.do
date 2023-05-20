*** Matching
clear all
* data

use "Dataset_Bowling_Replication_JPE.dta"

* c)

* d)

gen lnpop = ln(pop25)

*Dummies for size quintiles
xtile pop25_quintiles = pop25, nq(5)
tab  pop25_quintiles, gen(d_pop_quintile)

nnmatch pcNSentry_std clubs_pc_AM lnpop, m(1) robust(1) tc(att)
nnmatch pcNSentry_std clubs_pc_AM lnpop, m(3) robust(3) tc(att)
nnmatch pcNSentry_std clubs_pc_AM lnpop share_cath25 bcollar25, m(3) robust(3) tc(att)
nnmatch pcNSentry_std clubs_pc_AM lnpop share_cath25 bcollar25 latitude longitude, m(3) robust(3) tc(att)
nnmatch pcNSentry_std clubs_pc_AM lnpop share_cath25 bcollar25 latitude longitude, m(3) robust(3) tc(att) exact(pop25_quintiles landweimar_num)

* e)
reg pog20s pog1349 lnpop share_cath25 bcollar25 if exist1349==1, r beta 
nnmatch pog20s pog1349 lnpop share_cath25 bcollar25  latitude longitude if exist1349==1, m(3) robust(3) tc(att)
reg pcNSDAP285 pog1349 lnpop share_cath25 bcollar25 if exist1349==1, r beta 
nnmatch pcNSDAP285 pog1349 lnpop share_cath25 bcollar25  latitude longitude if exist1349==1, m(3) robust(3) tc(att)
reg clubs_all_pc pog1349 lnpop share_cath25 bcollar25 if exist1349==1, r beta 
nnmatch clubs_all_pc pog1349 lnpop share_cath25 bcollar25 latitude longitude if exist1349==1, m(3) robust(3) tc(att)

* f)

teffects ipw (pog20s) (pog1349 lnpop share_cath25 bcollar25 latitude longitude) if exist1349==1, atet vce(r)
teffects ipw (pcNSDAP285) (pog1349 lnpop share_cath25 bcollar25 latitude longitude) if exist1349==1, atet vce(r)
teffects ipw (clubs_all_pc) (pog1349 lnpop share_cath25 bcollar25 latitude longitude) if exist1349==1, atet vce(r)
* g)


* h)

blopmatch (pog20s lnpop share_cath25 bcollar25 latitude longitude) (pog1349) if exist1349==1, atet

blopmatch (pcNSDAP285 lnpop share_cath25 bcollar25 latitude longitude) (pog1349) if exist1349==1, atet

blopmatch (clubs_all_pc lnpop share_cath25 bcollar25 latitude longitude) (pog1349) if exist1349==1, atet

