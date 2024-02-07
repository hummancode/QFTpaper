%% restrict controller gs
EHA_cascadePlant;
Gcell = importdata("D:\EHA - Control & Simulation\QFT\Designs\v04\G_data\Gcell_cascade2.mat");
g_array1 = Gcell{1};
g_array2 = Gcell{2};
g_array3 = Gcell{3};
g_array4 = Gcell{4};
w_m={[ 0.001, 0.01, 0.1 , 1, 10, 30, 50, 100, 500], 
     [0.1, 1, 10, 30,50,100],
     [0.01, 0.1, 1, 10,30,50],
     [1 10 30 50 100]};
w_a = merge_frequency_points(w_m);
[gmin,gmax,EHAphase] = g_restrictor4(w_a,Parray,Pnom,Gcell); 

G0 = tf(1,[1 0  ]);
g_gain = 165.2e3;

%% Initialization
F=100;
parameter_count = 6;
% Parameters
K_array={};
iterations =50;
W = 0.9;
C1 = 2;
C2 = 2;
n = 49;
% ---- initial swarm position -----
index = 1;
for i = 1 : 7
for j = 1 : 7
for k=1:7
    for l=1:7
        for m=1:7
            for n =1:7
particle(index, 1, 1) = i*200;
particle(index, 1, 2) = j*2;
particle(index, 1, 3) = k*2000;
particle(index, 1, 4) = l*50;
particle(index, 1, 5) = m*0.1;
particle(index, 1, 6) = n*20;
index = index + 1;
end
end
end
end
end
end
particle(:, 4, 1) = 10000000;          % best value so far
particle(:, 2, :) = 5.9e1;             % initial velocity


%% Iterations

for iter = 1 : iterations

for i = 1 : n
for pcounter =1: parameter_count
particle(i, 1, pcounter) = max(1e-2,particle(i, 1, pcounter) + particle(i, 2, pcounter)/1.3); %update y position
end


for counter=1:6
if particle(i,1,counter)>1e4
    particle(i,1,counter)=1e4;
end
end

K1 = particle(i, 1, 1);
K2 = particle(i, 1, 2);
K3 = particle(i, 1, 3);
K4 = particle(i, 1, 4);
K5 = particle(i, 1, 5);
K6 = particle(i, 1, 6);
K_array=[K_array,[K1 ; K2; K3; K4; K5; K6]];

% e=Z.SettlingMax;
% alpha=0.5;

G1 =  tf([1/K1 1],[1/K2 1])*tf([1/K3 1],[1/K4 1])*tf([1/K5 1],[1/K6 1]); 
GQFT = g_gain*G0*G1;



F =  QFTcost(GQFT,Pnom,EHAphase,w_a,gmin,gmax) ;          % fitness evaluation
        
if F < particle(i, 4, 1)                 % if new cost is better
particle(i, 3, 1) = particle(i, 1, 1);    % update best x,
particle(i, 3, 2) = particle(i, 1, 2);    % best y postions
particle(i, 3, 3) = particle(i, 1, 3);    % best z postions
particle(i, 3, 4) = particle(i, 1, 4);    
particle(i, 3, 5) = particle(i, 1, 5);   
particle(i, 3, 6) = particle(i, 1, 6);   
particle(i, 4, 1) = F;               % and best value
end
end
[temp, gbest] = min(particle(:, 4, 1));        % global best position
%--- updating velocity vectors
for i = 1 : n
particle(i, 2, 1) = rand*W*particle(i, 2, 1) + C1*rand*(particle(i, 3, 1) - particle(i, 1, 1)) + C2*rand*(particle(gbest, 3, 1) - particle(i, 1, 1));   %x velocity component

particle(i, 2, 2) = rand*W*particle(i, 2, 2) + C1*rand*(particle(i, 3, 2) - particle(i, 1, 2)) + C2*rand*(particle(gbest, 3, 2) - particle(i, 1, 2));   %y velocity component

particle(i, 2, 3) = rand*W*particle(i, 2, 3) + C1*rand*(particle(i, 3, 3) - particle(i, 1, 3)) + C2*rand*(particle(gbest, 3, 3) - particle(i, 1, 3));   %z velocity component

particle(i, 2, 4) = rand*W*particle(i, 2, 4) + C1*rand*(particle(i, 3, 4) - particle(i, 1, 4)) + C2*rand*(particle(gbest, 3, 4) - particle(i, 1, 4));   %z velocity component

particle(i, 2, 5) = rand*W*particle(i, 2, 5) + C1*rand*(particle(i, 3, 5) - particle(i, 1, 5)) + C2*rand*(particle(gbest, 3, 5) - particle(i, 1, 5));   %z velocity component

particle(i, 2, 6) = rand*W*particle(i, 2, 6) + C1*rand*(particle(i, 3, 6) - particle(i, 1, 6)) + C2*rand*(particle(gbest, 3, 6) - particle(i, 1, 6));   %z velocity component

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
axis([-1e4 1e4 -1e4 1e4]);
pause(0)
end



