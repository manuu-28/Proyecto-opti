$Title Prueba con los datos del articulo - Ogboi et al. (2025)

* Caso 1: Omega Investments (portafolio de inversion) - capital 10.000.000 naira
* Caso 2: Omega Bank (portafolio de credito) - fondos 100 millones de naira
* Objetivo: verificar si las soluciones que reporta el articulo son optimas.

* =========================== CASO 1 ===========================
Set i /Bonos, REIT, Acciones/;

Table datos(i,*)
          retorno  riesgo  minimo
Bonos       0.06      2     0.20
REIT        0.09      5     0.30
Acciones    0.12      8     0.10;

Scalar K    capital total        /10000000/;
Scalar Rmax riesgo promedio max  /5/;

Positive Variable x(i);
Variable Z1;

Equations objetivo1, presupuesto1, riesgo1;

objetivo1..
 Z1 =e= sum(i, datos(i,'retorno')*x(i));

presupuesto1..
 sum(i, x(i)) =e= K;

riesgo1..
 sum(i, datos(i,'riesgo')*x(i)) =l= Rmax*K;

* Inversion minima de cada activo
x.lo(i) = datos(i,'minimo')*K;

Model caso1 /objetivo1, presupuesto1, riesgo1/;

Solve caso1 using LP maximizing Z1;

Parameter sol_articulo1(i) solucion que reporta el articulo
   /Bonos 2000000, REIT 5000000, Acciones 3000000/;

Parameter comparacion1(*,*);
comparacion1(i,'optimo GAMS') = x.l(i);
comparacion1(i,'articulo')    = sol_articulo1(i);
comparacion1('Retorno','optimo GAMS')      = Z1.l;
comparacion1('Retorno','articulo')         = sum(i, datos(i,'retorno')*sol_articulo1(i));
comparacion1('Riesgo prom.','optimo GAMS') = sum(i, datos(i,'riesgo')*x.l(i))/K;
comparacion1('Riesgo prom.','articulo')    = sum(i, datos(i,'riesgo')*sol_articulo1(i))/K;

Display comparacion1;

* =========================== CASO 2 ===========================
Set j /Personal, Hipotecario, Empresarial/;

Table datos2(j,*)
              retorno  riesgo
Personal        0.15      9
Hipotecario     0.10      3
Empresarial     0.12      6;

Scalar F    fondos disponibles (millones)  /100/;
Scalar R2   riesgo promedio max            /6/;

Positive Variable y(j);
Variable Z2;

Equations objetivo2, fondos2, riesgo2, minHipotecario, maxPersonal;

objetivo2..
 Z2 =e= sum(j, datos2(j,'retorno')*y(j));

fondos2..
 sum(j, y(j)) =l= F;

riesgo2..
 sum(j, datos2(j,'riesgo')*y(j)) =l= R2*sum(j, y(j));

minHipotecario..
 y('Hipotecario') =g= 0.30*sum(j, y(j));

maxPersonal..
 y('Personal') =l= 0.50*sum(j, y(j));

Model caso2 /objetivo2, fondos2, riesgo2, minHipotecario, maxPersonal/;

Solve caso2 using LP maximizing Z2;

Parameter sol_articulo2(j) solucion que reporta el articulo
   /Personal 30, Hipotecario 40, Empresarial 30/;

Parameter comparacion2(*,*);
comparacion2(j,'optimo GAMS') = y.l(j);
comparacion2(j,'articulo')    = sol_articulo2(j);
comparacion2('Retorno','optimo GAMS')      = Z2.l;
comparacion2('Retorno','articulo')         = sum(j, datos2(j,'retorno')*sol_articulo2(j));
comparacion2('Riesgo prom.','optimo GAMS') = sum(j, datos2(j,'riesgo')*y.l(j))/sum(j, y.l(j));
comparacion2('Riesgo prom.','articulo')    = sum(j, datos2(j,'riesgo')*sol_articulo2(j))/sum(j, sol_articulo2(j));

Display comparacion2;
