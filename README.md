# Optimización de portafolios de inversión en Colombia con Programación Lineal


Integrantes: Manuela Vergara, Gabriela Virgüez, Juan Zamudio

## Descripción

Adaptamos el modelo de programación lineal (PL) del artículo de Ogboi, Olurotimi, Olatunde y Blessing (2025) a Colombia. El modelo decide cuánto invertir en cada activo para maximizar el retorno esperado, sujeto a un presupuesto, un riesgo promedio máximo y mínimos y máximos por activo.

- **Artículo base:** Ogboi, Olurotimi, Olatunde & Blessing (2025). *International Journal of Engineering, Business and Management Research*, 9(5), 447–463. https://doi.org/10.51505/IJEBMR.2025.9529
- **Activos:** TES 2026, TES 2034, ETF iShares COLCAP y un fondo de inversión colectiva (FIC) de renta fija.
- **Perfiles:** conservador, moderado y agresivo, con mínimos, máximos y tope de riesgo distintos.

## Modelo

```
max   Σ r_i · x_i
s.a.  Σ x_i = K                       (presupuesto)
      Σ s_i · x_i ≤ R_max · K         (riesgo promedio máximo)
      l_ip · K ≤ x_i ≤ u_ip · K       (mínimos y máximos por perfil)
```

- `x_i`: monto invertido en el activo i
- `r_i`: retorno anual esperado
- `s_i`: puntaje de riesgo de 1 a 10, calculado con la volatilidad anual: `s_i = 1 + 9 (σ_i − σ_min) / (σ_max − σ_min)`
- `K`: capital total (1.000 millones de COP)

Es un modelo de PL continua. Se resuelve con GAMS.

## Estructura del repositorio

```
├── data/
│   ├── raw/          Datos originales sin modificar
│   └── processed/    Datos procesados (Excel con COLCAP, TES y riesgo)
├── gams/
│   ├── prueba_articulo.gms               Réplica de los casos del artículo
│   └── proyecto_portafolio_colombia.gms  Modelo oficial con datos colombianos         
└── documentos/             Informe final (.pdf) y Presentación final (.pptx)
```

## Datos y fuentes

| Dato | Fuente | Periodo |
|---|---|---|
| COLCAP: retorno y volatilidad | Yahoo Finance, ICOLCAP.CL (cierre ajustado, mensual) | ene-2015 a dic-2025 |
| TES: retorno esperado | Itaú, rendimientos al vencimiento por nodo | 31-mar-2025 |
| TES: volatilidad | Banco de la República, curva cero cupón en pesos (1 y 10 años) | dic-2014 a dic-2025 |
| FIC: retorno | Ficha técnica Itaú Corto Plazo, Tipo A, rentabilidad E.A. últimos 3 años | 16-nov-2026 |
| FIC: volatilidad | **Supuesto** (1 %) | n/a |

## Resultados (capital de 1.000 millones de COP)

| Perfil | TES 2026 | TES 2034 | COLCAP | FIC | Retorno esperado | Riesgo promedio |
|---|---|---|---|---|---|---|
| Conservador | 50,0 % | 25,4 % | 0 % | 24,6 % | 10,02 % | 3,00 (tope 3) |
| Moderado | 40,0 % | 50,0 % | 0 % | 10,0 % | 10,78 % | 4,79 (tope 5) |
| Agresivo | 35,0 % | 50,0 % | 10,0 % | 5,0 % | 10,69 % | 5,68 (tope 7) |


## Referencias

- Ogboi, Olurotimi, Olatunde & Blessing (2025). IJEBMR, 9(5), 447–463.
- Yahoo Finance. iShares MSCI COLCAP ETF (ICOLCAP.CL).
- Banco de la República. Tasa de interés cero cupón, TES en pesos.
- Itaú. Informe mensual de renta fija local (abril de 2025) y ficha técnica del fondo Itaú Corto Plazo.
