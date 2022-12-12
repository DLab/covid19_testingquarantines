# COVID-19 SUPPRESSION USING A TESTING/QUARANTINE STRATEGY: A multi-paradigm simulation approach based on a SEIRTQ compartmental model
This repository contains the mutliparadigm simulations that produced the results presented in this paper published in the proceedings of the Winter Simulation Conference 2022.

## Ordinary Differential Equations (ODE)
The ODE simulations where performed using the [cv19gm library](https://github.com/DLab/covid19geomodeller)

## Agent Based Models
The agents based simulations where performed using the [Net-Logo library](https://ccl.northwestern.edu/netlogo/), version 6.1.1.


## Paper Abstract
During the current COVID-19 pandemic, non-pharmaceutical interventions represent the first-line of defense to tackle the dispersion of the disease. One of the main non-pharmaceutical interventions is testing, which consists on the application of clinical tests aiming to detect and quarantine infected people. Here, we extended the SEIR compartmental model into a SEIRTQ model, adding new states representing the testing (**T**) and quarantine (**Q**) dynamics. In doing so, we have characterized the effects of a set of testing and quarantine strategies using a multi-paradigm approach, based on ordinary differential equations and agent based modelling. Our simulations suggest that iterative testing over 10% of the population could effectively suppress the spread of COVID-19 when testing results are delivered within 1 day. Under these conditions, a reduction of at least 95% of the infected individuals can be achieved, along with a drastic reduction in the number of super-spreaders.
