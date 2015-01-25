marxan classes
============

## Overview
This package relies on five main classes. These are the `MarxanOpts`, `MarxanData`, `MarxanUnsolved`, `MarxanResults`, and `MarxanSolved` classes (Figure 1). Each class encapsulates a different aspect of the Marxan work-flow. To make the most of this package, users will need to be familiar with each of these classes. Briefly, the `MarxanOpts` class stores the Marxan input parameters. The `MarxanData` class stores Marxan input data relating to the planning units and the species. The `MarxanUnsolved` class combines `MarxanOpts` and `MarxanData` objects to represent an unsolved Marxan problem. The `MarxanResults` class stores the outputs from Marxan. The `MarxanSolved` class combines `MarxanOpts`, `MarxanData`, and `MarxanResults` class to represent the inputs and outputs from Marxan. All of these classes are associated with help files, for example `help('MarxanOpts-class')`. 

![The relationship between the five main Marxan classes. The `MarxanOpts` and `MarxanData` classes are used to construct a `MarxanUnsolved` object. The `MarxanUnsolved` class is then processed by the Marxan program to generate outputs for the `MarxanResults` class. The `MarxanOpts`, `MarxanData`, and `MarxanResults` classes are used to construct the `MarxanSolved` class. Open circles denote classes, filled in circles denote programs, and arrows indicate dependencies.](doc/images/figure1.png)

The example data used in this tutorial is a simplified version of the data used in the "Introduction to Marxan" course. It can be loaded in R by running the code below:

```r
data(taspu, tasinvis)
```

## MarxanOpts
The `MarxanOpts` class represents the input parameters for Marxan (Figure 2). `MarxanOpts` objects are used to generate 'input.dat' files for Marxan. This class has slots that correspond to the names of input parameters in the 'input.dat' file, and an additional `NCORES` slot that refers to the number of processes to use for parallel processing. To ensure that Marxan outputs are compatible with other functions in this package, the user is unable to set parameters that affect which files are output by Marxan.

New `MarxanOpts` objects can be created in R by specifying desired input parameters, or by reading them from an existing 'input.dat' file.

```r
# create new MarxanOpts object, with default parameters except BLM and NUMITNS
# note that NUMITNS is an integer and must be set using numbers with an L after them
opts1<-MarxanOpts(BLM=100, NUMITNS=10L)

# write to disk to a temporary directory
write.MarxanOpts(opts1, tempdir())

# show the resulting input.dat file
cat(paste(readLines(), collapse="\n"),"\n")

# create new Marxanopts object by loading parameters from the input.dat
opts2<-read.MarxanOpts()
```

Once created, the parameters stored in a `MarxanOpts` object can be viewed.

```r
# show all parameters and their values
str(opts1)
str(opts2)

# show BLM parameter with @ operator
# the @ operator is conceptually similar to the $ operator,
# but used for S4 classes and not S3 classes.
opts1@BLM

# show PROP parameter with slot function
slot(opts1, 'PROP')
```

The parameters stored in an existing `MarxanOpts` object can be changed.

```r
# change BLM parameter with @ operator and show it
opts1@BLM<-100
opts1@BLM

# change HEURTYPE parameter with slot operator
slot(opts1, 'HEURTYPE')<-5L
opts1@HEURTYPE

# copy parameters in opts1 to opts3, 
# but change NCORES parameter to 2L
opts3<-update(opts1, ~opt(NCORES=2L))
opts1@NCORES
opts3@NCORES
```

## MarxanData
The `MarxanData` class stores the input planning unit and species data for Marxan scenarios (Figure 3). All slots of this class are `data.frame` objects that correspond to a specific Marxan input data file. The `species` slot corresponds to 'spec.dat', the `pu` slot corresponds to 'pu.dat', the `puvspecies` slot corresponds to 'puvspr2.dat', the `puvspecies_spo` slot corresponds to 'puvspr2.dat' sorted by species id (an undocumented feature in Marxan used to speed up pre-processing), and the `boundary` slot corresponds to 'bound.dat'.

New `MarxanData` objects can be created in R by supplying pre-processed data, supplying raw data for processing, or by reading Marxan input data from files.

```r
## create MarxanData object from pre-processed data
# make pre-processed data
pu.dat<-taspu@data
spec.dat<-data.frame(id=unique(getValues(tasinvis)),spf=1,target=100)
puvspr.dat<-calcPuVsSpeciesData(taspu, tasinvis)
bound.dat<-calcBoundaryData(taspu)
polyset<-SpatialPolygons2PolySet(taspu)
# make MarxanData object
mdata1<-MarxanData(pu=pu.dat, species=spec.dat, puvspecies=puvspr.dat, boundary=bound.dat, polygons=polyset)

## create MarxanData object from raw data
# format.MarxanData is basically a wrapper for code shown above
mdata2<-format.MarxanData(taspu, tasinvis, targets=100, spf=1)

## create MarxanData object from data marxan files
# write mdata1 to temporary folder
write.MarxanData(mdata1, tempdir())
# create new MarxanData object
mdata3<-read.MarxanData(tempdir())
```

Data in existing `MarxanData` objects can be viewed and changed using several functions and operators. While only functions to get and set species penalty factors and targets are shown below, functions exist to get and set all fields in the 'pu.dat' and 'spec.dat' tables. Generally, users are encouraged to use the `update` function. Be aware, that the set functions, eg. `targets(...)<-value` and `spfs(...)<-value` shown below, are extremely inefficient and should only be used for small problems.

```r
# show first 20 rows of species data
head(mdata1@species)
head(slot(mdata1, 'species'))

# show species targets
mdata1@species$target
slot(mdata1, 'species')$target
targets(mdata1)

# change species spfs to 5
mdata1@species$spf<-5L
slot(mdata1, 'species')$spf=5L
spfs(mdata1)<-5L

#  copy data in mdata1 to mdata2
#  and change the target for species 1 to 10
mdata2<-update(mdata1, ~spp(1, target=10))
```

## MarxanUnsolved 
The `MarxanUnsolved` class stores the input parameters and data for Marxan (Figure 4). It has two slots, an `opts` slot containing a `MarxanOpts` object and a `data` slot containing a `MarxanData` object.

New `MarxanUnsolved` objects can be created using `MarxanOpts` and `MarxanData` objects, reading Marxan input data from file, or using the `marxan` function with argument `solve=FALSE`.

```r
## create new MarxanUnsolved object using existing objects
mu1<-MarxanUnsolved(mopts1, mdata1)

## create new MarxanUnsolved object by reading data from file
# write data to file
write.MarxanUnsolved(mu1, tempdir())

# read data from file and store in new object
input.dat.path<-file.path(tempdir(), 'input.dat')
mu2<-read.MarxanUnsolved(input.dat.path)

# create new MarxanUnsvoled object by processing raw data
mu3<-marxan(taspus, tasinvis, targets='50%', solve=FALSE)
```

Similar to the `MarxanOpts` and `MarxanData` classes, the update function can be used to change the Marxan input data and parameters for `MarxanUnsolved` objects.

```r
# take mu3, copy its data,
# then change the HEURTYPE parameter to 4,
# change the CLUMPTYPE parameter to 1,
# change the target for species 1 to 2,
# change the cost for planning unit 4 to 10,
# and store data in mu4
mu4<-update(mu3, ~opt(HEURTYPE=4, CLUMPTYPE=1) + spp(1, target=2) + pu(4, cost=10))
```

## MarxanResults
The `MarxanResults` class stores all the outputs from Marxan (Figure 5). The `summary` slot contains the 'output_sum.csv', the `selections` slot contains the 'output_solutionsmatrix.csv', the `log` slot contains the `output_log.dat`, and the `best` slot contains index of the best solution. The `amountheld`, `occheld`, `mpm`, `sepacheived`, and `targetsmet` slots contain data from the fields in all the `output_mv*.dat` files merged into a `matrix`. Each row in these matrices refers to different solution; each column refers to a different species.

New `MarxanResults` objects can created by reading Marxan outputs from disk. The code below is provided only for instructive purposes, users should generally use the `solve` and `marxan` functions.

```r
# save MarxanUnsolved object to temporary directory
write.MarxanUnsolved(mu1, tempdir())

# copy marxan executable to temporary directory
findMarxanExecutablePath()
file.copy(options()$marxanExecutablePath, file.path(tempdir(), basename(options()$marxanExecutablePath)))

# run marxan
system(paste0('"',file.path(tempdir(), basename(options()$marxanExecutablePath)),'" "',file.path(tempdir(), 'input.dat'),'"'))

# create MarxanResults object by reading results from disk
mr1<-read.MarxanResults(tempdir())
```

Data stored in a `MarxanResults` object can be accessed using the `@` operator, the slot function, and using various get methods. The code below used to access the solutions selections in the `selection` slot can also be used to access solution data in the `occheld`, `accountheld`, `mpm`, `sepacheived`, and `targetsheld` by using the corresponding slot name.


```r
# show summary data
mr1@summary
slot(mr1, 'summary')
summary(mr1)

# show best solution index
mr1@best
slot(mr1, 'best')

# show debug information
mr1@debug
slot(mr1, 'debug')
debug(mr1)

# access selections in all solutions
mr1@selections
slot(mr1, 'selections')
selections(mr1)

# access selections for best solution
mr1@selections[mr1@best,]
slot(mr1, 'selections')[mr1@best,]
selections(mr1, 0)

# access selections for third solution
mr1@selections[3,]
slot(mr1, 'selections')[3,]
selections(mr1, 3)
```

## MarxanSolved
The `MarxanSolved` class stores Marxan input parameters, data, and outputs. It has a `opts` slot that contains a `MarxanOpts` object, a `data` slot that contains a `MarxanData` object, and a `results` slot that contains a `MarxanResults` object.

New `MarxanSolved` objects can be created by solving a `MarxanUnsolved` and `MarxanSolved` objects, or by updating existing `MarxanUnsolved` and  `MarxanSolved` objects.


```r
# solved MarxanUnsolved object
ms1<-solve(mu1)

# resolve a MarxanSolved object
ms2<-solve(ms1, force_reset=TRUE)

# update MarxanUnsolved object
ms3<-update(mu1, ~opt(HEURTYPE=2L) + spp(1, spf=5) + pu(4, cost=100))

# update MarxanSolved object
ms4<-update(ms3, ~opt(HEURTYPE=2L) + spp(1, spf=5) + pu(4, cost=100))
```

The data stored in the `MarxanSolved` object can be accessed using methods describe for the `MarxanOpts`, `MarxanData`, and `MarxanUnsolved` classes.

<!--
%\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{marxan R package classes}
-->
