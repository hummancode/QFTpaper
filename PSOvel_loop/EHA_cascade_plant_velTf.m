    
beta = 1.555e9;         %[Pa] Bulk modulu
ro      = 860;             %[kg/m^3]    Hidroligin kütlesel yogunlugu
mu      = .0155;                %[kg/(m*s)]         hidrolik vizkozite
k_T = .73;              %[Nm/A] Motorun tork katsayi
K_T=k_T;
k_E = 0.1;          %[Nm/(rad/s)] Motorun zit EMK kuvveti

T_0 = 11.4;               %[Nm] Stall torque
T_l = 2.7;               %[Nm] Yüklü hiz testindeki tork
w_l = 733;              %[rad/s] Yüklü hiz testindeki donme hizi
R =0.45; % V*k_T/T_0;          %[ohm] Armatur direnci
L = 2.1e-3;              %[H] Enduktans
J_m = 5.93*1e-4;           %[kg*m^2] Rotor ataleti
J_eq = J_m;             %[kg*m^2] Motor-pompa komplesinin toplam ataleti (Pompanin ataleti cok daha dusuk oldugu icin yoksayilmistir)
b_m = 0.426*1e-2;           %[Nm/(rad/s)] Rotorun sonumleme katsayisi
D_p = 6.6845e-07;     %[m^3/rad] Deplasman

c_eq = b_m + 1*D_p*mu;  %[Nm/(rad/s)] Motor-pompa komplesinin sonumleme katsayisi
A_p = 2572e-6;           %[m^2] Etkin piston alani
V_d = A_p*120e-3*1.3;      %[m^3] Olu hacim (akis yollarini da kapsamasi icin 1.3 ile carpildi)
m_p = 2;               %[kg] Piston kutlesi
c_c = 50;               %[N/(m/s)] Silindirdeki viskoz sürtünme
C_p = 1/9.6e11;         %[(m^3/s)/Pa] Pompanin ic kacak katsayisi
C_r = C_p;              %[(m^3/s)/Pa] Pompanin dis kacak katsayisi
C_c = 1/5e12;           %[Pa/(m3/s)] Silindir ic kacak katsayisi
C_1 = C_p + C_c + C_r;
C_2 = C_p + C_c;
C_3 = C_1 + C_2;
C_eq = C_3;
K_P = 90e3;             %[V/m] Kontrolcünün oransal katsayisi
K_I = 8.51e3;          %[V/(m*s)] Kontrolcünün integral katsayisi
K_D = 0.84e3;           %[V/(m/s)] Kontrolcünün türevsel katsayisi
f_s     = .24;                  %[Nm]               Breakaway friction
f_ps=0.1;
C_d     = .625;                 %[]                 Discharge coef.
stroke=0.12;

%%tork controller PI
TORK_KP  = 11.3;
TORK_KI = TORK_KP/(.8*1e-3);
VEL_KP=0.43;
VEL_Tn=8; %30
VEL_KI=VEL_KP*1/(VEL_Tn*1e-3);
I_p = 1/K_T; %peak cur, not peak cur. Inverse torque char
% state space with tork controller states are i, w, x ,xdot, pD,
% integral(iref-iactual)
%iref = I_p* ( VEL_KP*(wref-wact) +VEL_KI*w_e))
A = [-R/L-TORK_KP/L, -k_E/L, 0,0, 0, TORK_KI/L ;...
    k_T/J_eq, -c_eq/J_eq, 0, 0,  -D_p/J_eq, 0;...
    0, 0,  0,1, 0, 0;...
    0, 0,  0, -c_c/m_p, A_p/m_p,0 ;...
    0, (2*beta*D_p)/V_d, 0, -(2*A_p*beta)/V_d, -(beta*C_eq)/V_d , 0;...
    -1,         0,        0,        0,      0,    0];
% input is iref
B2= [TORK_KP/L, 0, 0 ,0 ,0, 1]';
B3= [0, 0, 0 ,-1/m_p ,0, 0]';



% output is w 


Cw=[0  1 0 0 0 0 ;...
    ];

D = zeros(1,1);
%P
n1=4;
n2=4;


%Plant=ss(A,B,C,D);
 

Parray={};
[b,a]= ss2tf(A,B2,Cw,D);


Parray{1}=tf(b,a);
Pnom = Parray{1};
[b,a]= ss2tf(A,B2,Cw,D);
Pw = tf(b,a);
% -- Parameters: minimum "m", maximum "M", and grid
C_eqm = 1/5e11; C_eqM = 1/5e13; i1m = 5;
D_p_m= 6.6845e-07*0.8;  D_p_M = 6.6845e-07*1.03; i2m = 2;
betam = 9.555e8; betaM = 2.155e9; i3m = 3;
c_cm = 50; c_cM= 400; i4m = 3;
k_Tm = .5920; k_TM = 0.8640; i5m = 3;

% -- Gridding
C_eqv = logspace(log10(C_eqm),log10(C_eqM),i1m);
D_pv = logspace(log10(D_p_m),log10(D_p_M),i2m);
betav = logspace(log10(betam),log10(betaM),i3m);
c_cv = logspace(log10(c_cm),log10(c_cM),i4m);
k_Tv = logspace(log10(k_Tm),log10(k_TM),i5m);
% -- Plants
c = 1;
for i1=1:i1m
C_eq = C_eqv(i1);
for i2=1:i2m
D_p = D_pv(i2);
for i3=1:i3m
beta = betav(i3);
for i4=1:i4m
c_c = c_cv(i4);
for i5=1:i5m
k_T = k_Tv(i5);
c = c + 1;


A = [-R/L-TORK_KP/L, -k_E/L, 0,0, 0, TORK_KI/L ;...
    k_T/J_eq, -c_eq/J_eq, 0, 0,  -D_p/J_eq, 0;...
    0, 0,  0,1, 0, 0;...
    0, 0,  0, -c_c/m_p, A_p/m_p,0 ;...
    0, (2*beta*D_p)/V_d, 0, -(2*A_p*beta)/V_d, -(beta*C_eq)/V_d , 0;...
    -1,         0,        0,        0,      0,    0];
% input is iref
B2= [TORK_KP/L, 0, 0 ,0 ,0, 1]';
B3= [0, 0, 0 ,-1/m_p ,0, 0]';



% output is w 


Cw=[0  1 0 0 0 0 ;...
    ];


D = zeros(1,1);
%P
%Plant=ss(A,B,C,D);
[b,a]= ss2tf(A,B2,Cw,D);
Parray{c}=tf(b,a);
end
end
end
end
end
