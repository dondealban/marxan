% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generics.R, R/MarxanResults.R, R/MarxanSolved.R
\name{hclust}
\alias{hclust}
\alias{hclust.MarxanResults}
\alias{hclust.MarxanSolved}
\alias{hclust.default}
\title{Hierarchical Clustering for Marxan Solutions}
\usage{
hclust(x, ...)

\method{hclust}{default}(x, ...)

\method{hclust}{MarxanResults}(x, type = "dist", var = "selections", ...,
  force_reset = FALSE)

\method{hclust}{MarxanSolved}(x, type = "mds", var = "selections", ...,
  force_reset = FALSE)
}
\arguments{
\item{x}{"MarxanResults" or "MarxanSolved" object.}

\item{...}{arguments to \code{\link[vegan]{monoMDS}}, or \code{\link[stats]{prcomp}}.}

\item{type}{"character" use metric dimensional scaling ('mds'), or principle components analysis ('pca'), or distance matrix('dist') for analysis?}

\item{var}{"character" should solutions be compared based on selections ('solutions'), or the amount held ('amountheld'), number of occurances ('occheld'), or whether the targets have been met for each species ('targetsmet')?}

\item{force_reset}{"logical" should analysis be run even if it is stored in the cache?}
}
\value{
"hclust" object with an extra element named "phylo" that stores a "phylo" representation for pretty plotting.
}
\description{
This function runs an hierarchical clustering on (using \code{\link[fastcluster]{hclust}}) on Marxan solutions using various characteristics.
Results cached to permit rapid display for plotting functions.
}
\seealso{
\code{\link{MarxanSolved-class}}, \code{\link{marxan}}, \code{\link{ordiplot}}, \code{\link{dendrogram}}
}

