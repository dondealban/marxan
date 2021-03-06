% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generics.R, R/MarxanUnsolved.R, R/MarxanSolved.R
\name{solve}
\alias{solve}
\alias{solve.MarxanSolved}
\alias{solve.MarxanUnsolved}
\title{Solve Marxan object}
\usage{
\method{solve}{MarxanUnsolved}(x, wd = tempdir(), seeds = sample.int(n =
  10000L, size = x@opts@NCORES), clean = TRUE, verbose = TRUE)

\method{solve}{MarxanSolved}(x, wd = tempdir(), seeds = sample.int(n =
  10000L, size = x@opts@NCORES), clean = TRUE, force_reset = FALSE)
}
\arguments{
\item{x}{"MarxanUnsolved" or "MarxanSolved" object.}

\item{wd}{"character" file path to a working directory, this is a temporary directory by default to avoid pollution.}

\item{seeds}{"integer" vector of seeds to initialise Marxan 's random number generator.}

\item{clean}{"logical" delete files once processing completed?}

\item{verbose}{"logical" should messages be printed during optimisation?}

\item{force_reset}{"logical" should Marxan solutions be recalculated even if "MarxanSolved" object supplied?}
}
\value{
"MarxanSolved" object
}
\description{
This function executes Marxan using the input parameter and data stored in a "MarxanUsolved" object, 
and returns a "MarxanSolved" object with outputs in it.
}
\note{
This function is used to solve a MarxanUnsolved object that has all of its inputs generated. The marxan function (without lower case 'm') provides a more general interface for generating inputs and outputs for Marxan.
}

