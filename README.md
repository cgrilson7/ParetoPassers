Pareto Passers
--------------

### Pareto-efficient performances through NFL history.

The repository contains scripts used to scrape from Pro-Football-Reference.com's play index finder and find the Pareto fronts for various criteria in player game logs, using Patrick Roocks's rPref package: <https://www.p-roocks.de/rpref/>

This project was inspired by an article written by Neil Paine and Andrea Jones-Rooy of FiveThirtyEight, which lays out the concept of Pareto efficiency and applies it to NBA stat lines: <https://fivethirtyeight.com/features/explaining-james-hardens-monster-game-with-a-century-old-economic-theory/>

### What is 'Pareto efficiency'?

The [Wikipedia article](https://en.wikipedia.org/wiki/Pareto_efficiency) explains the concept and its applications well. Pareto efficiency is a way of thinking about possible allocations of resources among individuals or between criteria. In particular, the Pareto efficient outcome, or the 'Pareto frontier', describes the state in which no individual or criterion can be better off or further satisfied, without hurting another individual/criterion.

To prepare you for the charts I'll eventually present, here is a hypothetical example I've put together:

<img src="plots/pareto_frontier_example.png" width="80%" />

The Dual-Threat Frontier
------------------------

``` r
# Load data from input folder
load("input/qb_lines.Rdata")
```
