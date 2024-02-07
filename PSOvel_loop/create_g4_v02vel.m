function [g_array,g_array2] = create_g4_v02vel(w_m,P,Ws,ad_rad)
phi_a=-360: 5: 0;
w_a = merge_frequency_points(w_m);
lengthP=length(P);
N=length(phi_a)*length(w_a)*lengthP;


g_array=(zeros(N,2));  
g_array2=(zeros(N,2));  

for i=1:length(w_a)
[p1,p1angle]= mag_phase(P{1},w_a(i)*j);
[p2,p2angle]= mag_phase(P{lengthP-1},w_a(i)*j);
w_freq=w_a(i);
    for a=1:length(phi_a)
        disp([i,a]);
        phi=phi_a(a);
        for jcount=1:lengthP
            %disp([i,a,jcount]);
           
            [p,pphase] = mag_phase(P{jcount},w_a(i)*j);
            %%% 1 
            %type1
            
            a1=p^2*(1-1/(Ws^2));
            b1=2*p*cos((phi_a(a)+pphase)/180*pi);
            c1=1;
            if ismember(w_freq, w_m{1}) && abs(mod(phi_a(a)+pphase,-360)+180)<52
            g_array((i-1)*(73)*lengthP+(a-1)*lengthP +jcount,1)=double(  (  (-b1)-sqrt(b1^2-4*a1*c1)  )  /(2*a1)  );
            g_array((i-1)*(73)*lengthP+(a-1)*lengthP +jcount,2)=double(  (  (-b1)+sqrt(b1^2-4*a1*c1)  )  /(2*a1)  );
            else
            g_array((i-1)*(73)*lengthP+(a-1)*lengthP +jcount,1)=NaN;
            g_array((i-1)*(73)*lengthP+(a-1)*lengthP +jcount,2)=NaN;
            end
            %%% 2
            %type3
            
            T3=tf([1/ad_rad 0],[1/ad_rad,1]);
            [t3,t3phase]=mag_phase(T3,w_freq*j);
            %eqn2=p^2*g^2+2*p*cos((phi+pphase)/180*pi)*g+(1-1/t3^2)==0;
            a1=p^2;
            b1=2*p*cos((phi+pphase)/180*pi);
            c1=(1-1/t3^2);
            
            if ismember(w_freq, w_m{2})
            g_array2((i-1)*(73)*lengthP+(a-1)*lengthP +jcount,1)=double(  (  (-b1)-sqrt(b1^2-4*a1*c1)  )  /(2*a1)  );
            g_array2((i-1)*(73)*lengthP+(a-1)*lengthP +jcount,2)=NaN; %no below line
            else
            g_array2((i-1)*(73)*lengthP+(a-1)*lengthP +jcount,1)=NaN;
            g_array2((i-1)*(73)*lengthP+(a-1)*lengthP +jcount,2)=NaN;
            end
            %disp(double(  (  (-b1)-sqrt(b1^2-4*a1*c1)  )  /(2*a1)  )*p);
            
            
            %}
            

        end
    end
end

end