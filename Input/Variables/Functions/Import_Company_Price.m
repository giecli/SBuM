%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: C:\Users\jlouis\Dropbox\Smart Energy Grid and
%    House\Literature\Electricity in
%    Finland\KaikkiSiirtohinnat_Price_per_Company.xlsx Worksheet: Sheet2
%
% To extend the code for use with different selected data or a different
% spreadsheet, generate a function instead of a script.

% Auto-generated by MATLAB on 2014/10/24 14:15:56

for spsheet = 1:96
    %% Import the data
    [~, ~, raw] = xlsread('C:\Users\jlouis\Dropbox\Work\Smart House\Electricity in Finland\KaikkiSiirtohinnat_Price_per_Company.xlsx',strcat('Sheet',num2str(spsheet)),'E2:N91');
    raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};

    %% Replace non-numeric cells with NaN
    R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
    raw(R) = {NaN}; % Replace non-numeric cells

    %% Create output variable
    KaikkiSiirtohinnatPriceperCompanyS1 = reshape([raw{:}],size(raw));
    
    %% Create variable
    PriceList(:,:,spsheet)=KaikkiSiirtohinnatPriceperCompanyS1;

    %% Clear temporary variables
    clearvars raw R;
end