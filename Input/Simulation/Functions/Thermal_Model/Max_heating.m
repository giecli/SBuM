function [Max_heating, Dwelling_env_heat, Ventilation_heater] = Max_heating(N0, House_Volume, Heat_recovery_ventil_annual, Total_Loss, Loss_floor, Ventilation_Type, Temperatures_nodal0, uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, Building_Envelope, Building_Storage_constant, Air_leak)
%% Design heating capacity
% Firstly the design heating capacity needs to be assigned
%%%
% The first part comes from the heating need of the dwelling envelope
% losses
% As Oulu is part of the third geographical location its design outside
% temperature is -32 degrees. For ground temperature it is 2 degrees
% higher than annual average design temperature for the third geographical
% area (Jyv�skyl�). The annual mean design temperature is 3.4 degrees so
% design ground temperature is 5.4 degrees.

T_design_outside    = -32;
T_design_ground     = 5.4;
T_inlet             = 18;
Temp_Set            = 21;
Loss_Ventil_design = (1.2 * 1.007 * N0 * House_Volume)/3.6; 
Flow_rate           = N0;   % In design conditions, the flow rate is equal to the normal air-change rate
Internal_Heat_Gain  = 0;    % No internal heat gain in design conditions
Solar_Heat_Gain     = 0;    % No solar heat gain in design conditions
Solar_radiation     = 0;    % No solar radiation in design conditions
Solar_Radiation_vertical = 0; % No solar radiation in design conditions
% Heater_Power0       = 0;    % No heater power in free floating design conditions
% Heater_PowerMax     = 1000000;  % 'Unlimited' heater power to calculate the design heating power

% If there is a ventilation heater, then indoor heating capacity is for the
% difference of supply air temperature and indoor air temperature.
% Otherwise all the ventilation losses are met with the indoor heating.

switch Ventilation_Type
    
    case {'Natural ventilation','Mechanical ventilation'}
        
        Dwelling_env_heat = Total_Loss * (Temp_Set - T_design_outside) + Loss_floor * (Temp_Set - T_design_ground) + Loss_Ventil_design * (Temp_Set - T_design_outside);
        
    case ('Air-Air H-EX')
        
        Dwelling_env_heat = Total_Loss * (Temp_Set - T_design_outside) + Loss_floor * (Temp_Set - T_design_ground) + Loss_Ventil_design * (Temp_Set - T_inlet);
        
end

% Temperature in the free floating conditions
% [T_inside0, ~, T_operative0, ~] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power0, T_design_outside, T_design_ground, T_inlet, Temperatures_nodal0, Solar_Radiation_vertical, Solar_radiation);

% Temperature in the 'unlimited heating' conditions
% [T_insideMax, ~, T_operativeMax, ~] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_PowerMax, T_design_outside, T_design_ground, T_inlet, Temperatures_nodal0, Solar_Radiation_vertical, Solar_radiation);

% Calculate the heater power needed to achieve the temperature set-point in
% design conditions

% Dwelling_env_heat   = Heater_PowerMax * ((Temp_Set - T_inside0)/(T_insideMax - T_inside0));
% Dwelling_env_heat   = Heater_PowerMax * ((Temp_Set - T_operative0)/(T_operativeMax - T_operative0));

%%%
% Next part is calculating the heating power for the ventilation heater.
% The ventilation heater is expected to heat the inlet air to the building
% up to 18 degrees. If the dwelling has a heat recovery system then the
% heating is from the recovered temperature up to the inlet temperature.
% Otherwise the heating is estimated to happen from the outside
% temperature.
switch Ventilation_Type
    
    case {'Natural ventilation','Mechanical ventilation'}
        
        Ventilation_heater = 0;         % Do not include ventilation heater
    
    case ('Air-Air H-EX')
        
        if Heat_recovery_ventil_annual == 0     % No heat recovery, but supply air heater
            
                    Ventilation_heater = (1.2 * 1.007 * House_Volume * N0)/3.6 * (T_inlet - T_design_outside);
                    
        else
            
            Outlet_Temp_rate = (Temp_Set - 5)/(Temp_Set - T_design_outside);    % Outlet air temperature is estimated to be 5 degrees in apartments and dwellings
            Inlet_Temp_rate = Outlet_Temp_rate/1;                               % Inlet and outlet airflows are estimated to be the same for simplicities sake
            Heat_Recovery_Temp = T_design_outside + Inlet_Temp_rate * (Temp_Set - T_design_outside);
            Ventilation_heater = (1.2 * 1.007 * House_Volume * N0)/3.6 * (T_inlet - Heat_Recovery_Temp);
            
        end
        
end

% If heat recovery is able to increase the temperature higher than the
% inlet temperature, the Ventilation_heater value will became negative. It
% should then be assigned to zero.

if Ventilation_heater < 0
    Ventilation_heater = 0;
end

%%%
% Total required heating capacity is dwelling envelope's heating capacity
% and Ventilation heating capacities added together.

Dwelling_Heat_eff       = 1.0;         % 1 for electric heaters
Ventilation_Heat_eff    = 1.0;         % 1 for electric heaters
Max_heating = Dwelling_env_heat/Dwelling_Heat_eff + Ventilation_heater/Ventilation_Heat_eff;
end

