# Opciones para que el servo RDS3225 (2.35 N·m de bloqueo a 6.5 V) mueva la dirección.
# Ecuaciones de 505 (scrub torque, Jazar) + momento de levantamiento por inclinación del pivote (KPI),
# aproximado como N*d*sin(KPI)*sin(delta)  -> SUPOSICIÓN: fórmula aproximada, verificar con Gillespie/Jazar.
from math import *
g=9.81; m=25; W=m*g; beta=radians(16); mu=0.6; rc=0.025; S=1.3; eta=0.9; J=1.2e-3; dd=10.5; Ts=0.10
L=0.44; Lcm=0.173; LIM=2.35; r=0.100
def Ndn(h): return (W*cos(beta)*Lcm + W*sin(beta)*h)/L/2     # por rueda, bajando 16°
def Nfl(): return W*Lcm/L/2
def T(N,e,d=0.0,kpi=0.0,delta=35):
    tau=2/3*mu*N*rc + mu*N*e + N*d*sin(radians(kpi))*sin(radians(delta))
    return (tau+J*dd)*S/eta+Ts
def emax(N):  # e máximo sin KPI para T <= LIM
    tau=(LIM-Ts)*eta/S - J*dd
    return (tau-2/3*mu*N*rc)/(mu*N)
for h in (0.288,0.339,0.390):
    print('h_cm=%.0f mm: N bajando=%.1f N, e máx (sin KPI) bajando=%.1f mm; plano: %.1f mm'%(h*1e3,Ndn(h),emax(Ndn(h))*1e3,emax(Nfl())*1e3))
h=0.339; N=Ndn(h); Np=Nfl()
ops=[('A actual: pivote vertical, huella 55',0.040,0.040,0),
     ('B vía menor (s=60), mismo pivote',0.040,0.040,0),
     ('C neumático de 30 mm, pivote vertical',0.027,0.027,0),
     ('D KPI 14° (e=15), huella 55',0.015,0.040,14.0),
     ('E KPI 21.8° (e=0), huella 55',0.000,0.040,21.8),
     ('F rin con pivote dentro (e=15), vertical',0.015,0.015,0),
     ('G neumático 30 + KPI 15.1° (e=0)',0.000,0.027,15.1)]
for n,e,d,k in ops:
    dd_=0 if k==0 else d
    t1=T(Np,e,dd_,k); t2=T(N,e,dd_,k)
    print('%-42s e=%4.1f mm  plano %.2f  bajando %.2f N·m  FS=%.2f'%(n,e*1e3,t1,t2,LIM/t2))
# Corrección: b de Ackermann = distancia entre pivotes
for nombre,b in (('pivote 40 mm dentro del plano de rueda (s=100)',0.52),('pivote a 20 mm del bastidor',0.44),('vía de ruedas 600',0.60)):
    R=L/tan(radians(35))+b/2; do=degrees(atan(L/(R+b/2)))
    print('b=%.0f mm (%s): Rmin=%.2f m, delta_o=%.1f°'%(b*1e3,nombre,R,do))
