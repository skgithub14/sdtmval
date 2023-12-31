% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read.R
\name{read_sdtm_tbls}
\alias{read_sdtm_tbls}
\title{Import SDTM data tables}
\usage{
read_sdtm_tbls(sdtm_tbls, dir)
}
\arguments{
\item{sdtm_tbls}{character vector of SDTM table file names (without extension)}

\item{dir}{string, the directory containing the production SDTM tables}
}
\value{
a named list of data frames where the names are taken from
\code{sdtm_tbls} and the data frames are the SDTM data
}
\description{
Reads-in SDTM data tables store as .sas7bdat files and puts them in a list.
}
\details{
The file encoding will be UTF-8.
}
\examples{
sdtm_tbls <- "dm"
sdtm_dir <- system.file("extdata", package = "sdtmval")
sdtm_dat <- read_sdtm_tbls(sdtm_tbls, dir = sdtm_dir)

}
\seealso{
\code{\link[=read_edc_tbls]{read_edc_tbls()}}
}
