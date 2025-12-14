gen date_stata = mofd(date(date, "YMD"))
format date_stata %tm
tsset date_stata, monthly
  
*Malay: price_klse - price_myrusd
*Phillip: price_psi - price_phpusd
*Thailand: price_seti - price_thbusd 
*Sing: price_sti - price_sgdusd
*Vietnam: price_vni - price_vndusd
 
*stock markets -> σ by GJK-GARCH  
foreach v in klse psi seti sti vni {
    
    * Step 1: Returns
    gen r_`v' = ln(price_`v' / L.price_`v')
   
    * Step 2: Stationarity    
*I(0)
dfuller r_`v', trend lags(0) regress
dfuller r_`v', trend lags(1) regress
dfuller r_`v', trend lags(2) regress
*I(1)
dfuller d.r_`v', trend lags(0) regress
dfuller d.r_`v', trend lags(1) regress
dfuller d.r_`v', trend lags(2) regress    

* Step 3: GJR- GARCH(1)regression 
    arch r_`v', arch(1) garch(1) tarch(1)
predict σ_`v', variance
}


*stock markets -> σ by GJK-GARCH  
foreach v in klse psi seti sti vni {
    
    * Step 1: Returns
    gen r_`v' = ln(price_`v' / L.price_`v')
   
    * Step 2: Stationarity    
*I(0)
dfuller r_`v', trend lags(0) regress
dfuller r_`v', trend lags(1) regress
dfuller r_`v', trend lags(2) regress
*I(1)
dfuller d.r_`v', trend lags(0) regress
dfuller d.r_`v', trend lags(1) regress
dfuller d.r_`v', trend lags(2) regress    

* Step 3: GJR- GARCH(1)regression 
    arch r_`v', arch(1) garch(1) tarch(1)
predict σ_`v', variance
}


foreach v in klse psi seti sti vni {    
    * Step 3: Mean Equation
    arima r_`v', ar(1) ma(1)
    
    * Step 4: Innovations
    predict innovation_`v', resid   
	reg innovation_`v'
   
 * Step 6: BDS test
    bds innovation_`v'
}


*Special case: 
arch r_sti, arch() garch(2) tarch(1)
predict σ_sti, variance

*exchange rate -> σ by GJK-GARCH   (TAKEN)
foreach v in myrusd phpusd thbusd sgdusd vndusd {
    * Step 1: Returns
    gen r_`v' = ln(price_`v' / L.price_`v')
    * Step 2: Stationarity    
*I(0)
dfuller r_`v', trend lags(0) regress
dfuller r_`v', trend lags(1) regress
dfuller r_`v', trend lags(2) regress
*I(1)
dfuller d.r_`v', trend lags(0) regress
dfuller d.r_`v', trend lags(1) regress
dfuller d.r_`v', trend lags(2) regress    

* Step 3: GJR- GARCH(1)regression 
    arch r_`v', arch(1) garch(1) tarch(1)
predict σ_`v', variance
}

*COVARIANCE EXTRACTION 
 (TAKEN)
gen lnOPUI = log(opu_index)
gen neg_lnOPUI =  lnOPUI< 0  
foreach v in myrusd phpusd thbusd sgdusd vndusd {
gen neg_`v' = r_`v'  < 0  
mgarch dcc (r_`v' = neg_`v', noconstant) (lnOPUI =  neg_lnOPUI, noconstant), arch(1) garch(1)
predict h_r_`v', variance equation(r_`v')
predict h_lnOPUI_`v', variance equation(lnOPUI)
predict rho_`v'_lnOPUI, correlation equation(r_`v',lnOPUI)
gen cov_`v'_lnOPUI = rho_`v'_lnOPUI* sqrt(h_r_`v') * sqrt(h_lnOPUI_`v')
}

*TABLE 1. Stock Market Price, Exchange rate and OVX descriptive
rename opu_index OVX

sum price_klse price_psi price_sti price_seti price_vni price_wti price_myrusd price_thbusd price_vndusd price_sgdusd price_phpusd OVX

*TABLE 2. Stock Market Return, Exchange rate Return descriptive
sum r_klse r_psi r_seti r_sti r_vni r_myrusd r_phpusd r_thbusd r_sgdusd r_vndusd 

*TABLE 3. Stock Market Volatility, Exchange rate Volatility descriptive using GJR-GARCH(1,1)
*THIS IS VARIANCE SO SHOULD TAKE SQUARE ROOT TO ESTIMATE VOLATILITY 
rename ( σ_klse σ_psi σ_seti σ_sti σ_vni σ_myrusd σ_phpusd σ_thbusd σ_sgdusd σ_vndusd)  ( volatility_klse volatility_psi volatility_seti volatility_sti volatility_vni volatility_myrusd volatility_phpusd volatility_thbusd volatility_sgdusd volatility_vndusd)
*VOLATILITY ESTIMATION
foreach v in klse psi seti sti vni myrusd phpusd thbusd sgdusd vndusd {    
gen σ_`v' = sqrt(volatility_`v')
 }
rename ( σ_myrusd σ_phpusd σ_thbusd σ_sgdusd σ_vndusd)  (EXV_myrusd EXV_phpusd EXV_thbusd EXV_sgdusd EXV_vndusd)

rename (EXV_myrusd EXV_phpusd EXV_thbusd EXV_sgdusd EXV_vndusd)( EXV_klse EXV_psi EXV_seti EXV_sti EXV_vni )

 sum σ_klse σ_psi σ_seti σ_sti σ_vni EXV_klse EXV_psi EXV_seti EXV_sti EXV_vni
 
 
 *TABLE 4. Covariance between Exchange rate Volatility and OPUI index using Asymmetric DCC-GARCH(1,1) 
rename (cov_myrusd_lnOPUI cov_phpusd_lnOPUI  cov_thbusd_lnOPUI  cov_sgdusd_lnOPUI  cov_vndusd_lnOPUI)  (COVOX_myrusd COVOX_phpusd COVOX_thbusd COVOX_sgdusd COVOX_vndusd)

rename (COVOX_myrusd COVOX_phpusd COVOX_thbusd COVOX_sgdusd COVOX_vndusd)( COVOX_klse COVOX_psi COVOX_seti COVOX_sti COVOX_vni )

sum COVOX_klse COVOX_psi COVOX_seti COVOX_sti COVOX_vni


*TABLE 5. Stationary test on returns of stock markets, exchange rates and OVX 
*Stationary 
foreach v in klse psi seti sti vni myrusd phpusd thbusd sgdusd vndusd {
    *Stationarity    
*I(0)
dfuller r_`v', trend lags(0) regress

}

*Stationary 
*I(0)
dfuller lnOPUI, trend lags(0) regress

*I(1)
dfuller d.lnOPUI, trend lags(0) regress



*TABLE 6. Nonlinearity test on returns of stock markets and exchange rates
*BDS 
*BDS test on stock returns and exchange rate returns 
foreach v in klse psi seti sti vni  myrusd phpusd thbusd sgdusd vndusd {    
    * Step 3: Mean Equation
   arima r_`v', ar(1) ma(1)
    
   * Step 4: Innovations
predict innovation_`v', resid   
reg innovation_`v'
    
 * Step 6: 
   bds innovation_`v'
 }


tsline σ_klse σ_psi σ_seti σ_sti σ_vni,    legend(order(1 "KLSE Volatility" 2 "PSI Volatility" 3 "SETI Volatility" 4 "STI Volatility" 5 "VNI Volatility"))  title("Conditional Volatility of ASEAN Stock Markets")   ytitle("Volatility (σ)") xtitle("Time") 


tsline COVOX_klse COVOX_psi COVOX_seti COVOX_sti COVOX_vni, legend(order(1 "MYR/USD" 2 "PHP/USD" 3 "THB/USD" 4 "SGD/USD" 5 "VND/USD"))  title("DCC-Based Conditional Covariance: COVOX")   ytitle("ρ (DCC Estimate)") xtitle("Time") 


sum r_klse r_psi r_seti r_sti r_vni
sum σ_klse σ_psi σ_seti σ_sti σ_vni 
sum EXV_klse EXV_psi EXV_seti EXV_sti EXV_vni
sum COVOX_klse COVOX_psi COVOX_seti COVOX_sti COVOX_vni

foreach v in klse psi seti sti vni {
 gen lr_`v' = l.r_`v'
}
*=====

foreach v in klse {
*Deploy equation 1: Qτ(rt​)=α0(τ)​+α1(τ)​OVXt​+α2(τ)​EXVt​+α3(τ)​rt−1​+εt(τ)​

reg r_`v' OVX  EXV_`v' lr_`v'
est sto a1_`v'_OLS
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.1)
est sto q1_`v'_q1
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.2)
est sto q1_`v'_q2
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.3)
est sto q1_`v'_q3
qreg r_`v' OVX EXV_`v' lr_`v', quantile(0.4)
est sto q1_`v'_q4
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.5)
est sto q1_`v'_q5
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.6)
est sto q1_`v'_q6
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.7)
est sto q1_`v'_q7
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.8)
est sto q1_`v'_q8
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.9)
est sto q1_`v'_q9

*Deploy equation 2:Qτ(rt​)=α0(τ)​+α1(τ)​COVOXt​+α2(τ)​rt−1​+εt(τ)​
qreg r_`v' COVOX_`v' lr_`v'
est sto a2_`v'_OLS
qreg r_`v' COVOX_`v' lr_`v', quantile(0.1)
est sto q2_`v'_q1
qreg r_`v' COVOX_`v' lr_`v', quantile(0.2)
est sto q2_`v'_q2
qreg r_`v' COVOX_`v' lr_`v', quantile(0.3)
est sto q2_`v'_q3
qreg r_`v' COVOX_`v' lr_`v', quantile(0.4)
est sto q2_`v'_q4
qreg r_`v' COVOX_`v' lr_`v', quantile(0.5)
est sto q2_`v'_q5
qreg r_`v' COVOX_`v' lr_`v', quantile(0.6)
est sto q2_`v'_q6
qreg r_`v' COVOX_`v' lr_`v', quantile(0.7)
est sto q2_`v'_q7
qreg r_`v' COVOX_`v' lr_`v', quantile(0.8)
est sto q2_`v'_q8
qreg r_`v' COVOX_`v' lr_`v', quantile(0.9)
est sto q2_`v'_q9

esttab a1_`v'_OLS q1_`v'_q1  q1_`v'_q2  q1_`v'_q3 q1_`v'_q4 q1_`v'_q5 q1_`v'_q6 q1_`v'_q7 q1_`v'_q8 q1_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

esttab a2_`v'_OLS q2_`v'_q1  q2_`v'_q2  q2_`v'_q3 q2_`v'_q4 q2_`v'_q5 q2_`v'_q6 q2_`v'_q7 q2_`v'_q8 q2_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                      (1)             (2)             (3)             (4)             (5)             (6)             (7)             (8)             (9)            (10)   
                   r_klse          r_klse          r_klse          r_klse          r_klse          r_klse          r_klse          r_klse          r_klse          r_klse   
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
OVX            -0.0000439      -0.0000712      -0.0000475      -0.0000619      -0.0000487      0.00000516      -0.0000139      -0.0000232      -0.0000237       -0.000106*  
                  (-1.19)         (-0.94)         (-0.85)         (-1.10)         (-1.07)          (0.11)         (-0.35)         (-0.47)         (-0.44)         (-1.86)   

EXV_klse            0.301           0.722           0.729           0.791           0.298           0.445           0.146          -0.176          -0.178          -0.450   
                   (0.77)          (0.90)          (1.23)          (1.33)          (0.62)          (0.91)          (0.35)         (-0.34)         (-0.31)         (-0.75)   

lr_klse            -0.130*        -0.0996         -0.0968         -0.0890          -0.120          -0.209**        -0.207**       -0.0506          -0.116          -0.234** 
                  (-1.72)         (-0.64)         (-0.85)         (-0.77)         (-1.29)         (-2.22)         (-2.58)         (-0.50)         (-1.07)         (-2.01)   

_cons            -0.00113         -0.0437**       -0.0340**       -0.0241        -0.00684        -0.00813         0.00688          0.0223*         0.0305**        0.0589***
                  (-0.12)         (-2.20)         (-2.31)         (-1.63)         (-0.57)         (-0.67)          (0.67)          (1.72)          (2.17)          (3.94)   
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
N                     183             183             183             183             183             183             183             183             183             183   
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
t statistics in parentheses
* p<0.1, ** p<0.05, *** p<0.01

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                      (1)             (2)             (3)             (4)             (5)             (6)             (7)             (8)             (9)            (10)   
                   r_klse          r_klse          r_klse          r_klse          r_klse          r_klse          r_klse          r_klse          r_klse          r_klse   
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
COVOX_klse         -0.361**        -0.651**        -0.472**        -0.487***       -0.526***       -0.361**        -0.394***       -0.281*         -0.254          -0.115   
                  (-2.24)         (-2.19)         (-2.50)         (-2.70)         (-3.47)         (-2.24)         (-2.92)         (-1.66)         (-1.51)         (-0.44)   

lr_klse            -0.133          -0.208         -0.0966         -0.0543          -0.127          -0.133          -0.152*         -0.109          -0.164*         -0.172   
                  (-1.43)         (-1.21)         (-0.89)         (-0.52)         (-1.46)         (-1.43)         (-1.96)         (-1.12)         (-1.69)         (-1.14)   

_cons              0.0250**       0.00446         0.00823          0.0159          0.0277***       0.0250**        0.0323***       0.0326***       0.0410***       0.0419** 
                   (2.45)          (0.24)          (0.69)          (1.39)          (2.89)          (2.45)          (3.78)          (3.04)          (3.84)          (2.53)   
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
N                     183             183             183             183             183             183             183             183             183             183   
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
t statistics in parentheses
* p<0.1, ** p<0.05, *** p<0.01



foreach v in psi {
*Deploy equation 1: Qτ(rt​)=α0(τ)​+α1(τ)​OVXt​+α2(τ)​EXVt​+α3(τ)​rt−1​+εt(τ)​

reg r_`v' OVX  EXV_`v' lr_`v'
est sto a1_`v'_OLS
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.1)
est sto q1_`v'_q1
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.2)
est sto q1_`v'_q2
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.3)
est sto q1_`v'_q3
qreg r_`v' OVX EXV_`v' lr_`v', quantile(0.4)
est sto q1_`v'_q4
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.5)
est sto q1_`v'_q5
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.6)
est sto q1_`v'_q6
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.7)
est sto q1_`v'_q7
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.8)
est sto q1_`v'_q8
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.9)
est sto q1_`v'_q9

*Deploy equation 2:Qτ(rt​)=α0(τ)​+α1(τ)​COVOXt​+α2(τ)​rt−1​+εt(τ)​
qreg r_`v' COVOX_`v' lr_`v'
est sto a2_`v'_OLS
qreg r_`v' COVOX_`v' lr_`v', quantile(0.1)
est sto q2_`v'_q1
qreg r_`v' COVOX_`v' lr_`v', quantile(0.2)
est sto q2_`v'_q2
qreg r_`v' COVOX_`v' lr_`v', quantile(0.3)
est sto q2_`v'_q3
qreg r_`v' COVOX_`v' lr_`v', quantile(0.4)
est sto q2_`v'_q4
qreg r_`v' COVOX_`v' lr_`v', quantile(0.5)
est sto q2_`v'_q5
qreg r_`v' COVOX_`v' lr_`v', quantile(0.6)
est sto q2_`v'_q6
qreg r_`v' COVOX_`v' lr_`v', quantile(0.7)
est sto q2_`v'_q7
qreg r_`v' COVOX_`v' lr_`v', quantile(0.8)
est sto q2_`v'_q8
qreg r_`v' COVOX_`v' lr_`v', quantile(0.9)
est sto q2_`v'_q9

esttab a1_`v'_OLS q1_`v'_q1  q1_`v'_q2  q1_`v'_q3 q1_`v'_q4 q1_`v'_q5 q1_`v'_q6 q1_`v'_q7 q1_`v'_q8 q1_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

esttab a2_`v'_OLS q2_`v'_q1  q2_`v'_q2  q2_`v'_q3 q2_`v'_q4 q2_`v'_q5 q2_`v'_q6 q2_`v'_q7 q2_`v'_q8 q2_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

}

foreach v in seti {
*Deploy equation 1: Qτ(rt​)=α0(τ)​+α1(τ)​OVXt​+α2(τ)​EXVt​+α3(τ)​rt−1​+εt(τ)​

reg r_`v' OVX  EXV_`v' lr_`v'
est sto a1_`v'_OLS
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.1)
est sto q1_`v'_q1
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.2)
est sto q1_`v'_q2
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.3)
est sto q1_`v'_q3
qreg r_`v' OVX EXV_`v' lr_`v', quantile(0.4)
est sto q1_`v'_q4
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.5)
est sto q1_`v'_q5
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.6)
est sto q1_`v'_q6
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.7)
est sto q1_`v'_q7
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.8)
est sto q1_`v'_q8
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.9)
est sto q1_`v'_q9

*Deploy equation 2:Qτ(rt​)=α0(τ)​+α1(τ)​COVOXt​+α2(τ)​rt−1​+εt(τ)​
qreg r_`v' COVOX_`v' lr_`v'
est sto a2_`v'_OLS
qreg r_`v' COVOX_`v' lr_`v', quantile(0.1)
est sto q2_`v'_q1
qreg r_`v' COVOX_`v' lr_`v', quantile(0.2)
est sto q2_`v'_q2
qreg r_`v' COVOX_`v' lr_`v', quantile(0.3)
est sto q2_`v'_q3
qreg r_`v' COVOX_`v' lr_`v', quantile(0.4)
est sto q2_`v'_q4
qreg r_`v' COVOX_`v' lr_`v', quantile(0.5)
est sto q2_`v'_q5
qreg r_`v' COVOX_`v' lr_`v', quantile(0.6)
est sto q2_`v'_q6
qreg r_`v' COVOX_`v' lr_`v', quantile(0.7)
est sto q2_`v'_q7
qreg r_`v' COVOX_`v' lr_`v', quantile(0.8)
est sto q2_`v'_q8
qreg r_`v' COVOX_`v' lr_`v', quantile(0.9)
est sto q2_`v'_q9

esttab a1_`v'_OLS q1_`v'_q1  q1_`v'_q2  q1_`v'_q3 q1_`v'_q4 q1_`v'_q5 q1_`v'_q6 q1_`v'_q7 q1_`v'_q8 q1_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

esttab a2_`v'_OLS q2_`v'_q1  q2_`v'_q2  q2_`v'_q3 q2_`v'_q4 q2_`v'_q5 q2_`v'_q6 q2_`v'_q7 q2_`v'_q8 q2_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

}


foreach v in sti {
*Deploy equation 1: Qτ(rt​)=α0(τ)​+α1(τ)​OVXt​+α2(τ)​EXVt​+α3(τ)​rt−1​+εt(τ)​

reg r_`v' OVX  EXV_`v' lr_`v'
est sto a1_`v'_OLS
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.1)
est sto q1_`v'_q1
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.2)
est sto q1_`v'_q2
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.3)
est sto q1_`v'_q3
qreg r_`v' OVX EXV_`v' lr_`v', quantile(0.4)
est sto q1_`v'_q4
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.5)
est sto q1_`v'_q5
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.6)
est sto q1_`v'_q6
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.7)
est sto q1_`v'_q7
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.8)
est sto q1_`v'_q8
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.9)
est sto q1_`v'_q9

*Deploy equation 2:Qτ(rt​)=α0(τ)​+α1(τ)​COVOXt​+α2(τ)​rt−1​+εt(τ)​
qreg r_`v' COVOX_`v' lr_`v'
est sto a2_`v'_OLS
qreg r_`v' COVOX_`v' lr_`v', quantile(0.1)
est sto q2_`v'_q1
qreg r_`v' COVOX_`v' lr_`v', quantile(0.2)
est sto q2_`v'_q2
qreg r_`v' COVOX_`v' lr_`v', quantile(0.3)
est sto q2_`v'_q3
qreg r_`v' COVOX_`v' lr_`v', quantile(0.4)
est sto q2_`v'_q4
qreg r_`v' COVOX_`v' lr_`v', quantile(0.5)
est sto q2_`v'_q5
qreg r_`v' COVOX_`v' lr_`v', quantile(0.6)
est sto q2_`v'_q6
qreg r_`v' COVOX_`v' lr_`v', quantile(0.7)
est sto q2_`v'_q7
qreg r_`v' COVOX_`v' lr_`v', quantile(0.8)
est sto q2_`v'_q8
qreg r_`v' COVOX_`v' lr_`v', quantile(0.9)
est sto q2_`v'_q9

esttab a1_`v'_OLS q1_`v'_q1  q1_`v'_q2  q1_`v'_q3 q1_`v'_q4 q1_`v'_q5 q1_`v'_q6 q1_`v'_q7 q1_`v'_q8 q1_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

esttab a2_`v'_OLS q2_`v'_q1  q2_`v'_q2  q2_`v'_q3 q2_`v'_q4 q2_`v'_q5 q2_`v'_q6 q2_`v'_q7 q2_`v'_q8 q2_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

}


foreach v in vni {
*Deploy equation 1: Qτ(rt​)=α0(τ)​+α1(τ)​OVXt​+α2(τ)​EXVt​+α3(τ)​rt−1​+εt(τ)​

reg r_`v' OVX  EXV_`v' lr_`v'
est sto a1_`v'_OLS
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.1)
est sto q1_`v'_q1
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.2)
est sto q1_`v'_q2
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.3)
est sto q1_`v'_q3
qreg r_`v' OVX EXV_`v' lr_`v', quantile(0.4)
est sto q1_`v'_q4
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.5)
est sto q1_`v'_q5
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.6)
est sto q1_`v'_q6
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.7)
est sto q1_`v'_q7
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.8)
est sto q1_`v'_q8
qreg r_`v' OVX  EXV_`v' lr_`v', quantile(0.9)
est sto q1_`v'_q9

*Deploy equation 2:Qτ(rt​)=α0(τ)​+α1(τ)​COVOXt​+α2(τ)​rt−1​+εt(τ)​
qreg r_`v' COVOX_`v' lr_`v'
est sto a2_`v'_OLS
qreg r_`v' COVOX_`v' lr_`v', quantile(0.1)
est sto q2_`v'_q1
qreg r_`v' COVOX_`v' lr_`v', quantile(0.2)
est sto q2_`v'_q2
qreg r_`v' COVOX_`v' lr_`v', quantile(0.3)
est sto q2_`v'_q3
qreg r_`v' COVOX_`v' lr_`v', quantile(0.4)
est sto q2_`v'_q4
qreg r_`v' COVOX_`v' lr_`v', quantile(0.5)
est sto q2_`v'_q5
qreg r_`v' COVOX_`v' lr_`v', quantile(0.6)
est sto q2_`v'_q6
qreg r_`v' COVOX_`v' lr_`v', quantile(0.7)
est sto q2_`v'_q7
qreg r_`v' COVOX_`v' lr_`v', quantile(0.8)
est sto q2_`v'_q8
qreg r_`v' COVOX_`v' lr_`v', quantile(0.9)
est sto q2_`v'_q9

esttab a1_`v'_OLS q1_`v'_q1  q1_`v'_q2  q1_`v'_q3 q1_`v'_q4 q1_`v'_q5 q1_`v'_q6 q1_`v'_q7 q1_`v'_q8 q1_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

esttab a2_`v'_OLS q2_`v'_q1  q2_`v'_q2  q2_`v'_q3 q2_`v'_q4 q2_`v'_q5 q2_`v'_q6 q2_`v'_q7 q2_`v'_q8 q2_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

}


foreach v in klse psi seti sti vni {
 gen lσ_`v' = l.σ_`v'
}

*=====
foreach v in klse {
*Deploy equation 1: Qτ(σt​)=α0(τ)​+α1(τ)​OVXt​+α2(τ)​EXVt​+α3(τ)​rt−1​+εt(τ)​

reg σ_`v' OVX  EXV_`v' lσ_`v'
est sto aa1_`v'_OLS
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.1)
est sto qq1_`v'_q1
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.2)
est sto qq1_`v'_q2
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.3)
est sto qq1_`v'_q3
qreg σ_`v' OVX EXV_`v' lσ_`v', quantile(0.4)
est sto qq1_`v'_q4
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.5)
est sto qq1_`v'_q5
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.6)
est sto qq1_`v'_q6
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.7)
est sto qq1_`v'_q7
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.8)
est sto qq1_`v'_q8
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.9)
est sto qq1_`v'_q9

*Deploy equation 2:Qτ(σt​)=α0(τ)​+α1(τ)​COVOXt​+α2(τ)​rt−1​+εt(τ)​
qreg σ_`v' COVOX_`v' lσ_`v'
est sto aa2_`v'_OLS
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.1)
est sto qq2_`v'_q1
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.2)
est sto qq2_`v'_q2
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.3)
est sto qq2_`v'_q3
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.4)
est sto qq2_`v'_q4
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.5)
est sto qq2_`v'_q5
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.6)
est sto qq2_`v'_q6
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.7)
est sto qq2_`v'_q7
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.8)
est sto qq2_`v'_q8
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.9)
est sto qq2_`v'_q9

esttab aa1_`v'_OLS qq1_`v'_q1  qq1_`v'_q2  qq1_`v'_q3 qq1_`v'_q4 qq1_`v'_q5 qq1_`v'_q6 qq1_`v'_q7 qq1_`v'_q8 qq1_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

esttab aa2_`v'_OLS qq2_`v'_q1  qq2_`v'_q2  qq2_`v'_q3 qq2_`v'_q4 qq2_`v'_q5 qq2_`v'_q6 qq2_`v'_q7 qq2_`v'_q8 qq2_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

}
foreach v in  psi {
*Deploy equation 1: Qτ(σt​)=α0(τ)​+α1(τ)​OVXt​+α2(τ)​EXVt​+α3(τ)​rt−1​+εt(τ)​

reg σ_`v' OVX  EXV_`v' lσ_`v'
est sto aa1_`v'_OLS
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.1)
est sto qq1_`v'_q1
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.2)
est sto qq1_`v'_q2
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.3)
est sto qq1_`v'_q3
qreg σ_`v' OVX EXV_`v' lσ_`v', quantile(0.4)
est sto qq1_`v'_q4
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.5)
est sto qq1_`v'_q5
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.6)
est sto qq1_`v'_q6
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.7)
est sto qq1_`v'_q7
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.8)
est sto qq1_`v'_q8
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.9)
est sto qq1_`v'_q9

*Deploy equation 2:Qτ(σt​)=α0(τ)​+α1(τ)​COVOXt​+α2(τ)​rt−1​+εt(τ)​
qreg σ_`v' COVOX_`v' lσ_`v'
est sto aa2_`v'_OLS
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.1)
est sto qq2_`v'_q1
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.2)
est sto qq2_`v'_q2
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.3)
est sto qq2_`v'_q3
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.4)
est sto qq2_`v'_q4
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.5)
est sto qq2_`v'_q5
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.6)
est sto qq2_`v'_q6
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.7)
est sto qq2_`v'_q7
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.8)
est sto qq2_`v'_q8
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.9)
est sto qq2_`v'_q9

esttab aa1_`v'_OLS qq1_`v'_q1  qq1_`v'_q2  qq1_`v'_q3 qq1_`v'_q4 qq1_`v'_q5 qq1_`v'_q6 qq1_`v'_q7 qq1_`v'_q8 qq1_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

esttab aa2_`v'_OLS qq2_`v'_q1  qq2_`v'_q2  qq2_`v'_q3 qq2_`v'_q4 qq2_`v'_q5 qq2_`v'_q6 qq2_`v'_q7 qq2_`v'_q8 qq2_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

}

foreach v in seti {
*Deploy equation 1: Qτ(σt​)=α0(τ)​+α1(τ)​OVXt​+α2(τ)​EXVt​+α3(τ)​rt−1​+εt(τ)​

reg σ_`v' OVX  EXV_`v' lσ_`v'
est sto aa1_`v'_OLS
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.1)
est sto qq1_`v'_q1
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.2)
est sto qq1_`v'_q2
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.3)
est sto qq1_`v'_q3
qreg σ_`v' OVX EXV_`v' lσ_`v', quantile(0.4)
est sto qq1_`v'_q4
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.5)
est sto qq1_`v'_q5
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.6)
est sto qq1_`v'_q6
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.7)
est sto qq1_`v'_q7
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.8)
est sto qq1_`v'_q8
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.9)
est sto qq1_`v'_q9

*Deploy equation 2:Qτ(σt​)=α0(τ)​+α1(τ)​COVOXt​+α2(τ)​rt−1​+εt(τ)​
qreg σ_`v' COVOX_`v' lσ_`v'
est sto aa2_`v'_OLS
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.1)
est sto qq2_`v'_q1
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.2)
est sto qq2_`v'_q2
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.3)
est sto qq2_`v'_q3
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.4)
est sto qq2_`v'_q4
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.5)
est sto qq2_`v'_q5
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.6)
est sto qq2_`v'_q6
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.7)
est sto qq2_`v'_q7
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.8)
est sto qq2_`v'_q8
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.9)
est sto qq2_`v'_q9

esttab aa1_`v'_OLS qq1_`v'_q1  qq1_`v'_q2  qq1_`v'_q3 qq1_`v'_q4 qq1_`v'_q5 qq1_`v'_q6 qq1_`v'_q7 qq1_`v'_q8 qq1_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

esttab aa2_`v'_OLS qq2_`v'_q1  qq2_`v'_q2  qq2_`v'_q3 qq2_`v'_q4 qq2_`v'_q5 qq2_`v'_q6 qq2_`v'_q7 qq2_`v'_q8 qq2_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

}

foreach v in  sti  {
*Deploy equation 1: Qτ(σt​)=α0(τ)​+α1(τ)​OVXt​+α2(τ)​EXVt​+α3(τ)​rt−1​+εt(τ)​

reg σ_`v' OVX  EXV_`v' lσ_`v'
est sto aa1_`v'_OLS
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.1)
est sto qq1_`v'_q1
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.2)
est sto qq1_`v'_q2
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.3)
est sto qq1_`v'_q3
qreg σ_`v' OVX EXV_`v' lσ_`v', quantile(0.4)
est sto qq1_`v'_q4
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.5)
est sto qq1_`v'_q5
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.6)
est sto qq1_`v'_q6
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.7)
est sto qq1_`v'_q7
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.8)
est sto qq1_`v'_q8
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.9)
est sto qq1_`v'_q9

*Deploy equation 2:Qτ(σt​)=α0(τ)​+α1(τ)​COVOXt​+α2(τ)​rt−1​+εt(τ)​
qreg σ_`v' COVOX_`v' lσ_`v'
est sto aa2_`v'_OLS
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.1)
est sto qq2_`v'_q1
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.2)
est sto qq2_`v'_q2
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.3)
est sto qq2_`v'_q3
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.4)
est sto qq2_`v'_q4
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.5)
est sto qq2_`v'_q5
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.6)
est sto qq2_`v'_q6
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.7)
est sto qq2_`v'_q7
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.8)
est sto qq2_`v'_q8
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.9)
est sto qq2_`v'_q9

esttab aa1_`v'_OLS qq1_`v'_q1  qq1_`v'_q2  qq1_`v'_q3 qq1_`v'_q4 qq1_`v'_q5 qq1_`v'_q6 qq1_`v'_q7 qq1_`v'_q8 qq1_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

esttab aa2_`v'_OLS qq2_`v'_q1  qq2_`v'_q2  qq2_`v'_q3 qq2_`v'_q4 qq2_`v'_q5 qq2_`v'_q6 qq2_`v'_q7 qq2_`v'_q8 qq2_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

}

foreach v in vni {
*Deploy equation 1: Qτ(σt​)=α0(τ)​+α1(τ)​OVXt​+α2(τ)​EXVt​+α3(τ)​rt−1​+εt(τ)​

reg σ_`v' OVX  EXV_`v' lσ_`v'
est sto aa1_`v'_OLS
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.1)
est sto qq1_`v'_q1
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.2)
est sto qq1_`v'_q2
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.3)
est sto qq1_`v'_q3
qreg σ_`v' OVX EXV_`v' lσ_`v', quantile(0.4)
est sto qq1_`v'_q4
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.5)
est sto qq1_`v'_q5
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.6)
est sto qq1_`v'_q6
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.7)
est sto qq1_`v'_q7
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.8)
est sto qq1_`v'_q8
qreg σ_`v' OVX  EXV_`v' lσ_`v', quantile(0.9)
est sto qq1_`v'_q9

*Deploy equation 2:Qτ(σt​)=α0(τ)​+α1(τ)​COVOXt​+α2(τ)​rt−1​+εt(τ)​
qreg σ_`v' COVOX_`v' lσ_`v'
est sto aa2_`v'_OLS
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.1)
est sto qq2_`v'_q1
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.2)
est sto qq2_`v'_q2
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.3)
est sto qq2_`v'_q3
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.4)
est sto qq2_`v'_q4
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.5)
est sto qq2_`v'_q5
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.6)
est sto qq2_`v'_q6
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.7)
est sto qq2_`v'_q7
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.8)
est sto qq2_`v'_q8
qreg σ_`v' COVOX_`v' lσ_`v', quantile(0.9)
est sto qq2_`v'_q9

esttab aa1_`v'_OLS qq1_`v'_q1  qq1_`v'_q2  qq1_`v'_q3 qq1_`v'_q4 qq1_`v'_q5 qq1_`v'_q6 qq1_`v'_q7 qq1_`v'_q8 qq1_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

esttab aa2_`v'_OLS qq2_`v'_q1  qq2_`v'_q2  qq2_`v'_q3 qq2_`v'_q4 qq2_`v'_q5 qq2_`v'_q6 qq2_`v'_q7 qq2_`v'_q8 qq2_`v'_q9, star(* 0.1 ** 0.05 *** 0.01) replace

}

