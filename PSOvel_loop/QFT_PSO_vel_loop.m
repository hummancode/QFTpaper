
clear;
rng(3);
%% EHA transfer function and plant
EHA_cascade_plant_velTf;
w_m={ [0.01, 0.1 ,20, 200, 300,500],[]
        };
w_a =merge_frequency_points(w_m);
Ws = 1.16;
ad_rad = 600; % rad/s sensitivity 

%%

%%
Gcell = importdata("velSPO\Gcell_sens.mat");

%% restrict controller gs

[gmin,gmax,EHAphase] = g_restrictor4(w_a,Parray,Pnom,Gcell); 
 g_array1=Gcell{1};
 g_array2=Gcell{2};
%% g1 
plot_plainNichols(g_array1,w_a,Pnom,length(Parray))
%% restrict controller gs
Gcont = 1; %default controller
plot_NicholsVel(gmin,gmax,EHAphase,w_a,Pnom,Gcont)


%% Initialization
parameter_count = 3;
% Parameters
K_array={};
Farray={};
iterations =50;
W = 0.9;
C1 = 2;
C2 = 2;
n = 49;
% ---- initial swarm position -----


mu = 1;
sigma = 35;

for nelor=1:n
    for parts=1:parameter_count
        particle(nelor, 1, parts) = abs(random('Normal',mu,sigma));
    end
end
particle(:, 4, 1) = 100000;          % best value so far
particle(:, 2, :) = 6.9e1;             % initial velocity


%% Iterations

for iter = 1 : iterations

for i = 1 : n
for pcounter =1: parameter_count
particle(i, 1, pcounter) = max(1e-2,particle(i, 1, pcounter) + particle(i, 2, pcounter)/1.3); %update y position
end


for counter=1:parameter_count
if particle(i,1,counter)>1e4
    particle(i,1,counter)=1e4;
end
end

K1 = particle(i, 1, 1);
K2 = particle(i, 1, 2);
K3 = particle(i, 1, 3);

K_array=[K_array,[K1 ; K2; K3]];

% e=Z.SettlingMax;
% alpha=0.5;

G1 =  pid(K1,K2)*tf([1],[1/K3 1])/k_T; 
GQFT = G1;



F =  QFTcostvel(Ws,GQFT,Pnom,EHAphase,w_a,gmin,gmax) ;          % fitness evaluation
        
if F < particle(i, 4, 1)                 % if new cost is better
for counter=1:parameter_count
particle(i, 3, counter) = particle(i, 1, counter);    % update best x,
end
particle(i, 4, 1) = F;               % and best value
end
end
Farray =[Farray,particle(i, 4, 1)]; %cost of best positions array
[temp, gbest] = min(particle(:, 4, 1));        % global best position
%--- updating velocity vectors
for i = 1 : n
for counter=1:parameter_count
particle(i, 2, counter) = rand*W*particle(i, 2, counter) + C1*rand*(particle(i, 3, counter) - particle(i, 1, counter)) + C2*rand*(particle(gbest, 3, counter) - particle(i, 1, counter));   %x velocity component

end 
if particle(i,2,1)>1e4
    particle(i,2,1)=1e4;
end
if particle(i,2,2)>1e4
    particle(i,2,2)=1e4;
end
end
%% Plotting the swarm
clf    
plot(particle(:, 1, 1), particle(:, 1, 2), 'x')   
axis([-1e3 1e3 -1e3 1e3]);
pause(0)
end


%% analyze

bode(1/(1+Pnom*GQFT))
hold on 

T3=tf([1/ad_rad 0],[1/ad_rad,1]);
bode(T3)
bode(Pnom*GQFT/(1+Pnom*GQFT))
%%

plot_NicholsVel_plain(gmin,gmax,EHAphase,w_a,Pnom,GQFT)
F =  QFTcostvel(Ws,GQFT,Pnom,EHAphase,w_a,gmin,gmax)
%%
%%
K_arrayPI=cell2mat(K_array);
its_array = 0: iterations/length(K_array):iterations;
for i=1:3
semilogy(its_array(2:end),movmean(K_arrayPI(i,:),2),"DisplayName",sprintf("K_%d",i),"LineWidth",2)
hold on
end
xlabel("iterations");
xlim([0,iterations])
ylabel("value");
grid on 
grid minor
%%
F_arrayPI=cell2mat(Farray);


plot(F_arrayPI,'k',"DisplayName","cost","LineWidth",2)

xlabel("iterations");
xlim([0,iterations])
%ylim([-10,1000])
ylabel("value");
grid on 
grid minor

%%
Gsens = importdata("D:\EHA - Control & Simulation\QFT\PSO\velSPO\Gcell_sens.mat");
Gstab = importdata("D:\EHA - Control & Simulation\QFT\PSO\velSPO\Gcell_stab.mat");
Farray = importdata("D:\EHA - Control & Simulation\QFT\PSO\velSPO\Farray.mat");
K_array = importdata("D:\EHA - Control & Simulation\QFT\PSO\velSPO\Karray.mat");
GQFT = importdata("D:\EHA - Control & Simulation\QFT\PSO\velSPO\PIControllerGOOD.mat");
%%
[gmin1,gmax1,EHAphase1] = g_restrictor4(w_a,Parray,Pnom,Gsens); 
[gmin2,gmax2,EHAphase2] = g_restrictor4(w_a,Parray,Pnom,Gstab); 
%%
subplot(1,2,1)
plot_NicholsVel_plain(gmin1,gmax1,EHAphase1,w_a,Pnom,GQFT)
grid minor 
%%
subplot(1,2,2)
plot_NicholsVel2(gmin2,gmax2,EHAphase2,w_a,Pnom,GQFT)
grid minor 