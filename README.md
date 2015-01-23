marxan
============

#### This R package contains decision support tools for reserve selection using Marxan. It brings the entire Marxan workflow to R. Key features include the ability to prepare input data for Marxan, execute Marxan, and visualise Marxan solutions.

##### Installation

To install the marxan R package, execute the following commands in R:

```
if (!require('devtools'))
	install.packages('devtools', repo='http://cran.rstudio.com', dep=TRUE)
devtools:::install_github('paleo13/marxan')
```

##### Quick start guide

First, let's load the 'marxan' R package and some example data.

```
# load marxan R package
library(marxan)

# load example data
data(taspu, tasinvis)
```

This data comes from the ['Introduction to Marxan'](http://marxan.net/courses.html). `taspu` is a `SpatialPolygonsDataFrame` object that contains our planning units, and `tasinvis` is a `RasterLayer` that contains distribution data for 63 broad vegetation classes. Let's take a look at the data.

``` 
# plot planning units
plot(taspu)

# plot vegetation data
plot(tasinvis)
```

Each planning unit in the `taspu` object is associated with an id, an acquisition cost, and a value indicating if the most of the unit is already locked up in protected areas. This information is stored in the `data` slot.

```
# print data in the attribute table for first 20 planning units
head(taspu@data)

# plot planning units with colours indicating cost
spplot(taspu, 'cost')

# plot planning units with colors indicating status
# units with a status of 2 have most of their area in IUCN protected areas,
# otherwise they have a status of 0
spplot(taspu, 'status')
```

To keep things simple, let's make some reserve systems assuming that all planning units have equal cost, that there are no protected areas in Tasmania, and that we don't care about fragmentation in the prioritisation. To do this, we will first need to make a copy of `taspu` and change the `cost` and `status` fields.

```
# copy object
taspu2<-taspu

# change cost field
taspu2@data$cost<-1

# change status field
# note that we're putting using 0L to indicate
# this value is an integer
taspu2@data$status<-0L

```

Now, let's make some reserve systems.

```
# the NUMREPS=100L parameter tells marxan to generate 100 candidate reserve systems
# the BLM=0 parameter indicates that fragmented prioritisations incur no additional penalties
results<-marxan(taspu, tasinvis, NUMREPS=100L, BLM=0)
```

Well, that was easy. Apparently it worked? All we see is text. How can visualise these solutions and assess their quality? We can make some geoplots.

```
## make a geoplot of the best solution
plot(results, 0)

## make a geoplot of the second solution
# let's also add a kickass google map background
# and make the planning unit colours transparent.
plot(results, 2, basemap='satellite', alpha=0.8)

## make a geoplot of planning unit selection frequencies
# planning units with darker colours were more often
# selected for protection than those with lighter colours.
plot(results, basemap='satellite', alpha=0.8)
```

We have one hundred solutions. How can we compare them? We don't want to make 100 maps; while they are pretty, they're not that pretty. Instead, we could make some dotcharts that let us compare various properties of the solutions.

```
# make dotchart showing the score of each solution
# the score describes the overall value of the prioritisations based on our criteria
# the lower the value, the better the solution
# the best solution is coloured in red.
dotchart(results, var='score')

# make a dotchart showing the connectivity of the solutions
# the connectivity describes how clustered the selected planning units are
# a prioritisation with lots of planning units close together will have a low value
# whereas a fragmented prioritisation will have a high value
# we can specify arguments to limit the plot to the solutions in with the top 20
# connectivity vlaues, and colour the best 5 in red.
dotchart(results, var='con', nbest=5, n=20)
```

How can we visualise the main components of variation in the solutions? In other words, how can we visualise the key differences and commonalities between the solutions? For instance, we would want to know if the all the solutions are very similar, or if they fall into several key groups. If they all fall into several groups, this means we don't have to look at all the solutions. Instead, we can look at some of the best solutions in each group to decide which candidate reserve system is the best. 

But how can we do this? Fortunately, statisticians solved this problem a long time ago. We can use ordination techniques to create a few variables that describe commonalities among the solutions, and visualise the main sources of variation in a manageable number of dimensions.

```
## dendrogram showing differences between solutions based on which planning units 
## were selected (using Bray-Curtis distances by default)
# the solutions are shown at the tips of the tree.
# solutions that occupy nearby places in tree
# have similar sets of planning units selected.
# the best prioritisation is coloured in red.
dendrogram(results, type='dist', var='selections')

## same dendrogram as above but with the best 10 prioritisations coloured in red
# if all the red lines connect together at the bottom of the dendrogram
# this means that all the best prioritisations are really similar to each other,
# but if they connect near the top of the dendrogram then this means that
# some of the best prioritisations have totally different sets of planning units
# selected for protection.
dendrogram(results, type='dist', var='selections', nbest=10)

## ordination plot showing differences between solutions based on the number of units
## occupied by each vegetation class (using MDS with Bray-Curtis distances)
# we can also use multivariate techniques to see how the solutions vary
# based on how well they represent different vegetation classes.
# the numbers indicate solution indices.
# solutions closer to each other in this plot have more
# similar levels of representation for the same species.
# the size of the numbers indicate solution quality,
# the bigger the number, the higher the solution score.
ordiplot(results, type='mds', var='occheld', method='bray')

# ordination plot showing differences between solutions based on the amount held 
# by each vegetation class (using a principle components analysis)
# labels are similar to the previous plot.
# the arrows indicate the variable loadings.
ordiplot(results, type='pca', var='amountheld')
```

Before, to keep things simple we made several horrifying assumtions. We assumed that all areas had equal acquisition costs--we assumed that placing a protected area in Hobart (that's the capital city) would cost the same as placing it in an urbanised of land. We also assumed that Tasmania also has no protected areas--so many of the vegetation classes we want to represent in our reserve network may already be captured by existing areas, and so if implemented, our reserve system might over-represent these classes and under-represent other classes. Let's do it right.

```
# run marxan again, but this time using the original data
results2<-marxan(taspu, tasinvis, NUMREPS=100L, BLM=0)
```

Let's compare the solutions in different runs.

```
## geoplot showing differences between the best solution in 
## results and results2 
plot(results2, results3, i=0, j=0)

## geoplot showing differences between the third solution
## in results and the fifth solution in results2
plot(results2, results3, i=3, j=j)

## geoplot showing different in selection frequencies in the 'results' and 'results2' objects
# blue colours indicate that units were more often selected in
# the scenario where we assumed equal costs and that Tasmania has no protected areas.
# red  colours indicate that untis were more often selected
# in the scenario where we used cost and protected area data
# to get more informed prioritisations.
plot(results, results2)
````

We can see that the solutions when including all the cost and protected area data are fairly fragmented. This could be an issue, because such protected area networks may be associated with poor connectivity and higher maintenance costs. Let's try increasing the boundary length modifier, and generating more solutions. 

```
# use the update function to copy the data in results2,
# tweak the parameters, rerun marxan, and store the 
# new solutions in results3.
results3<-update(results2, ~opt(BLM=100))

# show differences in the best solutions in results2
# and results3 with a google basemap
plot(results2, results3, basemap='hybrid', alpha=0.5)
```

