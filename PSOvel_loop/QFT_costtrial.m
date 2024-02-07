wspan=w_a;
gmincell=gmin;
gmaxcell=gmax;
Gtf =GQFT;

cost=0;
gmargin = 10;
pmargin = 107;
for i=1:length(wspan)
    gmax1 = gmaxcell{i};
    gmin2 = gmincell{i};
    [p,pphase] = mag_phase(Pnom*Gtf,wspan(i)*j);
    if pphase>0
    pphase=-360+pphase;
    end   
    c=EHAphase{i};
 
    eha_phaseindex =  min(find(min(abs(c-pphase)) == abs(c-pphase)));
    
    if 20*log10(p)>0 && wspan(i)<80
        if(gmax1(eha_phaseindex)>p) 
        cost=cost+abs(20*log10(gmax1(eha_phaseindex))-20*log10(p));
        end
    else
            if(gmin2(eha_phaseindex)<p) && wspan(i)>=100
            cost=cost+abs(20*log10(gmin2(eha_phaseindex))-20*log10(p));
            else 
                cost=cost-0.02*abs(20*log10(gmin2(eha_phaseindex))-20*log10(p)); %control effort reduction
            end
    end

end

%margin test
[gainM,gainPhase] = margin(Pnom*Gtf);
if(max(step(Gtf*Pnom/(Gtf*Pnom+1)))>1.05)
    cost = cost+max(step(Gtf*Pnom/(Gtf*Pnom+1)))-1.05;
end
if(gainM<gmargin) 
    cost=cost+gmargin-gainM;
end
if(gainPhase<pmargin)
    cost=cost+pmargin-gainPhase;
end

% if(length(cost)>1)
%     cost=cost(1);
% end
