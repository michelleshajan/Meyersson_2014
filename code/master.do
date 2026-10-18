*******************************************************
* master.do
*
* Master script for the RD based on
* Meyersson (2014).
*******************************************************

clear all
set more off
version 17

*-------------------------------------------------------
* 1. USER SETTINGS: EDIT ONLY THIS LINE
*-------------------------------------------------------

* Set this to the location of the cloned repository.
global root "C:/Users/miche/Downloads/rd-meyersson-2014"

*-------------------------------------------------------
* 2. PROJECT PATHS
*-------------------------------------------------------

global data_raw "$root/data/raw"
global code     "$root/code"
global output   "$root/output"
global tables   "$root/output/tables"
global figures  "$root/output/figures"


cap mkdir "$output"
cap mkdir "$tables"
cap mkdir "$figures"


*-------------------------------------------------------
* 4. REQUIRED PACKAGES
*-------------------------------------------------------

foreach pkg in rdrobust rddensity estout {
    cap which `pkg'
    if _rc ssc install `pkg', replace
}
*-------------------------------------------------------
* 5. RUN ANALYSIS
*-------------------------------------------------------

do "$code/rd_validity.do"
do "$code/rd_estimation.do"


