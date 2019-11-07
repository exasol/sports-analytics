
# Sports Analytics

## Overview

This repository contains examples for sports analytics with Exasol.
Please follow the corresponding blog post for a detailed walk thro

## Prerequisite

* Runnning Exasol instance or Exasol community edition
* Write access to the BucketFS

## Usage

1) You have to publish the provided sports analytics Python scripting-language Docker container
to your Exasol instance. This container provides every Python packages needed for the different examples.

2) Choose your showcase ;)



## Showcases

### Voronoi diagramm for position data

Voronoi diagramms can be used to indentify the space on the pitch controlled by a single player.
The coresponding blog post can be found at the Exasol homepage: https://www.exasol.com/en/blog/controlling-space-in-football/

![Voronoi](/screenshots/Voronoi3.gif)


### Convex hull for position data

In football defending teams want to have a compact shape to defend the dangerous areas in front of the goal. Attacking teams want to play wide, to strech the defence. A convex hull diagram can be used to visualize this team shape. Using the stretch factor as indicator of the compactness helps to measure the time, how a long team needs to get the correct shape during a transition phase. 

![Convex Hull](/screenshots/convex_hull.gif)

