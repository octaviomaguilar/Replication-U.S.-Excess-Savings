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

This code will extend figure 7a from the FEDS note: https://www.federalreserve.gov/econres/notes/feds-notes/excess-savings-during-the-covid-19-pandemic-20221021.html
The sample period will 

PARAMETERS:
1.) The period for the program is 2015q1 - latest data point. 
2.) The baseline period for the linear trend is 2015q1 - 2019q1.

*/

*******
**(1)**
*******
use "$bea/bea_qtr.dta", clear

*1.1: Set parameters that identify the start and end of sample:
local begin = yq(2015,1)
local end = yq(2024,3)

*1.1.1: Set parameters that identify the start and end of the linear trend:
local begin_trend = yq(2015,1)
local end_trend = yq(2019,4)

*1.1.2: Set parameters that identify the start and end of the excess savings figures: 
local begin_excess_savings = yq(2020,1)
local end_excess_savings = yq(2024,3)

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
*keep year-quarter indicator and excess savings variable:
keep yq excess_savings_stock

*merge in time-varying shares that match the FEDS note. This was calculated in the excel "calculate_time_varying_shares.xlsx".
merge 1:1 yq using "$data/time_varying_shares.dta", nogen

*keep data only for 2020-latest data point
keep if yq >= yq(2020,1)

*2.2.1: Apply constant shares for 2022q2-latest data point 
replace tv_share_q1 = 0.05 if tv_share_q1 == . 
replace tv_share_q2 = 0.15 if tv_share_q2 == .
replace tv_share_q3 = 0.28 if tv_share_q3 == .
replace tv_share_q4 = 0.54 if tv_share_q4 == .

* 2.2: Define income quartile shares for 2020-2022q2: The shares are time varying and are allocated based on the shares reported on the FEDS note. 
gen excess_savings_stock_q4 = tv_share_q4 * excess_savings_stock
gen excess_savings_stock_q3 = tv_share_q3 * excess_savings_stock
gen excess_savings_stock_q2 = tv_share_q2 * excess_savings_stock
gen excess_savings_stock_q1 = tv_share_q1 * excess_savings_stock

* 2.3: Create a stacked bar chart for income quartiles
graph bar excess_savings_stock_q1 excess_savings_stock_q2 excess_savings_stock_q3 excess_savings_stock_q4 if yq >= `begin_excess_savings' & yq <= `end_excess_savings', over(yq) stack bar(1, color(black)) bar(2, color(pink)) bar(3, color(lavender)) bar(4, color(green)) ytitle("Billions of Dollars") title("Stock of Excess Savings by Income Quartile") legend(off)
graph export "$figures/figure7_2024.eps", replace

*2.4: export the final dataset with excess savings by income quartile:
keep yq excess_savings_stock_q4 excess_savings_stock_q3 excess_savings_stock_q2 excess_savings_stock_q1

save "$data/output/excess_savings_quartiles_extension.dta", replace
export excel "$data/output/excess_savings_quartiles_extension.xlsx", firstrow(variables) replace
