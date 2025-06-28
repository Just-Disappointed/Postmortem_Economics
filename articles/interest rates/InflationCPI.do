********************MONETARY POLICY TRANSMISSION MALAWI 

*change directory
cd "C:\Users\USER\Documents\stata code\interest rates"

****Importation
import excel "C:\Users\USER\Documents\Database backup and stuff\database data\interestRates.xlsx", sheet("Sheet1") firstrow clear
keep Date PolicyR SaveDR mon3DR LendingR Spread TBR91 TBR182 TBR384 TBRall INTBRate

destring TBR91 TBR182 TBR384 TBRall, generate (tbr91s tbr182s tbr364s TBRalls) force


drop TBR91 TBR182 TBR384 TBRall


****Visualizations 
tsset Date
tsline PolicyR LendingR tbr91s tbr182s tbr364s TBRalls INTBRate


*****Visualization of Policy Rate and Interbank Rtate
tsline PolicyR INTBRate if Date >= Date[475]
cor PolicyRL INTBRate if Date >= Date[475]

*****Visualization of Policy Rate and Lending Rate
tsline PolicyR LendingR



tsline PolicyR TBRalls tbr91s tbr182s tbr364s
label var INTBRate "Interbank Rate"
tsline PolicyR TBRalls
tsline PolicyR INTBRate if Date >= Date[218], title("Lagged Interbank Rate and Policy Rate") bgcolor(white) plotregion(color(white)) graphregion(color(white))
cor PolicyR INTBRate if Date >= Date[218]

graph save IntBpol, replace

****Save DTA File
save "C:\Users\USER\Documents\stata code\interest rates\PolicyTransmission.dta", replace 


****Merge With Inflation
import excel "C:\Users\USER\Documents\Database backup and stuff\database data\MonthlyCPI.xlsx", sheet("MonthlyCPI") firstrow clear 
merge 1:1 Date using "C:\Users\USER\Documents\stata code\interest rates\PolicyTransmission.dta"

***A bit of cleaning 
drop if HeadCPI == . | HeadInf == . | FoodCPI == .
drop if PolicyR == .
gen time=_n
tsset time
*tsset Date

****Visualize 
/* lets keep the old ones for memory 
tsline NFoodInf PolicyR if Date > Date[252]
cor NFoodInf PolicyR if Date > Date[252]
cor NFoodInf polRlag if Date > Date[252]
*/
tsline NFoodInf PolicyR
cor NFoodInf PolicyR
cor NFoodInf polRlag


*PolicyR[_n-1]

tsline HeadInf PolicyR
tsline HeadInf L.PolicyR
cor HeadInf PolicyR


tsline FoodInf PolicyR
cor FoodInf PolicyR



****the three correlations together 
label var HeadInf "Headline Inflation"
label var PolicyR "Policy Rate"
label var FoodInf "Food Inflation"
label var NFoodInf "Non-Food Inflation"

gen PolicyRL = PolicyR[_n-1]

tsline HeadInf PolicyRL
cor HeadInf PolicyRL
cor HeadInf PolicyR

*tsline HeadInf PolicyR, title("Lagged Policy Rate and Inflation") bgcolor(white) plotregion(color(white)) graphregion(color(white))
graph save HeadInfPol, replace 

*tsline FoodInf PolicyRL
*cor FoodInf PolicyRL
tsline FoodInf PolicyR, title("Lagged Policy Rate and Food Inflation") bgcolor(white) plotregion(color(white)) graphregion(color(white))
graph save FoodInfPol, replace


*tsline NFoodInf PolicyRL
*cor NFoodInf PolicyRL
tsline NFoodInf PolicyR, title("Lagged Policy Rate and Nonfood Inflation") bgcolor(white) plotregion(color(white)) graphregion(color(white))
graph save NfoodInfPol, replace

graph combine HeadInfPol.gph FoodInfPol.gph NfoodInfPol.gph

*****Regressions for Refinement

**test  for stationarity
*visual test

*Iflation
tsline HeadInf
*there is seasonality
*trend seems to be upwards, is that normal? 


*Interest rate
tsline PolicyR
*i think its more or less clean but there may be some stationarity 
*further tests necessary 

*dicky-fuller test 
**for head inflation
dfuller HeadInf
dfuller HeadInf, regress
dfuller HeadInf, drift regress
dfuller HeadInf, lag(1) drift regress
dfuller HeadInf, lag(2) drift regress
****its stationary with 2 lags 

**for policy rate 
dfuller PolicyR
dfuller PolicyR, drift
dfuller PolicyR, lag(1) drift
dfuller PolicyR, lag(2) drift
*this one is stationary, yay


**Now lets do an autocorrelation and partial autocorrelation test
corrgram PolicyR, lag(20)
corrgram HeadInf, lag(20)

**okay, two lags for each


***Now lets run the regression!

gen HeadInfL = HeadInf[_n-1]
gen HeadInfLL = HeadInf[_n-2]
gen HeadInfLLL = HeadInf[_n-3]
gen PolicyRR = PolicyR[_n-1]
gen PolicyRRR = PolicyR[_n-2]
gen PolicyRRRR = PolicyR[_n-3]


reg HeadInf PolicyR HeadInfL
reg HeadInf PolicyR PolicyRR PolicyRRR HeadInfL HeadInfLL
reg HeadInf PolicyR PolicyRR HeadInfL HeadInfLL




**We can also do a command to find the optimal lags 
varsoc HeadInf
*three lags 

varsoc PolicyR
*four lags 

reg HeadInf PolicyR PolicyRR PolicyRRR PolicyRRRR HeadInfL HeadInfLL HeadInfLLL
reg HeadInf PolicyR PolicyRR PolicyRRR PolicyRRRR HeadInfL HeadInfLL


reg HeadInf PolicyR PolicyRR PolicyRRR PolicyRRRR HeadInfL HeadInfLL HeadInfLLL, robust
*THIS WAS SUPPOSED TO BE SIMPLE
/*
Okay, so what ive done here is use the autocorrelatio function and the varsoc
command to select my lags and i have accepted four lags for policyrate. For 
headinf i had to choose between 2 and 3. I wanted 2 based on the autocorrelation
function but the inclusion of the other lag increased the adjusted R squared so 
I think its okay. 
However, there is statistical insignificance in the policy rate variable which
I do not agree with based on the theory and the fact that on smaller regressions
there is statistical significance. I think this is omitted variable bias 
*/
*okay, lets look at other variables 

*Multicollinearity

vif

    Variable |       VIF       1/VIF  
-------------+----------------------
    PolicyRR |     25.28    0.039557
   PolicyRRR |     24.77    0.040374
    HeadInfL |      1.16    0.861311
-------------+----------------------
    Mean VIF |     17.07

. 
