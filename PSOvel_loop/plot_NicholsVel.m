function [] = plot_NicholsVel(gmin,gmax,EHAphase,w_a,Pnom,Gcont)
am=cell2mat(gmin);
bm=cell2mat(gmax);
cm=cell2mat(EHAphase);
mark=['r' 'b' "#D95319" 'g' 'c' 'k' 'm'];


f0 = figure;
tm = subplot(1,1,1,'Parent',f0);

for count=1:length(w_a)
a=am((count-1)*73+1:(count)*73);

b=bm((count-1)*73+1:(count)*73);

c=cm((count-1)*73+1:(count)*73);
eps=0.1;

a(abs(mode(a)-a)<=eps)=NaN;

%b(abs(mode(b)-b)<=eps)=NaN;

c(c<-360)=NaN;
c(c>-5)=NaN;

h=plot(tm,c,20*log10(b),'Color',mark(mod(count-1,6)+1));
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
XLabel.String = '[derece]';
YLabel.String = '[dB]';


hold on
h=plot(tm,c,20*log10(a),'--','Color',mark(mod(count-1,6)+1));
h.Annotation.LegendInformation.IconDisplayStyle = 'off';

[p,pphase] = mag_phase(Pnom*Gcont,w_a(count)*j);
if pphase>0
    pphase=-360+pphase;
    
end
plot(tm,pphase,20*log10(p),'o','Color',mark(mod(count-1,6)+1),'DisplayName',strcat('w=',num2str(w_a(count)),' rad/s'),LineWidth=3);

xlim([-360 3])
XLabel.String = '[degree]';
YLabel.String = '[dB]';


end
wspan=logspace(-3,3.1,2500);
parray ={};
pparray = {}
for i=1:length(wspan)
    [p,pphase] = mag_phase(Pnom*Gcont,wspan(i)*j);
    parray{i} =p;
    pparray{i} = pphase;
    if pphase>0
    pphase=-360+pphase;
    
end

end
    plot(tm,cell2mat(pparray),20*log10(cell2mat(parray)),'Color','k','LineWidth',2,'DisplayName','L(s)');
    XLabel.String = '[degree]';
    YLabel.String = '[dB]';
    
grid on
tm.XLabel.String = 'Phase (degree)';
tm.YLabel.String = 'Magnitude (dB)';

%nichols(Pnom);
xlim([-360 3])
hold off
end