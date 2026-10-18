*******************************************************
* rd_estimation.do
*
* RD plot
* local-linear estimate, and kernel robustness.
*******************************************************

use "$data_raw/RD_Data_Meyersson_2014.dta", clear

*-------------------------------------------------------
* RD plot with 40 evenly spaced bins
*-------------------------------------------------------

rdplot Y X, nbins(40) binspos(es) ///
    graph_options( ///
        title("RD plot: outcome versus running variable") ///
        xtitle("Islamic vote margin") ///
        ytitle("Share women aged 15-20 with HSE") ///
    )

graph export "$figures/fig_rdplot_40bins.png", width(1200) replace

*-------------------------------------------------------
* Local-linear RD estimate, triangular kernel
*-------------------------------------------------------

rdrobust Y X, c(0) p(1) kernel(triangular) bwselect(mserd)

scalar tau_tri = e(tau_cl)
scalar se_tri  = e(se_tau_cl)
scalar p_tri   = e(pv_rb)

di as txt "Triangular-kernel RD estimate:"
di as res "tau = " %9.4f tau_tri ///
    "; SE = " %9.4f se_tri ///
    "; p-value = " %9.4f p_tri

*-------------------------------------------------------
* Manual local-linear estimate
*-------------------------------------------------------

scalar h_left  = e(h_l)
scalar h_right = e(h_r)

preserve
    keep if X < 0 & X >= -h_left
    reg Y X
    scalar intercept_left = _b[_cons]
restore

preserve
    keep if X >= 0 & X <= h_right
    reg Y X
    scalar intercept_right = _b[_cons]
restore

scalar tau_manual = intercept_right - intercept_left

di as txt "Manual local-linear RD estimate:"
di as res "Left intercept = " %9.4f intercept_left
di as res "Right intercept = " %9.4f intercept_right
di as res "Manual tau = " %9.4f tau_manual

*-------------------------------------------------------
* Uniform-kernel robustness
*-------------------------------------------------------

rdrobust Y X, c(0) p(1) kernel(uniform) bwselect(mserd)

scalar tau_unif = e(tau_cl)
scalar se_unif  = e(se_tau_cl)
scalar p_unif   = e(pv_rb)

di as txt "Uniform-kernel RD estimate:"
di as res "tau = " %9.4f tau_unif ///
    "; SE = " %9.4f se_unif ///
    "; p-value = " %9.4f p_unif
