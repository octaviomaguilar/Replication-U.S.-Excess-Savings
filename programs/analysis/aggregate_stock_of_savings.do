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

This code will create figure 5 from the FEDS note: https://www.federalreserve.gov/econres/notes/feds-notes/excess-savings-during-the-covid-19-pandemic-20221021.html
The sample period used in the FEDS note is 2020q1-2022q2 but the data avilable ranges from 1947Q1 to 2024q3. 

PARAMETERS:
1.) The baseline period for the program is 2015q1 - 2022q2. 
2.) The baseline period for the linear trend is 2015q1 - 2019q1.
3.) The baseline period for the excess savings figures is 2020q1 - 2022q2. 

The baseline parameters will yield results that match figure 5 in Aditya Aladangady, David Cho, Laura Feiveson, and Eugenio Pinto (2022)
After matching their results, you can then modify the parameters to your period of interest.  

*/

*******
**(1)**
*******
use "$bea/bea_qtr.dta", clear

*1.1: Set parameters that identify the start and end of sample:
local begin = yq(2015,1)
local end = yq(2022,2)

*1.1.1: Set parameters that identify the start and end of the linear trend:
local begin_trend = yq(2015,1)
local end_trend = yq(2019,4)

*1.1.2: Set parameters that identify the start and end of the excess savings figures: 
local begin_excess_savings = yq(2020,1)
local end_excess_savings = yq(2022,2)

*1.2: set time restriction:
keep if yq >= `begin' & yq <= `end'

*1.3: keep variables of interest
keep DPI PCE yq year DPI Personal_Outlays interest_payments

*1.4: Get the trend for all variables of interest
foreach x in DPI Personal_Outlays PCE interest_payments {
    gen log_`x' = log(`x')                  // Create the log value
    reg log_`x' yq if yq >= `begin_trend' & yq < `end_trend'     // Regress log variable on time variable: fitting specified time. 
    predict log_trend, xb                   // Predict the fitted values
    gen trend_`x' = exp(log_trend)          // Transform back to level form
    drop log_trend log_`x'                  
}

*1.5: Calculate deviations from trend following FEDS note: 
gen dpi_above_trend = DPI - trend_DPI                   // DPI above its trend
gen outlays_below_trend = trend_interest_payments - interest_payments // Outlays below trend
gen pce_below_trend = trend_PCE - PCE					// PCE below trend

*1.6: Calculate flow of excess savings
egen excess_savings_flow = rowtotal(dpi_above_trend outlays_below_trend pce_below_trend)

*1.7: Cumulate the flows over time to calculate stock of excess savings
*Note: it is not annualized like all other figures. Hence why we divide by 4 below.
gen excess_savings_flow_quarterly = excess_savings_flow / 4
gen excess_savings_stock = sum(excess_savings_flow_quarterly)

*1.8: Label variables for ease of interpretation
label var dpi_above_trend "DPI above trend"
label var outlays_below_trend "Outlays below trend"
label var excess_savings_flow "Excess savings flow (quarterly)"
label var excess_savings_stock "Stock of excess savings (cumulative)"

*******
**(2)**
*******
*2.0: Figure 5a from FEDS note: Flow of Savings
twoway ///
    line excess_savings_flow yq if yq >= `begin_excess_savings' & yq <= `end_excess_savings', lcolor(black) lpattern(solid) ///
    ytitle("Billions of Dollars, Annual Rate") ///
    xtitle("Year-Quarter") ///
    title("Flow of Savings")
*graph export "$figures/figure5a.eps", replace

*3.1: Figure 5b from FEDS note: Stock of Savings
twoway ///
    line excess_savings_stock yq if yq >= `begin_excess_savings' & yq <= `end_excess_savings', lcolor(black) lpattern(solid) ///
    ytitle("Billions of Dollars") ///
    xtitle("Year-Quarter") ///
    title("Stock of Savings")
*graph export "$figures/figure5b.eps", replace

