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

This code will create figures 5 and 7a from the FEDS note: https://www.federalreserve.gov/econres/notes/feds-notes/excess-savings-during-the-covid-19-pandemic-20221021.html
The sample period used in the FEDS note is 2020q1-2022q2 but the data avilable ranges from 1947Q1 to 2024q3. 
*/

*******
**(1)**
*******
use "$bea/bea_qtr.dta", clear

* 1.1: Set time restriction to 2015q1 to 2022q4
*220 = 2015q1
*249 = 2022q2
*258 = 2024q3
gen temp = yq
keep if temp >= 220 & temp <= 249

*extend the time period
*keep if temp >= 220 & temp <= 258

*1.2: keep variables of interest
keep temp DPI yq year DPI Personal_Outlays

*1.3: Get the trend for all variables of interest
foreach x in DPI Personal_Outlays {
    gen log_`x' = log(`x')                  // Create the log value
    reg log_`x' yq if temp >= 220 & temp < 239 // Regress log variable on time variable fitting 2015-2019. 
    predict log_trend, xb                   // Predict the fitted values
    gen trend_`x' = exp(log_trend)          // Transform back to level form
    drop log_trend log_`x'                  // Clean up intermediate variables
}

*1.4: Calculate deviations from trend following FEDS note: 
gen dpi_above_trend = DPI - trend_DPI                   // DPI above its trend
gen outlays_below_trend = trend_Personal_Outlays - Personal_Outlays // Personal Outlays below trend

*1.5: Calculate flow of excess savings
egen excess_savings_flow = rowtotal(dpi_above_trend outlays_below_trend)

*1.6: Cumulate the flows over time to calculate stock of excess savings
*Note: it is not annualized like all other figures. Hence why we divide by 4 below.
gen excess_savings_flow_quarterly = excess_savings_flow / 4
gen excess_savings_stock = sum(excess_savings_flow_quarterly)

*1.7: Label variables for ease of interpretation
label var dpi_above_trend "DPI above trend"
label var outlays_below_trend "Outlays below trend"
label var excess_savings_flow "Excess savings flow (quarterly)"
label var excess_savings_stock "Stock of excess savings (cumulative)"

*******
**(2)**
*******
*2.0: Figure 5a from FEDS note: Flow of Savings
twoway ///
    line excess_savings_flow yq if temp >= 240 & temp <= 249, lcolor(black) lpattern(solid) ///
    ytitle("Billions of Dollars, Annual Rate") ///
    xtitle("Year-Quarter") ///
    title("Flow of Savings")
*graph export "$figures/figure5a.eps", replace

*3.1: Figure 5b from FEDS note: Stock of Savings
twoway ///
    line excess_savings_stock yq if temp >= 240 & temp <= 249, lcolor(black) lpattern(solid) ///
    ytitle("Billions of Dollars") ///
    xtitle("Year-Quarter") ///
    title("Stock of Savings")
*graph export "$figures/figure5b.eps", replace

*******
**(3)**
*******
/* Figure 7a from FEDS note */ 

*3.1: Rename x-axis of the figure:
tostring temp, gen(time)
replace time = "2020Q1" if time == "240"
replace time = "2020Q2" if time == "241"
replace time = "2020Q3" if time == "242"
replace time = "2020Q4" if time == "243"
replace time = "2021Q1" if time == "244"
replace time = "2021Q2" if time == "245"
replace time = "2021Q3" if time == "246"
replace time = "2021Q4" if time == "247"
replace time = "2022Q1" if time == "248"
replace time = "2022Q2" if time == "249"

/* Extend to 2024: 
replace time = "2022Q3" if time == "250"
replace time = "2022Q4" if time == "251"
replace time = "2023Q1" if time == "252"
replace time = "2023Q2" if time == "253"
replace time = "2023Q3" if time == "254"
replace time = "2023Q4" if time == "255"
replace time = "2024Q1" if time == "256"
replace time = "2024Q2" if time == "257"
replace time = "2024Q3" if time == "258"
*/
* 3.2: Define income quartile shares: The shares are allocated based on the shares reported on the FEDS note. 
gen excess_savings_stock_q4 = excess_savings_stock * 0.54
gen excess_savings_stock_q3 = excess_savings_stock * 0.29
gen excess_savings_stock_q2 = excess_savings_stock * 0.14
gen excess_savings_stock_q1 = excess_savings_stock * 0.03

* 3.3: Create a stacked bar chart for income quartiles
graph bar excess_savings_stock_q1 excess_savings_stock_q2 excess_savings_stock_q3 excess_savings_stock_q4 if temp >= 240 & temp <= 249, over(time) stack bar(1, color(black)) bar(2, color(pink)) bar(3, color(lavender)) bar(4, color(green)) ytitle("Billions of Dollars") title("Stock of Excess Savings by Income Quartile") legend(off)
*graph export "$figures/figure7.eps", replace
