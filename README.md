# Geodesy and Applications - Geoid Modeling and Geodetic Network Adjustment  
**Institution**: Faculdade de Ciências da Universidade de Lisboa  
**Course**: Geodesy and Applications  
**Project Date**: 2021  
**Project Language**: Portuguese

## Project Overview
This project focused on applying advanced geodetic methods for coordinate transformation, network adjustment, and geoid determination. The work was divided into three parts, each addressing a specific area of geodesy:
- **Part 1:** Coordinate transformation between Datum73 and ETRS89 using the Helmert transformation method.
- **Part 2:** Adjustment of geodetic networks, including both classical and monitoring networks.
- **Part 3:** Determination of the geoid undulation in Southern Portugal using gravimetric modeling.

### Table of Contents
- [Skills and Tools Used](#skills-and-tools-used)
- [Project Parts](#project-parts)
  - [Part 1: Coordinate Transformation](#part-1-coordinate-transformation)
  - [Part 2: Geodetic Network Adjustment](#part-2-geodetic-network-adjustment)
  - [Part 3: Geoid Determination](#part-3-geoid-determination)
- [Key Results](#key-results)
- [Project Structure](#project-structure)

## Skills and Tools Used
- **Software**: Excel, Surfer, FORTRAN
- **Techniques**: Helmert coordinate transformation, free and constrained network adjustment, gravimetric geoid modeling
- **Applications**: Geodetic coordinate transformation, geodetic network adjustment, geoid undulation calculation

---

## Project Parts

### Part 1: Coordinate Transformation
In this part, we performed a **Helmert transformation** between Datum73 and ETRS89 using coordinates provided by the **Instituto Geográfico Português**. The transformation was computed using Fortran programs, and two transformation solutions were compared:
- Global solution using all available vertices.
- Local solution using a subset of 10 geodetic vertices.

Additionally, we analyzed the transformation precision and compared the results with official transformation parameters provided by the IGP.

---

### Part 2: Geodetic Network Adjustment
In the second part, we adjusted a **geodetic network** using both free and constrained adjustments. This included:
- **Hayford-Gauss Datum 73**: Classic network adjustment using observed lengths, azimuths, and directions.
- **Jardim Botânico Monitoring Network**: Adjustment of a monitoring network using data collected with a **LEICA TCA2003** total station. Several configurations were tested to validate the statistical precision of the network.

The accuracy of the network adjustment was evaluated through error ellipses, absolute and relative errors, and statistical tests such as the Fisher test.

---

### Part 3: Geoid Determination
The final part focused on the **gravimetric determination of geoid undulations** in Southern Portugal using Stokes' integral. The process included:
- Calculation of free-air, reduced, and residual anomalies.
- Creation of a gravimetric geoid model.
- Adjustment of the geoid model to the leveling benchmarks using Fortran programs.

We used gravity data, geopotential model anomalies, and residual terrain models to perform the calculations, and the results were evaluated against known geoid undulations.

---

## Key Results

- **Part 1**: The Helmert transformation yielded high precision in both global and local solutions, with minor deviations compared to the official transformation parameters.
  
- **Part 2**: The adjustment of the geodetic network revealed that the relative error ellipses were independent of the fixed points, while absolute error ellipses were highly dependent on the configuration used.

- **Part 3**: The gravimetric geoid model showed significant accuracy, and adjustments to leveling benchmarks further improved the fit of the model to the actual geoid undulations in Southern Portugal.

---

## Project Structure

The project is organized into the following folders:

- **Part1/**: Contains the data and files used for Part 1 (coordinate transformation).
- **Part2/**: Contains the data and files used for Part 2 (geodetic network adjustment).
- **Part3/**: Contains the data and files used for Part 3 (geoid determination).
- **report.pdf**: Full report detailing the methodology and results.
- **residuals.xlsx**: Analysis of the results.

---

This project demonstrates the application of fundamental geodetic techniques in solving real-world problems such as coordinate transformation, network adjustment, and geoid determination.

---
