opts = bodeoptions;
opts.XLim={[1e-2,3e3]};

margin(Pnom*GQFT,opts)
plot_Nichols2(gmin,gmax,EHAphase,w_a,Pnom,GQFT)
Gcont = GQFT
%GQFT_controllerv02, used in paper
%%
K1=cell2mat(K_array)
iterations = 0: 250/length(K_array):250;
for i=1:6
semilogy(iterations(2:end),movmean(K1(i,:),10),"DisplayName",sprintf("K_%d",i),"LineWidth",2)
hold on
end
xlabel("iterations");
xlim([0,100])
ylabel("value");
grid on 
grid minor
%%
QFTcost(Gcont,Pnom,EHAphase,w_a,gmin,gmax) 
%%
QFTcost(GQFT,Pnom,EHAphase,w_a,gmin,gmax) 
%% turkish
opts.XLabel.String = "Frekans";

opts.YLabel.String{1} = "Genlik";
opts.YLabel.String{2} = "Faz";
opts.Title.String = "";
opts.Grid  = 'on';
%%
a_lo = 95;
a_up = 30; 
ksi =0.8;
wn=1.25*a_up/ksi;
T6up=tf([1/a_up,1],[1/wn^2,2*ksi/wn,1]);
T6lo=tf(1,[1/a_lo^2,2/a_lo,1]);    
figure(2)
%F= tf([1/42 1],[1/277 1])*tf([1],[1/57 1])*tf([1],[1/77 1]);
F= tf([1],[1/167 1])*tf([1/900 1],[1/1600 1]);
hold on 
h=bodeplot(T6lo);
bodeplot(F*GQFT*Pnom/(GQFT*Pnom+1),'k',opts);
bodeplot(GQFT*Pnom/(GQFT*Pnom+1),'k--',opts);
bodeplot(T6up);
h=legend("T6_{up}","T6_{low}","Ön filtreli kapalı döngü","Ön filtresiz kapalı döngü");
%set(h,'Interpreter','latex')
grid on
grid minor


%%
for j=1:25
i=randi(length(Parray));
disp(i)
bodeplot(F*GQFT*Parray{i}/(GQFT*Parray{i}+1))
hold on
end
%% step
step(T6lo);
hold on
step(GQFT*Pnom*F/(GQFT*Pnom+1));

step(T6up);

%%  stifness
opts.PhaseVisible='off';
Mk=2e-8*tf([1/150 1],[1/1200 1])*tf([1/150 1],[1/1200 1]);
bodeplot(1/Mk,'k',opts);
hold on 
bodeplot((F_tf*tf([1],[1 0])/(GQFT*Pnom+1))^(-1),opts)

%%

for j=1:55
i=randi(length(Parray));
disp(i)
bodeplot((F_tf*tf([1],[1 0])/(GQFT*Parray{i}+1))^(-1),opts)
hold on
end
grid on
grid minor