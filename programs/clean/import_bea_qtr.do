cap cls
clear all
set more off

global home = "/mq/scratch/m1oma00/oma_projects/excess_savings"
global data "$home/data"
global bea "$data/bea"

/*This program was written by Octavio M. Aguilar. If there are any questions or concerns 
please email me: octavio.m.aguilar@frb.gov.

To use this program please change the home global above to match your computer. 

This program will import and clean the BEA NIPA Data Archive (section 2) from: https://apps.bea.gov/histdatacore/fileStructDisplay.html?theID=12032&HMI=7&oldDiv=National%20Accounts&year=2024&quarter=,%20Q3&ReleaseDate=November-27-2024&Vintage=Second

*/
*******
**(1)**
*******
*1.1: import BEA data
import excel "/mq/scratch/m1oma00/oma_projects/excess_savings/data/bea/bea_qtr.xlsx", sheet("Sheet1") firstrow clear

*1.2: keep variables of interest
keep time Compensation_of_employees Proprietors_income Rental_income Interest_income Dividend_income Personal_transfer_receipts Unemp_insurance Other_transfer_receipts Social_insurance Personal_taxes DPI PCE interest_payments Transfer_payments Personal_saving Goods Services Saving_percentage_DPI Personal_Outlays

*1.3: set correct timing convention for Stata. 

*1.3.1: set year indicator
gen year = substr(time,1,4)
destring year, replace

*1.3.2: set year-quarter indicator
gen yq = quarterly(time, "YQ")
format yq %tq
drop time
order yq year

*1.4: combine Rental income, interest income, and dividend income 
egen Rent_Int_Div = rowtotal(Rental_income Interest_income Dividend_income)

*1.5: Convert variables of interest to billions of dollars (they are currently in millions)
foreach x in Compensation_of_employees Proprietors_income Rent_Int_Div Rental_income Interest_income Dividend_income Personal_transfer_receipts Unemp_insurance Other_transfer_receipts Social_insurance Personal_taxes DPI PCE interest_payments Transfer_payments Personal_saving Goods Services Personal_Outlays {
	replace `x' = `x'/1000
}
 
*1.6: Save the data 
save "$bea/bea_qtr.dta", replace
