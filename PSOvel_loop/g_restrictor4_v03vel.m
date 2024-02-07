function [wL,wL2,wL3] = g_restrictor4_v02(w_a,Parray,Pnom,Gcell)

phi_a=[-360: 5: 0];
N=length(phi_a)*length(w_a)*900;
wL={};
wL2={};
wL3={};
lengthP=length(Parray);

for i=1:length(w_a)
    w_freq=w_a(i);
    disp(i);
    disp(w_freq);
    
    G_phi_min=zeros(1,length(phi_a));
    G_phi_max=zeros(1,length(phi_a));
    Gphases=zeros(1,length(phi_a));
    %[p,pphase] = mag_phase(pmotor,w_freq*j);  %replaced p11 with pmotor% REVERT WHEN USING EHA
    % actually not need p,pphase
    maxphi=0;
    minphi=0;

    for jc=1:length(phi_a)
        [p,pphase] = mag_phase(Pnom,w_freq*j);
        maxb=0;
        minb=1000000000000;
        for k=1:lengthP
            gmin=0;
            gmax=0;
            glist1={};
            glist2={};
            for ig=1:length(Gcell) 
                g_array = Gcell{ig};
                glist1{ig} = abs((g_array((i-1)*lengthP*73+(jc-1)*lengthP+k,1)));
                glist1{ig+length(Gcell)} = abs((g_array((i-1)*lengthP*73+(jc-1)*lengthP+k,2)));
                
            end
            %disp(size(glist1))
            gmax=max(cell2mat(glist1));
            gmin=min(cell2mat(glist1));

            if gmax>=maxb
                maxb=gmax;
            end
            if gmin<=minb
                minb=gmin;
            end 
            bound_min=minb;
            bound_max=maxb;
            
        end
        
            G_phi_min(jc)=vpa(bound_min*p);
            G_phi_max(jc)=vpa(bound_max*p);
            Gphases(jc)=mod((phi_a(jc)+pphase),-360);
    end
    wL=[wL,G_phi_min];
    wL2=[wL2,G_phi_max];
    wL3=[wL3,Gphases];
end
end