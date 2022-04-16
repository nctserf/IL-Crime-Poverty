% 20211130:Illinois_Crime_Poverty_2018
% MatlabR2021b

%% Data Import
fileID=fopen('2018 Illinois Crime Statistics.csv');
formatSpec='%s %f %f %f %f %f %f %f %f %f %f';
C=textscan(fileID,formatSpec,'HeaderLines',1,'Delimiter',',');
fileID1=fopen('2018 Illinois County Population Statistics.csv');
formatSpec1='%s %f %f %f %f %f %f %f %f %f %f %f %f';
C1=textscan(fileID1,formatSpec1,'HeaderLines',4,'Delimiter',',');
fileID2=fopen('2018 Poverty Statistics.csv');
formatSpec2='%f %f %s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';
C2=textscan(fileID2,formatSpec2,'HeaderLines',4,'Delimiter',',');
%% Initial Variable Assignment
crime_counties=C{1};
violent_crime_incidence=C{2};
property_crime_incidence=C{7};
population_counties=C1{1};
population_estimates=C1{12};
poverty_states=C2{3};
poverty_counties=C2{4};
poverty_rates=C2{8};
%% Extract Illinois Counties from poverty Arrays
poverty_counties_index_Illinois=[];
for i=1:length(poverty_states)
    if poverty_states{i}=='IL'
       poverty_counties_index_Illinois=[poverty_counties_index_Illinois;i];
    end
end
poverty_counties_Illinois={poverty_counties{poverty_counties_index_Illinois}}';
poverty_rates_Illinois=[poverty_rates(poverty_counties_index_Illinois)];
%% Remove Elements of population, poverty Arrays Not Included in crime_counties
% crime_counties contains fewer Illinois counties than do the population
% and poverty arrays, so must remove certain elements from these sets of
% arrays
crime_counties=strcat(crime_counties,' County');
population_counties{20}='DeWitt County';
poverty_counties_Illinois{21}='DeWitt County';
comparison=ismember(population_counties,crime_counties);
indices=find(comparison);
population_counties={population_counties{indices}}';
population_estimates=[population_estimates(indices)];
comparison1=ismember(poverty_counties_Illinois,crime_counties);
indices1=find(comparison1);
poverty_counties_Illinois={poverty_counties_Illinois{indices1}}';
poverty_rates_Illinois=[poverty_rates_Illinois(indices1)];
%% Sort Crime Incidence Alphabetically
[sorted_crime_counties,I]=sort(crime_counties);
violent_crime_incidence=violent_crime_incidence(I);
property_crime_incidence=property_crime_incidence(I);
%% Convert Crime Incidence to Crime Rates
violent_crime_rate=violent_crime_incidence./population_estimates;
property_crime_rate=property_crime_incidence./population_estimates;
%% Sort Poverty Rates Numerically, Sort Crime Rates Correspondingly
[sorted_poverty_rates_Illinois,I1]=sort(poverty_rates_Illinois);
sorted_violent_crime_rate=violent_crime_rate(I1);
sorted_property_crime_rate=property_crime_rate(I1);
%% Write Table of Poverty Rates and Crime Rates to Text File
Rank=[1:length(sorted_poverty_rates_Illinois)]';
T=table(Rank,round(sorted_poverty_rates_Illinois,1),round(sorted_violent_crime_rate,5),round(sorted_property_crime_rate,5));
T.Properties.VariableNames={'Rank','Poverty Rates (%)','Violent Crime Rates','Property Crime Rates'};
writetable(T,'Illinois_Crime_Poverty_2018.txt','Delimiter',',')
%% Plot Crime Rates Against Poverty Rates Along with Linear Model
subplot(2,1,1)
set(gcf,'color','w')
[f,gof]=fit(sorted_poverty_rates_Illinois,sorted_violent_crime_rate,'poly1');
plot(sorted_poverty_rates_Illinois,sorted_violent_crime_rate,'ro',sorted_poverty_rates_Illinois,f(sorted_poverty_rates_Illinois),'-k','LineWidth',1.5,'MarkerSize',4,'MarkerFaceColor','r')
title('Poverty, Violent Crime, and Property Crime in Illinois: 2018','FontSize',12)
xlabel("2018 Illinois County Poverty Rates (%)",'FontSize',12)
ylabel("2018 Illinois County Violent Crime Rates",'FontSize',10)
legend({'Data','Linear Model'},'FontSize',12,'Location','best')
subplot(2,1,2)
[f1,gof1]=fit(sorted_poverty_rates_Illinois,sorted_property_crime_rate,'poly1');
plot(sorted_poverty_rates_Illinois,sorted_property_crime_rate,'bo',sorted_poverty_rates_Illinois,f1(sorted_poverty_rates_Illinois),'-k','LineWidth',1.5,'MarkerSize',4,'MarkerFaceColor','b')
xlabel("2018 Illinois County Poverty Rates (%)",'FontSize',12)
ylabel("2018 Illinois County Property Crime Rates",'FontSize',10)
legend({'Data','Linear Model'},'FontSize',12)
exportgraphics(gcf,'Illinois_Crime_Poverty_Graphs_2018.jpg','Resolution',300)
%% Write Results to a Text File
fID=fopen('Illinois_Crime_Poverty_2018_Results.txt','w');
fprintf(fID,'%s %f %s %s %f %s\n','The coefficient of determination for a linear model of 2018 Illinois violent crime rates vs. 2018 Illinois county poverty rates is ',gof.rsquare,'. This value indicates that the data is not appropriately represented by a linear model.','The coefficient of determination for a linear model of 2018 Illinois property crime rates vs. 2018 Illinois county poverty rates is ',gof1.rsquare,'. This value indicates that the data is not appropriately represented by a linear model.');
fclose(fID);

