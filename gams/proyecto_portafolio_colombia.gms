$Title Optimizacion de portafolios en Colombia: TES, COLCAP y FIC

* Proyecto de Optimizacion - Universidad del Rosario
* Articulo base: Ogboi, Olurotimi, Olatunde y Blessing (2025), IJEBMR 9(5), 447-463
* Programacion lineal continua: maximiza el retorno esperado de un capital K
* sujeto a presupuesto, riesgo promedio maximo y minimos/maximos por activo y perfil.
*
* FUENTE DE LOS DATOS (F = con fuente, S = supuesto por verificar)
*  TES 2026 y 2034, retorno: [F] rendimiento al vencimiento por nodo, Itau, 31-mar-2025
*  TES 2026 y 2034, volatilidad: [F] curva cero cupon TES en pesos, Banco de la Republica,
*     dato de fin de mes dic-2014 a dic-2025 (132 retornos mensuales). TES 2026 se aproxima con
*     el plazo de 1 ano (sigma 1,45 %) y TES 2034 con el de 10 anos (sigma 14,82 %); retorno
*     mensual de un cero cupon de plazo constante T: (1+y_ant)^T/(1+y)^(T-1/12)-1.
*     Ver hoja TES_mensual de Datos_COLCAP_2015_2025.xlsx
*  COLCAP, retorno y volatilidad: [F] Yahoo Finance, ICOLCAP.CL, Adj Close mensual,
*     ene-2015 a dic-2025 (131 retornos). Retorno = media mensual x 12;
*     volatilidad = desviacion muestral mensual x raiz(12). Ver Datos_COLCAP_2015_2025.xlsx
*  FIC, retorno: [F] ficha tecnica Itau Corto Plazo, Tipo A, rentabilidad E.A. ultimos 3 anos
*     (9,08 %), al 16-nov-2026.
*  FIC, volatilidad: [S] supuesto del grupo (1 %); la ficha consultada no la mostraba.

Set i /TES26, TES34, COLCAP, FIC/;
Set p /Conservador, Moderado, Agresivo/;

* ---------------------- DATOS DE MERCADO ----------------------
Table datos(i,*)
          retorno  volatilidad
TES26      0.0934     0.014500
TES34      0.1227     0.148200
COLCAP     0.083281   0.178365
FIC        0.0908     0.0100;

* ---------------- MEDIDA DE RIESGO COMPARABLE (1 a 10) ----------------
* puntaje = 1 + 9 (vol - vol_min) / (vol_max - vol_min)
Scalar volmin, volmax;
volmin = smin(i, datos(i,'volatilidad'));
volmax = smax(i, datos(i,'volatilidad'));

Parameter riesgo(i) puntaje de riesgo de 1 a 10;
riesgo(i) = 1 + 9*(datos(i,'volatilidad') - volmin)/(volmax - volmin);

* ---------------- POLITICA DE DIVERSIFICACION POR PERFIL ----------------
* Supuestos del grupo (liquidez, concentracion y tolerancia al riesgo); no son limites regulatorios.
Table minimo(i,p)
          Conservador  Moderado  Agresivo
TES26        0.20        0.10      0.00
TES34        0.00        0.00      0.00
COLCAP       0.00        0.00      0.10
FIC          0.20        0.10      0.05;

Table maximo(i,p)
          Conservador  Moderado  Agresivo
TES26        0.50        0.50      0.50
TES34        0.40        0.50      0.50
COLCAP       0.10        0.30      0.50
FIC          0.50        0.50      0.50;

Parameter tope(p) riesgo promedio maximo del perfil
   /Conservador 3, Moderado 5, Agresivo 7/;

Scalar K capital total (millones de COP) /1000/;
Scalar Rmax riesgo promedio maximo vigente;

* ---------------------- MODELO ----------------------
Positive Variable x(i);
Variable Z;

Equations objetivo, presupuesto, limiteRiesgo;

objetivo..
 Z =e= sum(i, datos(i,'retorno')*x(i));

presupuesto..
 sum(i, x(i)) =e= K;

limiteRiesgo..
 sum(i, riesgo(i)*x(i)) =l= Rmax*K;

Model portafolio /objetivo, presupuesto, limiteRiesgo/;

* ---------------------- UN PROBLEMA POR PERFIL ----------------------
Parameter
    reparto(p,i)   participacion optima (fraccion del capital)
    retornoOpt(p)  retorno esperado optimo (fraccion del capital)
    riesgoOpt(p)   riesgo promedio del portafolio
    precioSombra(p) precio sombra de la restriccion de riesgo
    estado(p)      status del modelo (1 = optimo);

loop(p,
   Rmax = tope(p);
   x.lo(i) = minimo(i,p)*K;
   x.up(i) = maximo(i,p)*K;
   Solve portafolio using LP maximizing Z;
   reparto(p,i)    = x.l(i)/K;
   retornoOpt(p)   = Z.l/K;
   riesgoOpt(p)    = sum(i, riesgo(i)*x.l(i))/K;
   precioSombra(p) = limiteRiesgo.m;
   estado(p)       = portafolio.modelstat;
);

* ---------------------- SENSIBILIDAD: tope de riesgo (perfil Moderado) ----------------------
Set s /s1*s6/;
Parameter topes(s) /s1 3, s2 4, s3 5, s4 6, s5 7, s6 8/;
Parameter sensRiesgo(s,*);

loop(s,
   Rmax = topes(s);
   x.lo(i) = minimo(i,'Moderado')*K;
   x.up(i) = maximo(i,'Moderado')*K;
   Solve portafolio using LP maximizing Z;
   sensRiesgo(s,'tope')   = topes(s);
   sensRiesgo(s,'retorno') = Z.l/K;
   loop(i, sensRiesgo(s,i) = x.l(i)/K);
);

* ---------------------- SENSIBILIDAD: retorno esperado del COLCAP (perfil Moderado) ----------------------
Set c /c1*c4/;
Parameter retColcap(c) /c1 0.03, c2 0.06, c3 0.10, c4 0.15/;
Parameter sensColcap(c,*);
Scalar retBase;
retBase = datos('COLCAP','retorno');

loop(c,
   datos('COLCAP','retorno') = retColcap(c);
   Rmax = tope('Moderado');
   x.lo(i) = minimo(i,'Moderado')*K;
   x.up(i) = maximo(i,'Moderado')*K;
   Solve portafolio using LP maximizing Z;
   sensColcap(c,'ret COLCAP') = retColcap(c);
   sensColcap(c,'retorno')    = Z.l/K;
   loop(i, sensColcap(c,i) = x.l(i)/K);
);
datos('COLCAP','retorno') = retBase;

option decimals = 4;
Display riesgo, reparto, retornoOpt, riesgoOpt, precioSombra, estado, sensRiesgo, sensColcap;
