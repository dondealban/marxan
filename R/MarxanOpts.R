#' @include RcppExports.R marxan-internal.R misc.R
NULL

#' MarxanOpts: An S4 class to represent Marxan input parameters
#'
#' This class is used to store Marxan input parameters.
#'
#' @slot BLM "numeric" Boundary length modifier. Defaults to 100.
#' @slot PROP "numeric" Proportion of planning units in initial reserve system. Defaults to 0.
#' @slot NUMREPS "integer" Number of replicate runs. Defaults to 100L.
#' @slot NUMITNS "integer" Number of iterations for annealing. Defaults to 1000000L.
#' @slot STARTTEMP "numeric" Initial temperature for annealing. Default to -1.
#' @slot COOLFAC "numeric" Cooling factor for annealing. Defaults to 0.
#' @slot NUMTEMP "integer" Number of temperature decreases for annealing. Defaults to 100000L.
#' @slot COSTTHRESH "numeric" Cost threshold. Defaults to 0.
#' @slot THRESHPEN1 "numeric" Size of cost threshold penalty. Defaults to 0.
#' @slot THRESHPEN2 "numeric" Shape of cost threshold penalty. Defaults to 0.
#' @slot MISSLEVEL "numeric" Amount of target below which it is counted as 'missing'. Defaults to 1.
#' @slot ITIMPTYPE "integer" Iterative improvement type. Defaults to 1L.
#' @slot HEURTYPE "integer" Heuristic type. Defaults to 1L.
#' @slot CLUMPTYPE "integer" Clumping penalty type. Defaults to 0L.
#' @slot VERBOSITY "integer" Amount of output displayed on the program screen. Defaults to 1L.
#' @slot NCORES "integer" Number of cores to use for processing. Defaults to 1L.

#' @note This class was not called "MarxanPars" due to the inevitable conflicts with \code{\link[graphics]{par}}.
#' @export
setClass("MarxanOpts",
	representation(
		BLM="numeric",
		PROP="numeric",
		NUMREPS="integer",

		NUMITNS="integer",
		STARTTEMP="numeric",
		COOLFAC="numeric",
		NUMTEMP="integer",
		
		COSTTHRESH="numeric",
		THRESHPEN1="numeric",
		THRESHPEN2="numeric",

		MISSLEVEL="numeric",
		ITIMPTYPE="integer",
		HEURTYPE="integer",
		CLUMPTYPE="integer",
		VERBOSITY="integer",
		
		NCORES="integer"

	),
	prototype=list(
		BLM=100,
		PROP=0,
		NUMREPS=100L,
	
		NUMITNS=1000000L,
		STARTTEMP=-1,
		COOLFAC=0,
		NUMTEMP=100000L,
			
		COSTTHRESH=0,
		THRESHPEN1=0,
		THRESHPEN2=0,

		MISSLEVEL=1,
		ITIMPTYPE=1L,
		HEURTYPE=1L,
		CLUMPTYPE=0L,
		VERBOSITY=1L,
		NCORES=1L
	),
	validity=function(object) {
		# check for NA or non-finite values
		for (i in c('BLM','PROP','NUMREPS','NUMITNS','STARTTEMP','COOLFAC','NUMTEMP','COSTTHRESH','THRESHPEN1','THRESHPEN2','MISSLEVEL','ITIMPTYPE','HEURTYPE','CLUMPTYPE','VERBOSITY','NCORES'))
			if (!is.finite(slot(object, i)))
				stop('argument to ',i,'is NA or non-finite')
		# check for valid parameters
		if (object@PROP > 1 || object@PROP < 0)
			stop('argument to PROP is not a numeric between 0 and 1')
		if (object@ITIMPTYPE > 3L || object@PROP < 0L)
			stop('argument to ITIMPTYPE is not an integer between 0L and 3L')
		if (object@HEURTYPE > 7L || object@HEURTYPE < 0L)
			stop('argument to HEURTYPE is not an integer between 0L and 7L')
		if (object@VERBOSITY > 3L || object@VERBOSITY < 0L)
			stop('argument to VERBOSITY is not an integer between 0L and 3L')
		return(TRUE)
	}
)

#' Create "MarxanOpts" object
#'
#' This function creates a new "MarxanOpts" object.
#'
#' @param ... arguments to set slots in a "MarxanOpts" object.
#' @param ignore.extra "logical" Should extra arguments be ignored? Defaults to \code{FALSE}.
#' @details
#' The slots of class "MarxanOpts" are shown below for reference.
#' \tabular{cccl}{
#' \strong{Name} \tab \strong{Class} \tab \strong{Default} \tab \strong{Description}\cr
#' BLM \tab "numeric" \tab 1000000L \tab boundary length modifier\cr
#' PROP \tab "numeric" \tab -1 \tab proportion of planning units in initial reserve system\cr
#' NUMREPS \tab "integer" \tab 100L \tab number of replicate runs\cr
#' NUMITNS \tab "integer" \tab 1000000L \tab number of iterations for annealing\cr
#' STARTTEMP \tab "numeric" \tab -1 \tab initial temperature for annealing\cr
#' COOLFAC \tab "numeric" \tab 0 \tab cooling factor for annealing\cr
#' NUMTEMP \tab "integer" \tab 100000L \tab number of temperature decreases for annealing\cr
#' COSTTHRESH \tab "numeric" \tab 0 \tab cost threshold\cr
#' THRESHPEN1 \tab "numeric" \tab 0 \tab size of cost threshold penalty\cr
#' THRESHPEN2 \tab "numeric" \tab 0 \tab shape of cost threshold penalty\cr
#' MISSLEVEL \tab "numeric" \tab 1 \tab amount of target below which it is counted as 'missing'\cr
#' ITIMPTYPE \tab "integer" \tab 1L \tab iterative improvement type\cr
#' HEURTYPE \tab "integer" \tab 0L \tab heuristic type\cr
#' CLUMPTYPE \tab "integer" \tab 0L \tab clumping penalty type\cr
#' VERBOSITY \tab "integer" \tab 1L \tab amount of output displayed on the program screen\cr
#' NCORES \tab "integer" \tab 1L \tab number of cores to use for processing\cr
#' }
#' @return "MarxanOpts" object
#' @seealso \code{\link{MarxanOpts-class}},  \code{\link{read.MarxanOpts}}, \code{\link{write.MarxanOpts}}.
#' @export
#' @examples
#' x<-MarxanOpts(NCORES=4L, NUMREPS=2L, NUMITNS=5L)
MarxanOpts<-function(..., ignore.extra=FALSE) {
	x<-new('MarxanOpts')
	args<-as.list(substitute(list(...)))[c(-1L)]
	extra<-which(!names(args) %in% names(getSlots("MarxanOpts")))
	if (length(extra)>0) {
		if (ignore.extra) {
			args<-args[-extra]
		} else {
			stop("These are not valid or changeable Marxan parameters: ",paste(names(extra), collapse=","))
		}
	}
	for (i in seq_along(args)) {
		slot(x, names(args)[[i]])=args[[i]]
	}
	return(x)
}

#' Read Marxan input parameters from disk
#'
#' This function reads Marxan parameter settings from an input file.
#'
#' @param path "character" directory path for location to save input parameters file.
#' @seealso \code{\link{MarxanOpts-class}},  \code{\link{MarxanOpts}}, \code{\link{write.MarxanOpts}}.
#' @export
#' @examples
#' x<-MarxanOpts()
#' write.MarxanData(x, file.path(tempdir(), 'input.dat'))
#' y<-read.MarxanData(file.path(tempdir(), 'input.dat'))
#' stopifnot(identical(x,y))
read.MarxanOpts<-function(path) {
	x<-new('MarxanOpts')
	marxanOptsFile=readLines(path)
	sl<-getSlots("MarxanOpts")
	for (i in seq_along(sl)) {
		pos<-grep(names(sl)[i],marxanOptsFile)
		if (length(pos)!=0)
			slot(x, names(sl)[i])<-as(strsplit(marxanOptsFile[pos[1]]," ", fixed=TRUE)[[1]][[2]], sl[[i]])
	}
	validObject(x)
	return(x)
}

#' Write Marxan Input Parameters to Disk
#'
#' This function writes Marxan parameter settings to a file.
#'
#' @param x "MarxanOpts" object.
#' @param inputdir "character" directory path for of input data files.
#' @param outputdir "character" directory path for location where Marxan input file and result data files are saved.
#' @param seed "integer" seed for random number generation in Marxan.
#' @seealso \code{\link{MarxanOpts-class}},  \code{\link{MarxanOpts}}, \code{\link{read.MarxanOpts}}.
#' @export
#' @examples
#' x<-MarxanOpts()
#' write.MarxanData(x, file.path(tempdir(), 'input.dat'))
#' y<-read.MarxanData(file.path(tempdir(), 'input.dat'))
#' stopifnot(identical(x,y))
write.MarxanOpts<-function(x,inputdir,outputdir=inputdir,seed=sample.int(n=10000L,size=1L)) {
	cat(
'Input file for Annealing program.

This file generated by the marxan R package.

General Parameters
VERSION 0.1
BLM ',x@BLM,'
PROP ',x@PROP,'
RANDSEED ',seed,'
BESTSCORE -1
NUMREPS ',ceiling(x@NUMREPS/x@NCORES),'

Annealing Parameters
NUMITNS ',x@NUMITNS,'
STARTTEMP ',x@STARTTEMP,'
COOLFAC ',x@COOLFAC,'
NUMTEMP ',x@NUMTEMP,'

Cost Threshold
COSTTHRESH ',x@COSTTHRESH,'
THRESHPEN1 ',x@THRESHPEN1,'
THRESHPEN2 ',x@THRESHPEN2,'

Input File
INPUTDIR ',inputdir,'
SPECNAME spec.dat
PUNAME pu.dat
PUVSPRNAME puvspr.dat
BOUNDNAME bound.dat
MATRIXSPORDERNAME puvspr_sporder.dat

Save Files
SCENNAME output
SAVERUN 3
SAVEBEST 3
SAVESUMMARY 3
SAVESCEN 2
SAVETARGMET 3
SAVESUMSOLN 3
SAVESOLUTIONSMATRIX 3
SAVELOG 1
SAVESNAPSTEPS 0
SAVESNAPCHANGES 0
SAVESNAPFREQUENCY 0
OUTPUTDIR ',outputdir,'

Program control.
RUNMODE 1
MISSLEVEL ',x@MISSLEVEL,'
ITIMPTYPE ',x@ITIMPTYPE,'
HEURTYPE ',x@HEURTYPE,'
CLUMPTYPE ',x@CLUMPTYPE,'
VERBOSITY ',x@VERBOSITY,'

',file=file.path(outputdir, 'input.dat'), sep=""
	)
}

#' @export
print.MarxanOpts<-function(x, header=TRUE) {
	if (header)
		cat("MarxanOpts object.\n")
}

#' @export
setMethod(
	'show',
	'MarxanOpts',
	function(object)
		print.MarxanOpts(object)
)


#' @export
#' @rdname update
update.MarxanOpts<-function(x, formula) {
	ops<-llply(as.list(attr(terms(formula),"variables"))[-1L], eval)
	findInvalidMarxanOperations(ops)
	ops<-ops[which(laply(ops, inherits, "MarxanOptsOperation"))]
	for (i in seq_along(ops)) {
		for (j in seq_along(ops[[i]]$value)) {
			slot(x, ops[[i]]$slot[[j]])<-ops[[i]]$value[[j]]
		}
	}
	validObject(x, test=FALSE)
	return(x)
}

#' Update Marxan input parameters
#'
#' This function is used in the formula argument of the update function to change input parameters of a "MarxanOpts" object.
#'
#' @param ... arguments to update "MarxanOpts" object.
#' @return "MarxanOptsOperation" object.
#' @export
#' @seealso \code{\link{MarxanOpts-class}}, \code{\link{MarxanUnsolved-class}}, \code{\link{MarxanSolved-class}} \code{\link{update}}, \code{\link{spp}}, \code{\link{pu}}
#' @examples
#' opt(BLM=90)
#' opt(PROP=0.7, NUMITNS=100)
opt<-function(...) {
	args<-as.list(substitute(list(...)))[c(-1L)]
	llply(names(args), match.arg, names(getSlots("MarxanOpts")))
	args<-llply(args, eval, envir=parent.frame())
	return(
		structure(
			list(names(args),args),
			.Names = c("slot", "value"),
			class = c("MarxanUpdateOperation", "MarxanOptsOperation")
		)
	)
}

