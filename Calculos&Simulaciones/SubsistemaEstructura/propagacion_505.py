# Propagación de la geometría del bastidor (504) a los parámetros de 505. Solo cálculo; no escribe en los .tex.
from math import *
g=9.81; m=25.0; beta=radians(16); a=0.30; mu=0.60; fr=0.05; S=1.30; eta_s=0.90; rc=0.025
Jm=1.2e-3; dd=10.5; Tss=0.10
def calc(b,L,Lcm,h,e):
    d_i=radians(35.0)
    R=L/tan(d_i)+b/2
    d_o=atan(L/(R+b/2)); d=atan(L/R)
    vuelco=degrees(atan((b/2)/h))
    W=m*g
    Nf_up=(W*cos(beta)*Lcm - W*sin(beta)*h - m*a*h)/L
    Nr_up=W*cos(beta)-Nf_up
    Nf_dn=(W*cos(beta)*Lcm + W*sin(beta)*h)/L
    Nf_fl=W*Lcm/L
    ftr=m*a+W*sin(beta)+fr*W*cos(beta)
    tau=lambda N: 2/3*mu*N*rc+mu*N*e
    out=dict(R=R,d_o=degrees(d_o),d=degrees(d),vuelco=vuelco,Nf_up=Nf_up,Nr_up=Nr_up,Nf_dn=Nf_dn,
        Nw_dn=Nf_dn/2,adh=mu*Nr_up,ftr=ftr,tau_fl=tau(Nf_fl/2),tau_dn=tau(Nf_dn/2))
    out['Ts_fl']=(out['tau_fl']+Jm*dd)*S/eta_s+Tss
    out['Ts_dn']=(out['tau_dn']+Jm*dd)*S/eta_s+Tss
    out['wr']=b/(2*R)
    return out
old=calc(0.380,0.450,0.225,0.180,0.015)
print('ANTES',{k:round(v,3) for k,v in old.items()})
# z del CG: sin elevación (marcos de referencia: suelo)
h0=59.0
comp=[('bastidor',3.40,130),('placas',0.32,130),('Cubo S potencia',1.5,107.5),('Cubo S control',1.5,107.5),('batería',2.16,63),('motores',1.6,41),('servos',0.12,41)]
mc=sum(x[1] for x in comp); zc=sum(x[1]*(x[2]+h0) for x in comp)/mc
print('sin elevación: m=%.2f kg, z=%.0f mm sobre el suelo'%(mc,zc))
res=[]
for H in (100,200,300):    # SUPOSICIÓN: altura del CG de la elevación sobre la cara superior del bastidor (z=260)
    z=(mc*zc+10.874*(260+h0+H))/(mc+10.874)
    r=calc(0.600,0.440,0.173,z/1000,0.040)
    res.append((H,z,r))
    print('H_el=%d -> h_cm=%.0f mm'%(H,z),{k:round(v,3) for k,v in r.items()})
