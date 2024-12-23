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
import excel "$bea/bea_qtr.xlsx", sheet("Sheet1") firstrow clear

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

*1.6: label yq
label define yqlabel 160 "2000q1" 161 "2000q2" 162 "2000q3" 163 "2000q4" 164 "2001q1" 165 "2001q2" 166 "2001q3" 167 "2001q4" 168 "2002q1" 169 "2002q2" 170 "2002q3" 171 "2002q4" 172 "2003q1" 173 "2003q2" 174 "2003q3" 175 "2003q4" 176 "2004q1" 177 "2004q2" 178 "2004q3" 179 "2004q4" 180 "2005q1" 181 "2005q2" 182 "2005q3" 183 "2005q4" 184 "2006q1" 185 "2006q2" 186 "2006q3" 187 "2006q4" 188 "2007q1" 189 "2007q2" 190 "2007q3" 191 "2007q4" 192 "2008q1" 193 "2008q2" 194 "2008q3" 195 "2008q4" 196 "2009q1" 197 "2009q2" 198 "2009q3" 199 "2009q4" 200 "2010q1" 201 "2010q2" 202 "2010q3" 203 "2010q4" 204 "2011q1" 205 "2011q2" 206 "2011q3" 207 "2011q4" 208 "2012q1" 209 "2012q2" 210 "2012q3" 211 "2012q4" 212 "2013q1" 213 "2013q2" 214 "2013q3" 215 "2013q4" 216 "2014q1" 217 "2014q2" 218 "2014q3" 219 "2014q4" 220 "2015q1" 221 "2015q2" 222 "2015q3" 223 "2015q4" 224 "2016q1" 225 "2016q2" 226 "2016q3" 227 "2016q4" 228 "2017q1" 229 "2017q2" 230 "2017q3" 231 "2017q4" 232 "2018q1" 233 "2018q2" 234 "2018q3" 235 "2018q4" 236 "2019q1" 237 "2019q2" 238 "2019q3" 239 "2019q4" 240 "2020q1" 241 "2020q2" 242 "2020q3" 243 "2020q4" 244 "2021q1" 245 "2021q2" 246 "2021q3" 247 "2021q4" 248 "2022q1" 249 "2022q2" 250 "2022q3" 251 "2022q4" 252 "2023q1" 253 "2023q2" 254 "2023q3" 255 "2023q4" 256 "2024q1" 257 "2024q2" 258 "2024q3"
label values yq yqlabel

*1.7: Save the data 
save "$bea/bea_qtr.dta", replace
