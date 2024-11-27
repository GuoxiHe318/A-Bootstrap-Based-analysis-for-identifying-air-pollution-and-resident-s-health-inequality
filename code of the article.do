*A Bootstrap-Based analysis for identifying air pollution and resident's health inequality: An empirical research on CFPS data

****Install all the packages might need
// //if your stata has already installed all these, ignore them
// ssc install ftools
// ssc install sum2docx
// ssc install reghdfe
// ssc install estout
// net install sgmediation2, from("https://tdmize.github.io/data/sgmediation2")


**1. Data Preprocess

**1) CFPS2018.dta

use  "C:\your\desire\file\cfps2018person_202012" ,clear  //files with absolute path

*Make the features       
tostring pid,format(%100.0g) gen(id_str)    //id code
gen id  = "CFPS2018_" + id_str       
gen datasource = "CFPS"                     //data source
gen year = 2018                             //year

*Individual features
label var gender"gender 1=male 0=female"        //gender code  

gen birth = ibirthy if ibirthy > 0              //year of born

drop if age < 0                             //drop out error

gen eduy   = cfps2018eduy if cfps2018eduy >= 0  //year of schooling 
replace eduy = 3 if cfps2018edu == 1 & eduy == .
replace eduy = 6 if cfps2018edu == 2 & eduy == .
replace eduy = 9 if cfps2018edu == 3 & eduy == .
replace eduy = 12 if cfps2018edu == 4 & eduy == .
replace eduy = 15 if cfps2018edu == 5 & eduy == .
replace eduy = 16 if cfps2018edu == 6 & eduy == .
replace eduy = 19 if cfps2018edu == 7 & eduy == .
replace eduy = 24 if cfps2018edu == 8 & eduy == .

gen edu = 0 if cfps2018edu==1                   //educational level
replace edu = 1 if cfps2018edu==2
replace edu = 2 if cfps2018edu==3
replace edu = 3 if cfps2018edu==4
replace edu = 4 if cfps2018edu==5
replace edu = 5 if cfps2018edu==6 | edu==7 | edu==8
replace edu = . if cfps2018edu==79

label var edu"Educational Level"
label define edulabel 0 "Uneducated" 1 "Primary" 2 "Middle School" 3 "High School" 4 "College" 5 "Bachalor and above"  //define the label of variable edu
label value edu edulabel


recode qea0  (2 3 = 1 "Married")(1 4 5 = 0 "Unmarried"), gen(marriage) //marriage

recode qa301 (1 7= 1 "Rural")(3 = 0 "Urban")(5 79 =.), gen(residence)  //residence

gen province = provcd18 if  provcd18 >0                		           //province

rename urban18 urban
drop if urban < 0
keep if age >= 16  

*Social Economical Status
drop if qg303code_isei ==.
gen sei = qg303code_isei

rename qg303code_isei ISEI
replace ISEI = 1 if ISEI < 40
replace ISEI = 2 if ISEI >= 40 & ISEI < 65
replace ISEI = 3 if ISEI >=65
label define ISEIlabel 1"low" 2"Medium" 3"High"
label value ISEI ISEIlabel


gen jobcode = qg303code if qg303code > 0 & qg303code <= 99999 //vocation

gen lgyincome = ln(income)    //log of annual income

*relative variables of health
gen height=qp101
gen weight=qp102
gen bmi=weight/2/(height/100)^2  //bmi

recode qp401(1=1)(0=0),gen(chronic)                //Chronic disease
label define Chronic_label 0"no" 1"yes" 
label value chronic Chronic_label

recode qp201 (1=5)(2=4)(3=3)(4=2)(5=1) ,gen(health) //Self-evaluated health level
label var health "code 1-5, the bigger the healthier"  

gen depression=cesd8  //mental health

gen exercise=qp702
replace exercise = 0 if exercise < 0


gen well_being=qm2016

recode qq301(1=1)(0=0)(79=.),gen(drink)
label var drink"1=yes,0=no"

recode qq201(1=1)(0=0)(79=.),gen(smoke)
label var smoke"1=yes,0=no"



*drop missing value
foreach var in $fv {
    drop if `var' == .|`var' <0
}
gen huwai = qg20
* keep subsample
keep if subsample

keep  pid fid18 fid18 fid16 fid14 fid12 fid10 provcd18 countyid18 cid18 id datasource year  edu  eduy birth  marriage residence age gender health height weight  bmi urban chronic  jobcode ISEI smoke drink income lgyincome depression well_being exercise huwai sei

rename provcd18 provcd
rename  cid18 cid

save "C:\your\desire\file\cfps18.dta",replace

************************************
**2) CFPS2020.dta

use  "C:\your\desire\file\cfps2020person_202306.dta" ,clear  //files with absolute path

*Features       
tostring pid,format(%100.0g) gen(id_str)    //id code
gen id  = "CFPS2020_" + id_str       
gen datasource = "CFPS"                     //data source
gen year = 2020                             //year
*Individual features
label var gender"gender 1=male 0=female"          //gender code  

gen birth = ibirthy if ibirthy > 0              //year of born

drop if age < 0                                 //drop out age error

gen eduy   = cfps2020eduy if cfps2020eduy >= 0  //year of schooling 
replace eduy = 3 if cfps2020eduy == 1 & eduy == .
replace eduy = 6 if cfps2020eduy == 2 & eduy == .
replace eduy = 9 if cfps2020eduy == 3 & eduy == .
replace eduy = 12 if cfps2020eduy == 4 & eduy == .
replace eduy = 15 if cfps2020eduy == 5 & eduy == .
replace eduy = 16 if cfps2020eduy == 6 & eduy == .
replace eduy = 19 if cfps2020eduy == 7 & eduy == .
replace eduy = 24 if cfps2020eduy == 8 & eduy == .

gen edu = 0 if cfps2020edu==1                   //educational level
replace edu = 1 if cfps2020edu==2
replace edu = 2 if cfps2020edu==3
replace edu = 3 if cfps2020edu==4
replace edu = 4 if cfps2020edu==5
replace edu = 5 if cfps2020edu==6 | edu==7 | edu==8
replace edu = . if cfps2020edu==79

label define edulabel 0"Uneducated" 1"Primary" 2"Middle School" 3"High School" 4"College" 5"Bachalor and above"  //define the label of variable edu
label value edu edulabel

recode qea0  (2 3 = 1 "Married")(1 4 5 = 0 "Unmarried"), gen(marriage) //marriage

recode qa301 (1 7= 1 "Rural")(3 = 0 "Urban")(5  79 =.), gen(residence) //residence

gen province = provcd20 if provcd20 >0                		           //province

rename urban20 urban
drop if urban < 0
keep if age >= 16  

*Social Economical Status
drop if qg303code_isei ==.
gen sei = qg303code_isei

rename qg303code_isei ISEI
replace ISEI = 1 if ISEI < 40
replace ISEI = 2 if ISEI >= 40 & ISEI < 65
replace ISEI = 3 if ISEI >=65
label define ISEIlabel 1"low" 2"Medium" 3"High"
label value ISEI ISEIlabel

gen jobcode = qg303code if qg303code > 0 & qg303code <= 99999 //vocation

gen lgyincome = ln(emp_income)    //log of annual income


*relative variables of health
gen height=qp101
gen weight=qp102
gen bmi=weight/2/(height/100)^2  //bmi

recode qp401(1=1)(0=0),gen(chronic)                //Chronic disease
label define Chronic_label 0"no" 1"yes" 
label value chronic Chronic_label

recode qp201 (1=5)(2=4)(3=3)(4=2)(5=1) ,gen(health) //Self-evaluated health level
label var health "code 1-5, the bigger the healthier"  

gen depression=cesd8  //mental health

gen exercise=qp702
replace exercise = 0 if exercise < 0


gen well_being=qm2016

recode qq301(1=1)(0=0)(79=.),gen(drink)
label var drink"1=yes,0=no"

recode qq201(1=1)(0=0)(79=.),gen(smoke)
label var smoke"1=yes,0=no"



*drop missing value
foreach var in $fv {
    drop if `var' == .|`var' <0
}
gen huwai = qg20
* keep subsample
keep if subsample

keep  pid fid20 fid18 fid16 fid14 fid12 fid10 provcd20 countyid20 cid20 id datasource year  edu  eduy birth  marriage residence age gender health height weight  bmi urban chronic jobcode ISEI smoke drink emp_income lgyincome depression well_being exercise huwai sei


rename provcd20 provcd
rename  cid20 cid

save "C:\your\desire\file\cfps20.dta",replace


use "C:\your\desire\file\cfps18.dta",clear
append using "C:\your\desire\file\cfps20.dta"
**Merge data
merge m:1 provcd year using "C:\your\desire\file\AQI.dta", force   //files with absolute path
keep if _merge==3
drop _merge

*Region Group

label define province 14	"Shanxi" 21	"Liaoning" 22	"Jilin" 23	"Heilongjiang" 33	"Zhejiang" 36	"Jiangxi" 37	"Shandong" 41	"Henan" 52	"Guizhou" 61	"Shaanxi" 62	"Gansu" 63	"Qinghai" 64	"Ningxia" 65	"Xinjiang" 11	"Beijing" 12	"Tianjin" 13	"Hebei" 42	"Hubei" 43	"Hunan" 45	"Guangxi" 53	"Yunnan" 34	"Anhui" 35	"Fujian" 44	"Guangdong" 15	"Neimenggu" 31	"Shanghai" 32	"Jiangsu" 51	"Sichuan" 46	"Hainan" 54	"Tibet" 50 "Chongqing"
label value provcd province
decode provcd ,gen(prvname)

gen region = 1 if prvname =="Beijing"|prvname =="Tianjin"|prvname =="Hebei"|prvname =="Shandong"|prvname =="Jiangsu"|prvname =="Shanghai"|prvname =="Zhejiang"|prvname =="Fujian"|prvname =="Guangdong"|prvname =="Hainan"|prvname == "Liaoning"

replace  region = 2 if prvname == "Shanxi"|prvname =="Anhui"|prvname =="Jiangxi"|prvname =="Henan"|prvname =="Hubei"|prvname =="Hunan"|prvname =="Jilin"|prvname =="Heilongjiang"

replace region = 3 if prvname =="Chongqing"|prvname =="Sichuan"|prvname =="Guizhou"|prvname =="Yunnan"|prvname =="Tibet"|prvname =="Shaanxi"|prvname =="Gansu"|prvname =="Qinghai"|prvname =="Ningxia"|prvname =="Xinjiang"|prvname =="Guangxi"|prvname == "Neimenggu"


replace marriage = . if marriage < 0
replace drink= . if drink < 0
replace smoke= . if smoke < 0

drop if chronic < 0
drop if depression < 0
drop if health < 0
drop if well_being < 0

**2. Analysis

**1) Descriptive Analysis
drop if depression == .
replace huwai = . if huwai < 0|huwai == 77
replace huwai = 3 if huwai == 3|huwai == 5|huwai == 6
tab ISEI,gen(dum_isei)
tab huwai,gen(dum_huwai)
sum2docx health AQI age gender edu marriage urban dum_isei*  chronic depression  exercise dum_huwai* year using Descriptive.docx, replace stats(N mean sd min median max)

**2)Regression

recode health (1 2=0)(3 4 5=1),g(health_2c)
* Basic Regression
reghdfe health AQI , absorb(provcd) 
est store m1
reghdfe health AQI age gender edu marriage urban ISEI  chronic depression, absorb(provcd)
est store m2
reghdfe health AQI exercise age gender edu marriage urban ISEI  chronic depression, absorb(provcd)
est store m3
esttab m1 m2 m3 using Basic_Regression.rtf , replace b(3) se(3) ar2 scalar(F) star(* 0.1 ** 0.05 *** 0.01) nogap onecell

*exercise_mechanism
reghdfe exercise AQI age gender edu marriage urban ISEI  chronic depression, absorb(provcd)
est store m1

reghdfe health exercise AQI age gender edu marriage urban ISEI  chronic depression, absorb(provcd)
est store m2

xi:bootstrap r(ind_eff),reps(100): sgmediation2 health, iv(AQI) mv(exercise) cv(age gen edu marriage urban ISEI  chronic depression i.provcd)
estat bootstrap, percentile bc


esttab m1 m2  using Exercise_Mechanism.rtf , replace b(3) se(3) ar2 scalar(F) star(* 0.1 ** 0.05 *** 0.01) nogap onecell

gen lnexercise = log(exercise)
hist lnexercise

**3) Bootstrap

*Simple Mediation effect
set seed 2000
xi:sgmediation2 health, iv(AQI) mv(exercise) cv(age gender edu marriage urban ISEI  chronic depression i.provcd )
xi:bootstrap r(ind_eff) r(dir_eff) r(tot_eff),reps(100): sgmediation2 health, iv(AQI) mv(exercise) cv(age gender edu marriage urban ISEI  chronic depression i.provcd)
estat bootstrap, percentile bc

**4) Exposure_Mechanism
**Different place
reghdfe health AQI age gender edu marriage urban ISEI  chronic depression if huwai == 1, absorb(provcd)  // outdoor
est store m1

reghdfe health AQI age gender edu marriage urban ISEI  chronic depression if huwai == 2, absorb(provcd)  //workshop
est store m2

reghdfe health AQI age gender edu marriage urban ISEI  chronic depression if huwai == 3|huwai == 5|huwai == 6, absorb(provcd) //office
est store m3

reghdfe health AQI age gender edu marriage urban ISEI  chronic depression if huwai == 4, absorb(provcd) //home
est store m4

esttab m1 m2 m3 m4 using Exposure.rtf , replace b(3) se(3) ar2 scalar(F) star(* 0.1 ** 0.05 *** 0.01) nogap onecell

**Different class
reghdfe health AQI age gender edu marriage urban  chronic depression if ISEI == 1, absorb(provcd)
est store m1

reghdfe health AQI age gender edu marriage urban  chronic depression if ISEI == 2, absorb(provcd)
est store m2

reghdfe health AQI age gender edu marriage urban  chronic depression if ISEI == 3, absorb(provcd)
est store m3

esttab m1 m2 m3 using Class.rtf , replace b(3) se(3) ar2 scalar(F) star(* 0.1 ** 0.05 *** 0.01) nogap onecell

***Different gender
reghdfe health AQI age  edu marriage urban ISEI chronic depression if gender == 1, absorb(provcd)
est store m1

reghdfe health AQI age  edu marriage urban ISEI chronic depression if gender == 0, absorb(provcd)
est store m2

reghdfe health c.gender##c.AQI age  edu marriage urban ISEI chronic depression , absorb(provcd)
est store m3

esttab m1 m2 m3 using Gender.rtf , replace b(3) se(3) ar2 scalar(F) star(* 0.1 ** 0.05 *** 0.01) nogap onecell

**Different residence
reghdfe health AQI age gender edu marriage ISEI  chronic depression if urban == 1, absorb(provcd)
est store m1

reghdfe health AQI age gender edu marriage ISEI  chronic depression if urban == 0, absorb(provcd)
est store m2

reghdfe health c.urban##c.AQI age gender edu marriage ISEI  chronic depression, absorb(provcd)
est store m3

esttab m1 m2 m3 using Urban.rtf , replace b(3) se(3) ar2 scalar(F) star(* 0.1 ** 0.05 *** 0.01) nogap onecell

***Different region
reghdfe health AQI age gender edu marriage urban ISEI chronic depression if region == 1, absorb(provcd)
est store m1

reghdfe health AQI age gender edu marriage urban ISEI  chronic depression if region == 2, absorb(provcd)
est store m2

reghdfe health AQI age gender edu marriage urban ISEI  chronic depression if region == 3, absorb(provcd)
est store m3

esttab m1 m2 m3 using region.rtf , replace b(3) se(3) ar2 scalar(F) star(* 0.1 ** 0.05 *** 0.01) nogap onecell


