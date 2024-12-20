cap cls
clear all
set more off

global home = "/mq/scratch/m1oma00/oma_projects/excess_savings"
global data "$home/data"
global bea "$data/bea"
global figures "$home/figures"

/*This program was written by Octavio M. Aguilar. If there are any questions or concerns 
please email me: octavio.m.aguilar@frb.gov.

To use this program please change the home global above to match your computer. 

This code will create figures 1-4 in the FEDS note: https://www.federalreserve.gov/econres/notes/feds-notes/excess-savings-during-the-covid-19-pandemic-20221021.html
The sample period used in the FEDS note is 2015-2022q2 but the data avilable ranges from 1947Q1 to 2024q3. 
*/

*******
**(1)**
*******
use "$bea/bea_qtr.dta", clear

*1.1: set time restriction:
gen temp = yq
order yq year temp

*220 = 2015q1
*249 = 2022q2
*258 = 2024q3

keep if temp >= 220 & temp <= 249
*keep if temp >= 220 & temp <= 258

*get the trend for all variables of interest: 
foreach x in Compensation_of_employees Proprietors_income Rent_Int_Div Rental_income Interest_income Dividend_income Personal_transfer_receipts Unemp_insurance Other_transfer_receipts Social_insurance Personal_taxes DPI PCE interest_payments Transfer_payments Personal_saving Goods Services Saving_percentage_DPI Personal_Outlays {
	
	gen log_`x' = log(`x')   // Create the log value

	reg log_`x' yq if temp >= 220 & temp < 239     // Regress log variable on time variable fitting 2015-2019. 
	predict log_trend, xb                        // Predict the fitted values
	gen trend_`x' = exp(log_trend)            // Transform back to level form
	drop log_trend
}

*******
**(2)**
*******
*2.1: Figure 1 from FEDS note: Personal Saving Rate
twoway ///
    line Saving_percentage_DPI yq, lcolor(black) lpattern(solid) || ///
    line trend_Saving_percentage_DPI yq, lcolor(blue) lpattern(dash) ///
    legend(order(1 "Actual" 2 "Log Linear Trend 2015-2019")) ///
    ytitle("Saving percentage - DPI") ///
    xtitle("Year-Quarter") ///
    title("Personal Saving Rate")
graph export "$figures/figure1.eps", replace

*******
**(3)**
*******
*3.0: Personal Outlays (not in FEDS but still worth plotting)
twoway ///
    line Personal_Outlays yq, lcolor(black) lpattern(solid) || ///
    line trend_Personal_Outlays yq, lcolor(blue) lpattern(dash) ///
    legend(order(1 "Actual" 2 "Log Linear Trend 2015-2019")) ///
    ytitle("Billions of Dollars, Annual Rate") ///
    xtitle("Year-Quarter") ///
    title("Personal Outlays")

*3.1: Figure 2a from FEDS note: DPI
twoway ///
    line DPI yq, lcolor(black) lpattern(solid) || ///
    line trend_DPI yq, lcolor(blue) lpattern(dash) ///
    legend(order(1 "Actual" 2 "Log Linear Trend 2015-2019")) ///
    ytitle("Billions of Dollars, Annual Rate") ///
    xtitle("Year-Quarter") ///
    title("Disposable Personal Income")
graph export "$figures/figure2a.eps", replace

*3.2: Figure 2b from FEDS note: Compensation of employees
twoway ///
    line Compensation_of_employees yq, lcolor(black) lpattern(solid) || ///
    line trend_Compensation_of_employees yq, lcolor(blue) lpattern(dash) ///
    legend(order(1 "Actual" 2 "Log Linear Trend 2015-2019")) ///
    ytitle("Billions of Dollars, Annual Rate") ///
    xtitle("Year-Quarter") ///
    title("Compensation of Employees")
graph export "$figures/figure2b.eps", replace

*3.3: Figure 2c from FEDS note: Proprietors' Income
twoway ///
    line Proprietors_income yq, lcolor(black) lpattern(solid) || ///
    line trend_Proprietors_income yq, lcolor(blue) lpattern(dash) ///
    legend(order(1 "Actual" 2 "Log Linear Trend 2015-2019")) ///
    ytitle("Billions of Dollars, Annual Rate") ///
    xtitle("Year-Quarter") ///
    title("Proprietors' Income")
graph export "$figures/figure2c.eps", replace

*3.4: Figure 2d from FEDS note: Rental, Interest, and Dividend Income: CHECK THIS AGAIN-- DOESN'T LOOK RIGHT
twoway ///
    line Rent_Int_Div yq, lcolor(black) lpattern(solid) || ///
    line trend_Rent_Int_Div yq, lcolor(blue) lpattern(dash) ///
    legend(order(1 "Actual" 2 "Log Linear Trend 2015-2019")) ///
    ytitle("Billions of Dollars, Annual Rate") ///
    xtitle("Year-Quarter") ///
    title("Rental, Interest, and Dividend Income")
graph export "$figures/figure2d.eps", replace

*3.5: Figure 2e from FEDS note: Personal Current Transfer Receipts
twoway ///
    line Personal_transfer_receipts yq, lcolor(black) lpattern(solid) || ///
    line trend_Personal_transfer_receipts yq, lcolor(blue) lpattern(dash) ///
    legend(order(1 "Actual" 2 "Log Linear Trend 2015-2019")) ///
    ytitle("Billions of Dollars, Annual Rate") ///
    xtitle("Year-Quarter") ///
    title("Personal Current Transfer Receipts")
graph export "$figures/figure2e.eps", replace

*3.6: Figure 2f from FEDS note: Personal Current Taxes
twoway ///
    line Personal_taxes yq, lcolor(black) lpattern(solid) || ///
    line trend_Personal_taxes yq, lcolor(blue) lpattern(dash) ///
    legend(order(1 "Actual" 2 "Log Linear Trend 2015-2019")) ///
    ytitle("Billions of Dollars, Annual Rate") ///
    xtitle("Year-Quarter") ///
    title("Personal Current Taxes")
graph export "$figures/figure2f.eps", replace

*******
**(4)**
*******
*4.1: Figure 3a from FEDS note: Nominal PCE
twoway ///
    line PCE yq, lcolor(black) lpattern(solid) || ///
    line trend_PCE yq, lcolor(blue) lpattern(dash) ///
    legend(order(1 "Actual" 2 "Log Linear Trend 2015-2019")) ///
    ytitle("Billions of Dollars, Annual Rate") ///
    xtitle("Year-Quarter") ///
    title("Nominal PCE")
graph export "$figures/figure3a.eps", replace

*4.2: Figure 3c from FEDS note: Nominal PCE: Goods
twoway ///
    line Goods yq, lcolor(black) lpattern(solid) || ///
    line trend_Goods yq, lcolor(blue) lpattern(dash) ///
    legend(order(1 "Actual" 2 "Log Linear Trend 2015-2019")) ///
    ytitle("Billions of Dollars, Annual Rate") ///
    xtitle("Year-Quarter") ///
    title("Nominal PCE: Goods")
graph export "$figures/figure3b.eps", replace

*4.3: Figure 3c from FEDS note: Nominal PCE: Services
twoway ///
    line Services yq, lcolor(black) lpattern(solid) || ///
    line trend_Services yq, lcolor(blue) lpattern(dash) ///
    legend(order(1 "Actual" 2 "Log Linear Trend 2015-2019")) ///
    ytitle("Billions of Dollars, Annual Rate") ///
    xtitle("Year-Quarter") ///
    title("Nominal PCE: Services")
graph export "$figures/figure3c.eps", replace

*******
**(5)**
*******
*5.1: Figure 4 from FEDS note: Personal Interest Payments
twoway ///
    line interest_payments yq, lcolor(black) lpattern(solid) || ///
    line trend_interest_payments yq, lcolor(blue) lpattern(dash) ///
    legend(order(1 "Actual" 2 "Log Linear Trend 2015-2019")) ///
    ytitle("Billions of Dollars, Annual Rate") ///
    xtitle("Year-Quarter") ///
    title("Personal Interest Payments")
graph export "$figures/figure4.eps", replace
