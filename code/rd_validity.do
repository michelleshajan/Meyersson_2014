*******************************************************
* rd_validity.do
*
* RD plots, covariate balance, density test,
* and placebo cutoff tests.
*******************************************************

use "$data_raw/RD_Data_Meyersson_2014.dta", clear

*-------------------------------------------------------
* Main RD estimate
*-------------------------------------------------------

rdrobust Y X, c(0) p(1) kernel(triangular) bwselect(mserd)

*-------------------------------------------------------
*Treatment and outcome RD plots
*-------------------------------------------------------

rdplot T X, c(0) p(1) kernel(triangular) bwselect(mserd) ///
    graph_options( ///
        title("Treatment: Islamic mayor in 1994") ///
        xtitle("Islamic vote margin") ///
        ytitle("Islamic mayor") ///
    )

graph export "$figures/fig_treatment_rdplot.png", width(1200) replace

rdplot Y X, c(0) p(1) kernel(triangular) bwselect(mserd) ///
    graph_options( ///
        title("Outcome: Female high-school education") ///
        xtitle("Islamic vote margin") ///
        ytitle("Share women aged 15-20 with HSE") ///
    )

graph export "$figures/fig_outcome_rdplot.png", width(1200) replace

*-------------------------------------------------------
* Covariate balance
*-------------------------------------------------------

local covariates ///
    hischshr1520m i89 vshr_islam1994 partycount ///
    lpop1994 merkezi merkezp subbuyuk buyuk

tempname results
tempfile balance_results

postfile `results' str32 covariate double bandwidth estimate pval effn ///
    using `balance_results', replace

foreach var of local covariates {
    rdrobust `var' X, c(0) p(1) kernel(triangular) bwselect(mserd)

    post `results' ///
        ("`var'") ///
        (max(e(h_l), e(h_r))) ///
        (e(tau_cl)) ///
        (e(pv_rb)) ///
        (e(N_h_l) + e(N_h_r))
}

postclose `results'

preserve
use `balance_results', clear
export delimited using "$tables/tab_covariate_balance.csv", replace
restore

*-------------------------------------------------------
* Histogram around cutoff
*-------------------------------------------------------

gen side = X >= 0

twoway ///
    (histogram X if side == 0, ///
        width(1) color(red%50) fcolor(red%50) lcolor(red)) ///
    (histogram X if side == 1, ///
        width(1) color(blue%50) fcolor(blue%50) lcolor(blue)), ///
    legend(off) ///
    xline(0, lwidth(medthick) lcolor(black)) ///
    xtitle("Islamic vote margin") ///
    ytitle("Frequency") ///
    title("Distribution of observations around the cutoff")

graph export "$figures/fig_density_histogram.png", width(1200) replace

*-------------------------------------------------------
* 1.5 Density discontinuity test
*-------------------------------------------------------


rddensity X, c(0) plot ///
    graph_opt(title("Density Test for Islamic Vote Margin") ///
              subtitle("McCrary Density Discontinuity Test") ///
              xtitle("Islamic Vote Share Margin") ///
              ytitle("Estimated density") ///
              legend(off))

graph export "$figures/fig_mccrary_density.png", width(1200) replace
*-------------------------------------------------------
*Placebo cutoffs
*-------------------------------------------------------

rdrobust Y X if X < 0, c(-10)
estimates store placebo_m10

rdrobust Y X if X < 0, c(-5)
estimates store placebo_m5

rdrobust Y X if X >= 0, c(5)
estimates store placebo_p5

rdrobust Y X if X >= 0, c(10)
estimates store placebo_p10

esttab ///
    placebo_m10 placebo_m5 placebo_p5 placebo_p10 ///
    using "$tables/tab_placebo_tests.tex", ///
    title("Placebo discontinuity tests at alternative cutoffs") ///
    mtitles("c = -10" "c = -5" "c = 5" "c = 10") ///
    b(3) se(3) ///
    stats(N c pv_rb, fmt(0 0 3) ///
        labels("Observations" "Cutoff" "Robust p-value")) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    replace
