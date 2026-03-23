** GENeSYS-MOD v3.1 [Global Energy System Model]  ~ March 2022
**
** #############################################################
**
** Licensed under the Apache License, Version 2.0 (the "License");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
**     http://www.apache.org/licenses/LICENSE-2.0
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an "AS IS" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
**
** #############################################################
*
**_______________________________________SENSITIVITIES__________________________________________*
*NewTradeCapacity.fx(y,'Power', 'DE_Nord','DE_NI')$(YearVal(y) > 2018) = 0.11;

* define Sets for offshore-regions
* Set of sea-based offshore hubs (excluded from symmetric transmission constraint in TrC6)
* DE_Nord_1..20 and DE_Baltic: only export to land, no symmetric capacity required
set offshore_hub_sea(r_full);
offshore_hub_sea(r_full) = no;
offshore_hub_sea('DE_Nord_1') = yes;
offshore_hub_sea('DE_Nord_2') = yes;
offshore_hub_sea('DE_Nord_3') = yes;
offshore_hub_sea('DE_Nord_4') = yes;
offshore_hub_sea('DE_Nord_5') = yes;
offshore_hub_sea('DE_Nord_6') = yes;
offshore_hub_sea('DE_Nord_7') = yes;
offshore_hub_sea('DE_Nord_8') = yes;
offshore_hub_sea('DE_Nord_9') = yes;
offshore_hub_sea('DE_Nord_10') = yes;
offshore_hub_sea('DE_Nord_11') = yes;
offshore_hub_sea('DE_Nord_12') = yes;
offshore_hub_sea('DE_Nord_13') = yes;
offshore_hub_sea('DE_Nord_14') = yes;
offshore_hub_sea('DE_Nord_16') = yes;
offshore_hub_sea('DE_Nord_17') = yes;
offshore_hub_sea('DE_Nord_19') = yes;
offshore_hub_sea('DE_Nord_20') = yes;
offshore_hub_sea('DE_Baltic_1') = yes;
offshore_hub_sea('DE_Baltic_2') = yes;
offshore_hub_sea('DE_Baltic_3') = yes;
offshore_hub_sea('DE_Baltic_4') = yes;
offshore_hub_sea('DE_Baltic_5') = yes;
offshore_hub_sea('DE_Baltic_6') = yes;

* Sensitivity multipliers in offshore hub regions:
* - CapitalCost for RES_Wind_Offshore_Deep and X_Alkaline_Electrolysis
* - CapitalCostStorage for storage linked to D_Battery_Li-Ion
CapitalCost(r,'RES_Wind_Offshore_Deep',y)$offshore_hub_sea(r) =
    CapitalCost(r,'RES_Wind_Offshore_Deep',y) * %offshore_deep_capitalcost_multiplier%;
CapitalCost(r,'X_Alkaline_Electrolysis',y)$offshore_hub_sea(r) =
    CapitalCost(r,'X_Alkaline_Electrolysis',y) * %X_Alkaline_Electrolysis_multiplier%;
CapitalCostStorage(r,s,y)$(offshore_hub_sea(r) and sum(m, TechnologyToStorage('D_Battery_Li-Ion',s,m,y)) > 0) =
    CapitalCostStorage(r,s,y) * %storage_capitalcost_multiplier%;


parameter TagTradeMonoDirectional(REGION_FULL);
TagTradeMonoDirectional(r) = 0;
TagTradeMonoDirectional(r)$offshore_hub_sea(r) = 1;

* Sensitivity multipliers in offshore hub regions:
* -TradeCapacityGrowthCosts for Power (both directions)
* -TradeCapacityGrowthCosts for H2 (both directions)
TradeCapacityGrowthCosts(r,'Power',rr)$offshore_hub_sea(r) =
    TradeCapacityGrowthCosts(r,'Power',rr) * %trade_capacity_growth_cost_multiplier%;
TradeCapacityGrowthCosts(r,'Power',rr)$offshore_hub_sea(rr) =
    TradeCapacityGrowthCosts(r,'Power',rr) * %trade_capacity_growth_cost_multiplier%;

TradeCapacityGrowthCosts(r,'H2',rr)$offshore_hub_sea(r) =
    TradeCapacityGrowthCosts(r,'H2',rr) * %trade_capacity_growth_cost_multiplier%;
TradeCapacityGrowthCosts(r,'H2',rr)$offshore_hub_sea(rr) =
    TradeCapacityGrowthCosts(r,'H2',rr) * %trade_capacity_growth_cost_multiplier%;

Import.fx(y,l,f,r,rr)$offshore_hub_sea(r) = 0;

$if not set h2_pricetarget $setglobal h2_pricetarget 1.82
$ifthen %h2_pricetarget% == 0
$else
VariableCost(r,'Z_Import_H2',m,'2050') = %h2_pricetarget%*7.68736;
VariableCost(r,'Z_Import_H2',m,'2045') = VariableCost(r,'Z_Import_H2',m,'2050')*(((1.1-1)/(%h2_pricetarget%/1.82))+1);
VariableCost(r,'Z_Import_H2',m,'2040') = VariableCost(r,'Z_Import_H2',m,'2045')*(((1.15-1)/(%h2_pricetarget%/1.82))+1);
VariableCost(r,'Z_Import_H2',m,'2035') = VariableCost(r,'Z_Import_H2',m,'2040')*(((1.25-1)/(%h2_pricetarget%/1.82))+1);
VariableCost(r,'Z_Import_H2',m,'2030') = VariableCost(r,'Z_Import_H2',m,'2035')*(((1.4-1)/(%h2_pricetarget%/1.82))+1);
VariableCost(r,'Z_Import_H2',m,'2025') = VariableCost(r,'Z_Import_H2',m,'2030')*(((1.5-1)/(%h2_pricetarget%/1.82))+1);
$endif

**
**
$ifthen not %switch_growth_rate_power% == 0

GrowthRateTradeCapacity(r,'Power',y,rr) = %switch_growth_rate_power%;

$endif

$ifthen not %switch_transport_costs_h2% == 0

TradeCosts('H2',r,rr) = TradeCosts('H2',r,rr) * %switch_transport_costs_h2%;

$endif

$ifthen %switch_h2_waste_heat% == 0

OutputActivityRatio(r,'X_Alkaline_Electrolysis',f,'2',y) = 0;
OutputActivityRatio(r,'X_SOEC_Electrolysis',f,'2',y) = 0;
OutputActivityRatio(r,'X_PEM_Electrolysis',f,'2',y) = 0;


$endif

*
**______________________________________________________________________________________________*
*
*

AvailabilityFactor(r,'Z_Import_H2',y)$(YearVal(y)<2030) = 0;
AvailabilityFactor(r,'Z_Import_H2','2025') = 1;
AvailabilityFactor('DE_BE','Z_Import_H2',y) = 0;
AvailabilityFactor('DE_HB','Z_Import_H2',y) = 0;
AvailabilityFactor('DE_HE','Z_Import_H2',y) = 0;
AvailabilityFactor('DE_HH','Z_Import_H2',y) = 0;
AvailabilityFactor('DE_ST','Z_Import_H2',y) = 0;
AvailabilityFactor('DE_TH','Z_Import_H2',y) = 0;

NewCapacity.up('2018','X_SMR',r) = +INF;
*
TradeCapacity('DE_BB','Gas_Natural',y,'DE_BE') = 100;
*GrowthRateTradeCapacity('DE_BB','Gas_Natural','2018','DE_BE') = INF;
*NewTradeCapacity.up('2018', 'Gas_Natural', r, rr) = +INF;


*fix so that imports have to be flat and not only used in times when production is not possible
equation Add_FlatH2Imports(y_full,l_full,r_full);
Add_FlatH2Imports(y,l,r)..   RateOfActivity(y,l,'Z_Import_H2','1',r)  =l= sum(ll,RateOfActivity(y,ll,'Z_Import_H2','1',r))*YearSplit(l,y)*1.05;

equation Add_FlatGasImports(y_full,l_full,r_full);
Add_FlatGasImports(y,l,r)..   RateOfActivity(y,l,'Z_Import_Gas','1',r)  =l= sum(ll,RateOfActivity(y,ll,'Z_Import_Gas','1',r))*YearSplit(l,y)*1.05;



*fix for offshore hub regions
CapacityFactor(r,'HLR_Solar_Thermal',l,y)$(CapacityFactor(r,'RES_PV_Utility_Avg',l,y)=0) = 0.00001;
CapacityFactor(r,'HLI_Solar_Thermal',l,y)$(CapacityFactor(r,'RES_PV_Utility_Avg',l,y)=0) = 0.00001;


*no free variable cost
VariableCost(r,t,m,y)$(not VariableCost(r,t,m,y)) = 0.01;

*nuclear phase out
TotalTechnologyAnnualActivityUpperLimit(r,'P_Nuclear',y)$(YearVal(y) >= 2025) = 0;


AvailabilityFactor(r,t,y)$offshore_hub_sea(r) = 0;

AvailabilityFactor(r,'RES_Wind_Offshore_Deep',y)$offshore_hub_sea(r) = 1;

AvailabilityFactor(r,'D_Battery_Li-Ion',y)$offshore_hub_sea(r) = 1;

AvailabilityFactor(r,'X_Alkaline_Electrolysis',y)$offshore_hub_sea(r) = 1;
AvailabilityFactor(r,'X_PEM_Electrolysis',y)$offshore_hub_sea(r) = 1;
AvailabilityFactor(r,'X_SOEC_Electrolysis',y)$offshore_hub_sea(r) = 1;


$ifthen %switch_central_h2% == 1
NewTradeCapacity.fx(y, 'Power', r, rr)$offshore_hub_sea(r) = 0;
$endif

ReserveMargin(r,y)$offshore_hub_sea(r) = 0;

*fix for suboptimality
ReserveMargin(r,y) = 0;


*TotalTechnologyAnnualActivityUpperLimit(r,'X_Alkaline_Electrolysis','2018')$(AvailabilityFactor(r,'X_Alkaline_Electrolysis','2018')) = 0.01*SpecifiedAnnualDemand(r,'H2','2018');
*TotalTechnologyAnnualActivityUpperLimit(r,'X_SMR','2018')$(AvailabilityFactor(r,'X_SMR','2018')) = 0.37*SpecifiedAnnualDemand(r,'H2','2018');
*RegionalBaseYearProduction(r,'X_SMR','H2','2018')$(AvailabilityFactor(r,'X_SMR','2018')) = 0.37*SpecifiedAnnualDemand(r,'H2','2018');
RegionalBaseYearProduction(r,'X_Alkaline_Electrolysis','H2','2018')$(AvailabilityFactor(r,'X_Alkaline_Electrolysis','2018')) = 0.01*SpecifiedAnnualDemand(r,'H2','2018');
RegionalBaseYearProduction(r,'X_Alkaline_Electrolysis','H2','2025')$(AvailabilityFactor(r,'X_Alkaline_Electrolysis','2025')) = 0.02*SpecifiedAnnualDemand(r,'H2','2025');

*
*
**___________________________________________________________________________________________________________*
*
*
*
*##### Total Annual Max Capacity for Wind_offshore_Shallow/Transitional/Deep adjusted for regions connected to DE_Nord & DE_Baltic (based on residual capacity) #####
TotalAnnualMaxCapacity('DE_SH','RES_Wind_Offshore_Deep',y)$(yearVal(y) >= 2015) = 0;
TotalAnnualMaxCapacity('DE_SH','RES_Wind_Offshore_Shallow',y)$(yearVal(y) >= 2015) = 2.4450;
TotalAnnualMaxCapacity('DE_NI','RES_Wind_Offshore_Deep',y)$(yearVal(y) >= 2015) = 0;
TotalAnnualMaxCapacity('DE_NI','RES_Wind_Offshore_Shallow',y)$(yearVal(y) >= 2015) = 4.2530;
TotalAnnualMaxCapacity('DE_MV','RES_Wind_Offshore_Deep',y)$(yearVal(y) >= 2015) = 0;
TotalAnnualMaxCapacity('DE_MV','RES_Wind_Offshore_Shallow',y)$(yearVal(y) >= 2015) = 1.0675;


GrowthRateTradeCapacity(r,'Gas_Natural',y,rr) = 0.1;
GrowthRateTradeCapacity(r,'H2',y,rr) = 0.15;
*
*
$ifthen %switch_Policy_Scenario% == 1
*######## Policy Scenario Osterpaket ##########



set t_group /onshore,offshore,solar,h2/;

parameter OsterpaketCapacity(y_full,t_group);

OsterpaketCapacity('2030','onshore') = 115;
OsterpaketCapacity('2030','solar') = 215;

set h2(t);
h2(t) = no;
h2('X_Alkaline_Electrolysis') = yes;
h2('X_SOEC_Electrolysis') = yes;
h2('X_PEM_Electrolysis') = yes;


set onshore(t);
onshore(t) = no;
onshore('RES_Wind_Onshore_Opt') = yes;
onshore('RES_Wind_Onshore_Avg') = yes;
onshore('RES_Wind_Onshore_Inf') = yes;

set offshore(t);
offshore(t) = no;
offshore('RES_Wind_Offshore_Deep') = yes;
offshore('RES_Wind_Offshore_Transitional') = yes;
offshore('RES_Wind_Offshore_Shallow') = yes;


parameter TagTechnologyToTechGroup(t,t_group);
TagTechnologyToTechGroup(Onshore,'onshore')=1;
TagTechnologyToTechGroup(t,'solar')$(TagTechnologyToSubsets(t,'Solar'))=1;
TagTechnologyToTechGroup('HLR_Solar_Thermal','solar')=0;
TagTechnologyToTechGroup('HLI_Solar_Thermal','solar')=0;


$ifthen %switch_FEP% == 0

set offshore (t);
offshore(t)= no;
offshore('RES_Wind_Offshore_Deep') = yes;
offshore('RES_Wind_Offshore_Shallow') = yes;
offshore('RES_Wind_Offshore_Transitional') = yes;

equations Add_Osterpaket(y_full,t_group);
Add_Osterpaket(y,t_group).. sum((t,r)$(TagTechnologyToTechGroup(t,t_group)),TotalCapacityAnnual(y,t,r)) =g= OsterpaketCapacity(y,t_group);

$elseIf %switch_FEP% == 1
equations Add_Osterpaket(y_full,t_group);
Add_Osterpaket(y,t_group).. sum((t,r)$(TagTechnologyToTechGroup(t,t_group)),TotalCapacityAnnual(y,t,r)) =g= OsterpaketCapacity(y,t_group);

equations Add_Osterpaket_h2(y_full,t_group);
Add_Osterpaket_h2(y,'h2')$(YearVal(y)=2030).. sum((t,r)$(TagTechnologyToTechGroup(t,'h2')),TotalCapacityAnnual(y,t,r)) =e= OsterpaketCapacity(y,'h2');


$endif


*########SectorEmissionLimits######
**AnnualSectorEmissions for net-zero in power sector 2035**
AnnualSectoralEmissions.fx(y,'CO2','Power',r)$(YearVal(y)>2030) = 0;

**Because power sector carbon free in 2035, and CHP can only run with Power in both modes

set FossilCHPs (t);
FossilCHPs(t) = no;
FossilCHPs(t)$(TagTechnologyToSubsets(t,'CHP') and TagTechnologyToSubsets(t,'FossilPower')) = yes;


AvailabilityFactor(r,FossilCHPs,y)$(YearVal(y)>=2035) = 0;



**80% of Power from RES in 2030
equations PowerREProduction(YEAR_FULL, FUEL);
PowerREProduction(y,f)$(YearVal(y)>2025)..sum(r, TotalREProductionAnnual(y,r,'Power')) =g= 0.8*sum((t,r), ProductionByTechnologyAnnual(y,t,'Power',r));

**Heating Sector (50%)


equations HeatREProduction(YEAR_FULL, REGION_FULL);
HeatREProduction(y,r)$(YearVal(y)>2025)..sum(f$(TagFuelToSubsets(f,'HeatFuels')), TotalREProductionAnnual(y,r,f)) + TotalREProductionAnnual(y,r,'Heat_District') =g= 0.5*sum((t,f)$(TagFuelToSubsets(f,'HeatFuels')), ProductionByTechnologyAnnual(y,t,f,r));


*AvailabilityFactor(r,'HLR_H2_Boiler',y) = 0;


$endif

$ifthen %switch_FEP% == 1
*###### Flächentwicklungsplan implementation #######
set offshore_nordic(r_full);
offshore_nordic(r_full) = no;
offshore_nordic('DE_Nord_1') = yes;
offshore_nordic('DE_Nord_2') = yes;
offshore_nordic('DE_Nord_3') = yes;
offshore_nordic('DE_Nord_4') = yes;
offshore_nordic('DE_Nord_5') = yes;
offshore_nordic('DE_Nord_6') = yes;
offshore_nordic('DE_Nord_7') = yes;
offshore_nordic('DE_Nord_8') = yes;
offshore_nordic('DE_Nord_9') = yes;
offshore_nordic('DE_Nord_10') = yes;
offshore_nordic('DE_Nord_11') = yes;
offshore_nordic('DE_Nord_12') = yes;
offshore_nordic('DE_Nord_13') = yes;
offshore_nordic('DE_Nord_14') = yes;
offshore_nordic('DE_Nord_16') = yes;
offshore_nordic('DE_Nord_17') = yes;
offshore_nordic('DE_Nord_19') = yes;
offshore_nordic('DE_Nord_20') = yes;
offshore_nordic('DE_NI') = yes;
offshore_nordic('DE_SH') = yes;



set offshore_baltic(r_full);
offshore_baltic(r_full) = no;
offshore_baltic('DE_Baltic_1') = yes;
offshore_baltic('DE_Baltic_2') = yes;
offshore_baltic('DE_Baltic_3') = yes;
offshore_baltic('DE_Baltic_4') = yes;
offshore_baltic('DE_Baltic_5') = yes;
offshore_baltic('DE_Baltic_6') = yes;
offshore_baltic('DE_MV') = yes;
offshore_baltic('DE_SH') = yes;


equation TotalCapOffshoreNord2025(YEAR_FULL,TECHNOLOGY,REGION_FULL);
TotalCapOffshoreNord2025(y,t,r)..sum((offshore,offshore_nordic), TotalCapacityAnnual('2025',Offshore,offshore_nordic)) =e= 9.4;
equation TotalCapOffshoreNord2030(YEAR_FULL,TECHNOLOGY,REGION_FULL);
TotalCapOffshoreNord2030(y,t,r)..sum((Offshore,offshore_nordic), TotalCapacityAnnual('2030',Offshore,offshore_nordic)) =e= 31.38;
equation TotalCapOffshoreNord2045(YEAR_FULL,TECHNOLOGY,REGION_FULL);
TotalCapOffshoreNord2045(y,t,r)..sum((Offshore,offshore_nordic), TotalCapacityAnnual('2045',Offshore,offshore_nordic)) =e= 64.4;


equation TotalCapOffshoreBaltic2030(YEAR_FULL,TECHNOLOGY,REGION_FULL);
TotalCapOffshoreBaltic2030(y,t,r)..sum((Offshore,offshore_baltic), TotalCapacityAnnual('2030',Offshore,offshore_baltic)) =e= 2.4;
equation TotalCapOffshoreBaltic2045(YEAR_FULL,TECHNOLOGY,REGION_FULL);
TotalCapOffshoreBaltic2045(y,t,r)..sum((Offshore,offshore_baltic), TotalCapacityAnnual('2045',Offshore,offshore_baltic)) =e= 5.6;


equation TotalCapOffshoreTotal2030(YEAR_FULL,TECHNOLOGY);
TotalCapOffshoreTotal2030(y,t)..sum((Offshore,r), TotalCapacityAnnual('2030',Offshore,r)) =g= 33.78;  
equation TotalCapOffshoreTotal2045(YEAR_FULL,TECHNOLOGY);
TotalCapOffshoreTotal2045(y,t)..sum((Offshore,r), TotalCapacityAnnual('2045',Offshore,r)) =g= 70;


OsterpaketCapacity('2030','offshore') = 30;
OsterpaketCapacity('2030','h2') = 10;

TagTechnologyToTechGroup(Offshore,'offshore')=1;
TagTechnologyToTechGroup(h2,'h2')=1;

$endif

$ifthen %switch_FEP% == 0

CommissionedTradeCapacity(r,rr,f,y) = 0;

$endif


*
ProductionByTechnologyAnnual.fx('2040',t,'Power',r)$(sum(m,InputActivityRatio(r,t,'Hardcoal',m,'2040'))) = 0;
ProductionByTechnologyAnnual.fx('2040',t,'Power',r)$(sum(m,InputActivityRatio(r,t,'Lignite',m,'2040'))) = 0;
AvailabilityFactor(r,'P_Nuclear',y)$(YearVal(y)>2020) = 0;
AvailabilityFactor(r,'P_Coal_Lignite',y)$(YearVal(y)>2035) = 0;
AvailabilityFactor('DE_NRW','P_Coal_Lignite',y)$(YearVal(y)>2030) = 0;
AvailabilityFactor(r,'P_Coal_Hardcoal',y)$(YearVal(y)>2035) = 0;
AvailabilityFactor(r,'CHP_Coal_Hardcoal',y)$(YearVal(y)>2035) = 0;
AvailabilityFactor(r,'CHP_Coal_Lignite',y)$(YearVal(y)>2035) = 0;
AvailabilityFactor('DE_NRW','CHP_Coal_Lignite',y)$(YearVal(y)>2030) = 0;


AvailabilityFactor(r,'R_Coal_Hardcoal',y)$(YearVal(y) > 2020) = 0;
*
*
*##### Baseyearproduction & capacity for DE_Nord & DE_Baltic (Werte aus der Excel)

RegionalBaseYearProduction(r,'RES_Wind_Offshore_Deep','Power','2018')$offshore_hub_sea(r) = 0;
RegionalBaseYearProduction('DE_MV','RES_Wind_Offshore_Transitional','Power','2018') = 0;
RegionalBaseYearProduction('DE_NI','RES_Wind_Offshore_Transitional','Power','2018') = 0;
RegionalBaseYearProduction('DE_SH','RES_Wind_Offshore_Transitional','Power','2018') = 0;


*### Residual Capaciy der bundesländer auf Null & Neue ResCap für DE_Nord & DE_Baltic 
ResidualCapacity('DE_MV','RES_Wind_Offshore_Transitional',y) = 0;
ResidualCapacity('DE_NI','RES_Wind_Offshore_Transitional',y) = 0;
ResidualCapacity('DE_SH','RES_Wind_Offshore_Transitional',y) = 0;

ResidualCapacity('DE_Nord_1','RES_Wind_Offshore_Deep','2018') = 0;
ResidualCapacity('DE_Nord_1','RES_Wind_Offshore_Deep','2020') = 0;
ResidualCapacity('DE_Nord_1','RES_Wind_Offshore_Deep','2025') = 0;
ResidualCapacity('DE_Nord_1','RES_Wind_Offshore_Deep','2030') = 0;
ResidualCapacity('DE_Nord_1','RES_Wind_Offshore_Deep','2035') = 0;

ResidualCapacity('DE_Nord_2','RES_Wind_Offshore_Deep','2018') = 0.572;
ResidualCapacity('DE_Nord_2','RES_Wind_Offshore_Deep','2020') = 1.633;
ResidualCapacity('DE_Nord_2','RES_Wind_Offshore_Deep','2025') = 1.633;
ResidualCapacity('DE_Nord_2','RES_Wind_Offshore_Deep','2030') = 1.633;
ResidualCapacity('DE_Nord_2','RES_Wind_Offshore_Deep','2035') = 1.633;

ResidualCapacity('DE_Nord_3','RES_Wind_Offshore_Deep','2018') = 0.610;
ResidualCapacity('DE_Nord_3','RES_Wind_Offshore_Deep','2020') = 0.610;
ResidualCapacity('DE_Nord_3','RES_Wind_Offshore_Deep','2025') = 0.852;
ResidualCapacity('DE_Nord_3','RES_Wind_Offshore_Deep','2030') = 0.852;
ResidualCapacity('DE_Nord_3','RES_Wind_Offshore_Deep','2035') = 0.852;

ResidualCapacity('DE_Nord_4','RES_Wind_Offshore_Deep','2018') = 0.366;
ResidualCapacity('DE_Nord_4','RES_Wind_Offshore_Deep','2020') = 0.366;
ResidualCapacity('DE_Nord_4','RES_Wind_Offshore_Deep','2025') = 0.708;
ResidualCapacity('DE_Nord_4','RES_Wind_Offshore_Deep','2030') = 0.708;
ResidualCapacity('DE_Nord_4','RES_Wind_Offshore_Deep','2035') = 0.708;

ResidualCapacity('DE_Nord_5','RES_Wind_Offshore_Deep','2018') = 0.896;
ResidualCapacity('DE_Nord_5','RES_Wind_Offshore_Deep','2020') = 0.896;
ResidualCapacity('DE_Nord_5','RES_Wind_Offshore_Deep','2025') = 0.896;
ResidualCapacity('DE_Nord_5','RES_Wind_Offshore_Deep','2030') = 0.896;
ResidualCapacity('DE_Nord_5','RES_Wind_Offshore_Deep','2035') = 0.896;

ResidualCapacity('DE_Nord_6','RES_Wind_Offshore_Deep','2018') = 0.802;
ResidualCapacity('DE_Nord_6','RES_Wind_Offshore_Deep','2020') = 0.1054;
ResidualCapacity('DE_Nord_6','RES_Wind_Offshore_Deep','2025') = 0.1054;
ResidualCapacity('DE_Nord_6','RES_Wind_Offshore_Deep','2030') = 0.1054;
ResidualCapacity('DE_Nord_6','RES_Wind_Offshore_Deep','2035') = 0.1054;

ResidualCapacity('DE_Nord_7','RES_Wind_Offshore_Deep','2018') = 0;
ResidualCapacity('DE_Nord_7','RES_Wind_Offshore_Deep','2020') = 0;
ResidualCapacity('DE_Nord_7','RES_Wind_Offshore_Deep','2025') = 0;
ResidualCapacity('DE_Nord_7','RES_Wind_Offshore_Deep','2030') = 0;
ResidualCapacity('DE_Nord_7','RES_Wind_Offshore_Deep','2035') = 0;

ResidualCapacity('DE_Nord_8','RES_Wind_Offshore_Deep','2018') = 0.400;
ResidualCapacity('DE_Nord_8','RES_Wind_Offshore_Deep','2020') = 0.518;
ResidualCapacity('DE_Nord_8','RES_Wind_Offshore_Deep','2025') = 0.518;
ResidualCapacity('DE_Nord_8','RES_Wind_Offshore_Deep','2030') = 0.518;
ResidualCapacity('DE_Nord_8','RES_Wind_Offshore_Deep','2035') = 0.518;

ResidualCapacity('DE_Nord_9','RES_Wind_Offshore_Deep','2018') = 0;
ResidualCapacity('DE_Nord_9','RES_Wind_Offshore_Deep','2020') = 0;
ResidualCapacity('DE_Nord_9','RES_Wind_Offshore_Deep','2025') = 0;
ResidualCapacity('DE_Nord_9','RES_Wind_Offshore_Deep','2030') = 0;
ResidualCapacity('DE_Nord_9','RES_Wind_Offshore_Deep','2035') = 0;

ResidualCapacity('DE_Nord_10','RES_Wind_Offshore_Deep','2018') = 0;
ResidualCapacity('DE_Nord_10','RES_Wind_Offshore_Deep','2020') = 0;
ResidualCapacity('DE_Nord_10','RES_Wind_Offshore_Deep','2025') = 0;
ResidualCapacity('DE_Nord_10','RES_Wind_Offshore_Deep','2030') = 0;
ResidualCapacity('DE_Nord_10','RES_Wind_Offshore_Deep','2035') = 0;

ResidualCapacity('DE_Nord_11','RES_Wind_Offshore_Deep','2018') = 0;
ResidualCapacity('DE_Nord_11','RES_Wind_Offshore_Deep','2020') = 0;
ResidualCapacity('DE_Nord_11','RES_Wind_Offshore_Deep','2025') = 0;
ResidualCapacity('DE_Nord_11','RES_Wind_Offshore_Deep','2030') = 0;
ResidualCapacity('DE_Nord_11','RES_Wind_Offshore_Deep','2035') = 0;

ResidualCapacity('DE_Nord_12','RES_Wind_Offshore_Deep','2018') = 0;
ResidualCapacity('DE_Nord_12','RES_Wind_Offshore_Deep','2020') = 0;
ResidualCapacity('DE_Nord_12','RES_Wind_Offshore_Deep','2025') = 0;
ResidualCapacity('DE_Nord_12','RES_Wind_Offshore_Deep','2030') = 0;
ResidualCapacity('DE_Nord_12','RES_Wind_Offshore_Deep','2035') = 0;

ResidualCapacity('DE_Nord_13','RES_Wind_Offshore_Deep','2018') = 0;
ResidualCapacity('DE_Nord_13','RES_Wind_Offshore_Deep','2020') = 0;
ResidualCapacity('DE_Nord_13','RES_Wind_Offshore_Deep','2025') = 0;
ResidualCapacity('DE_Nord_13','RES_Wind_Offshore_Deep','2030') = 0;
ResidualCapacity('DE_Nord_13','RES_Wind_Offshore_Deep','2035') = 0;

ResidualCapacity('DE_Nord_14','RES_Wind_Offshore_Deep','2018') = 0;
ResidualCapacity('DE_Nord_14','RES_Wind_Offshore_Deep','2020') = 0;
ResidualCapacity('DE_Nord_14','RES_Wind_Offshore_Deep','2025') = 0;
ResidualCapacity('DE_Nord_14','RES_Wind_Offshore_Deep','2030') = 0;
ResidualCapacity('DE_Nord_14','RES_Wind_Offshore_Deep','2035') = 0;

ResidualCapacity('DE_Nord_16','RES_Wind_Offshore_Deep','2018') = 0;
ResidualCapacity('DE_Nord_16','RES_Wind_Offshore_Deep','2020') = 0;
ResidualCapacity('DE_Nord_16','RES_Wind_Offshore_Deep','2025') = 0;
ResidualCapacity('DE_Nord_16','RES_Wind_Offshore_Deep','2030') = 0;
ResidualCapacity('DE_Nord_16','RES_Wind_Offshore_Deep','2035') = 0;

ResidualCapacity('DE_Nord_17','RES_Wind_Offshore_Deep','2018') = 0;
ResidualCapacity('DE_Nord_17','RES_Wind_Offshore_Deep','2020') = 0;
ResidualCapacity('DE_Nord_17','RES_Wind_Offshore_Deep','2025') = 0;
ResidualCapacity('DE_Nord_17','RES_Wind_Offshore_Deep','2030') = 0;
ResidualCapacity('DE_Nord_17','RES_Wind_Offshore_Deep','2035') = 0;

ResidualCapacity('DE_Nord_19','RES_Wind_Offshore_Deep','2018') = 0;
ResidualCapacity('DE_Nord_19','RES_Wind_Offshore_Deep','2020') = 0;
ResidualCapacity('DE_Nord_19','RES_Wind_Offshore_Deep','2025') = 0;
ResidualCapacity('DE_Nord_19','RES_Wind_Offshore_Deep','2030') = 0;
ResidualCapacity('DE_Nord_19','RES_Wind_Offshore_Deep','2035') = 0;

ResidualCapacity('DE_Nord_20','RES_Wind_Offshore_Deep','2018') = 0;
ResidualCapacity('DE_Nord_20','RES_Wind_Offshore_Deep','2020') = 0;
ResidualCapacity('DE_Nord_20','RES_Wind_Offshore_Deep','2025') = 0;
ResidualCapacity('DE_Nord_20','RES_Wind_Offshore_Deep','2030') = 0;
ResidualCapacity('DE_Nord_20','RES_Wind_Offshore_Deep','2035') = 0;

ResidualCapacity('DE_Baltic_1','RES_Wind_Offshore_Deep','2018') = 0.350;
ResidualCapacity('DE_Baltic_1','RES_Wind_Offshore_Deep','2020') = 0.735;
ResidualCapacity('DE_Baltic_1','RES_Wind_Offshore_Deep','2025') = 0.735;
ResidualCapacity('DE_Baltic_1','RES_Wind_Offshore_Deep','2030') = 0.735;
ResidualCapacity('DE_Baltic_1','RES_Wind_Offshore_Deep','2035') = 0.735;

ResidualCapacity('DE_Baltic_2','RES_Wind_Offshore_Deep','2018') = 0;
ResidualCapacity('DE_Baltic_2','RES_Wind_Offshore_Deep','2020') = 0;
ResidualCapacity('DE_Baltic_2','RES_Wind_Offshore_Deep','2025') = 0.476;
ResidualCapacity('DE_Baltic_2','RES_Wind_Offshore_Deep','2030') = 0.476;
ResidualCapacity('DE_Baltic_2','RES_Wind_Offshore_Deep','2035') = 0.476;

ResidualCapacity('DE_Baltic_3','RES_Wind_Offshore_Deep','2018') = 0.288;
ResidualCapacity('DE_Baltic_3','RES_Wind_Offshore_Deep','2020') = 0.288;
ResidualCapacity('DE_Baltic_3','RES_Wind_Offshore_Deep','2025') = 0.288;
ResidualCapacity('DE_Baltic_3','RES_Wind_Offshore_Deep','2030') = 0.288;
ResidualCapacity('DE_Baltic_3','RES_Wind_Offshore_Deep','2035') = 0.288;

ResidualCapacity('DE_Baltic_4','RES_Wind_Offshore_Deep','2018') = 0;
ResidualCapacity('DE_Baltic_4','RES_Wind_Offshore_Deep','2020') = 0;
ResidualCapacity('DE_Baltic_4','RES_Wind_Offshore_Deep','2025') = 0.257;
ResidualCapacity('DE_Baltic_4','RES_Wind_Offshore_Deep','2030') = 0.257;
ResidualCapacity('DE_Baltic_4','RES_Wind_Offshore_Deep','2035') = 0.257;

ResidualCapacity('DE_Baltic_5','RES_Wind_Offshore_Deep','2018') = 0;
ResidualCapacity('DE_Baltic_5','RES_Wind_Offshore_Deep','2020') = 0;
ResidualCapacity('DE_Baltic_5','RES_Wind_Offshore_Deep','2025') = 0;
ResidualCapacity('DE_Baltic_5','RES_Wind_Offshore_Deep','2030') = 0;
ResidualCapacity('DE_Baltic_5','RES_Wind_Offshore_Deep','2035') = 0;

ResidualCapacity('DE_Baltic_6','RES_Wind_Offshore_Deep','2018') = 0.048;
ResidualCapacity('DE_Baltic_6','RES_Wind_Offshore_Deep','2020') = 0.048;
ResidualCapacity('DE_Baltic_6','RES_Wind_Offshore_Deep','2025') = 0.048;
ResidualCapacity('DE_Baltic_6','RES_Wind_Offshore_Deep','2030') = 0.048;
ResidualCapacity('DE_Baltic_6','RES_Wind_Offshore_Deep','2035') = 0.048;
*
*
parameter Renovierungsrate;
Renovierungsrate(y)=0.015;
Renovierungsrate(y)$(YearVal(y)>2020)=0.035;
Renovierungsrate(y)$(YearVal(y)>2030)=0.045;
Renovierungsrate(y)$(YearVal(y)>2040)=0.065;

equation BuildingsInertia(REGION_FULL,TECHNOLOGY,YEAR_FULL);
BuildingsInertia(r,t,y)$(TagTechnologyToSector(t,'Buildings') and YearVal(y)>2015 and sum((tt)$(TagTechnologyToSubsets(tt,'CHP')),diag(t,tt))=0).. ProductionByTechnologyAnnual(y,t,'Heat_Low_Residential',r) =g= (1-sum(yy$(Yearval(yy)<=Yearval(y)),Renovierungsrate(yy)*YearlyDifferenceMultiplier(yy-1)))*ProductionByTechnologyAnnual('2018',t,'Heat_Low_Residential',r);

***constraint on emissions: emissions per sector are not allowed to increase***
equation E13a_SectoralEmissionReduction(y_full, EMISSION, SECTOR, REGION_FULL);
E13a_SectoralEmissionReduction(y,e,se,r)$(YearVal(y)>2018).. AnnualSectoralEmissions(y,e,se,r) =l= AnnualSectoralEmissions(y-1,e,se,r);

*equation E13b_RegionalSectoralEmissionReduction(y_full, EMISSION, SECTOR, REGION_FULL);
*E13b_RegionalSectoralEmissionReduction(y,e,se,r)$(YearVal(y)>2018).. AnnualSectoralEmissions(y,e,se,r) =l= 1.15*AnnualSectoralEmissions(y-1,e,se,r);
**

equation DistrictHeatingShareHLR(YEAR_FULL,FUEL);
DistrictHeatingShareHLR(y,f)..sum(r,ProductionByTechnologyAnnual('2050','HLR_Convert_DH','Heat_Low_Residential',r)) =g= 0.45*sum((r,t),ProductionByTechnologyAnnual('2050',t,'Heat_Low_Residential',r));

equation DistrictHeatingShareHLI(YEAR_FULL,FUEL);
DistrictHeatingShareHLI(y,f)..sum(r,ProductionByTechnologyAnnual('2050','HLI_Convert_DH','Heat_Low_Industrial',r)) =g= 0.1*sum((r,t),ProductionByTechnologyAnnual('2050',t,'Heat_Low_Industrial',r));