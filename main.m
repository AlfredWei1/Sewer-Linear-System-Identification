clear;
clc;
close all;

% Add current simulation into working directory
addpath(genpath("Simulation I\"));

%% Read Data
load('hurricane_dw.mat');
N = length(J1_1inflow);
time_step = 5; % In unit of second
time = 0:time_step:N*time_step-time_step;

%% Compute Relevant Hydraulic Variables

[Y1,Q1I] = C1_modeling(time,time_step,N);
[Y2,Q2I] = C2_modeling(time,time_step,N);
[Y3,Q3I] = C3_modeling(time,time_step,N);
YI = CI_modeling(time,time_step,N,Q1I,Q2I,Q3I);

%% Plot Simulation Figure

result_plotting(time,time_step,N,Y1,Y2,Y3,YI);








