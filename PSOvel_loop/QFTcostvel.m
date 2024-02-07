function[cost] = QFTcostvel(Ws,Gtf,Pnom,EHAphase,wspan,gmincell,gmaxcell) 
cost=0;


for i=1:length(wspan)
    gmax = gmaxcell{i};
    gmin = gmincell{i};
    [p,pphase] = mag_phase(Pnom*Gtf,wspan(i)*j);
    if pphase>0
    pphase=-360+pphase;
    end   
    c=EHAphase{i};
    
    eha_phaseindex =  min(find(min(abs(c-pphase)) == abs(c-pphase)));
    %disp(pphase)
    if(pphase+180<0) 
        cost = cost + abs(pphase+180);
    end

    if ~isnan(gmax(eha_phaseindex))
    Gdiff=abs(20*log10(gmax(eha_phaseindex))-20*log10(p));
    if(gmax(eha_phaseindex)>p) 
    cost=cost+Gdiff;
    else
        if wspan(i)>=100 
            
            cost = cost+max(0,Gdiff-2);   %control effort reduction
        end

        if wspan(i) <=1 
            cost = cost - Gdiff*0.01;
        end
    end
    %disp(cost)
    end


end
[mag,phase,wout] = bode(Pnom*Gtf/(1+Pnom*Gtf));
Wsmax=20*log10(max(mag));
if Wsmax>Ws
    cost= cost+abs(Wsmax-Ws)*10;
    %disp(Wsmax)
end
%disp(cost)


% if(length(cost)>1)
%     cost=cost(1);
% end
end