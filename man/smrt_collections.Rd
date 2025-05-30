% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/smrt_collections.R
\name{smrt_collections}
\alias{smrt_collections}
\title{Get collections information for a particular PacBio run}
\usage{
smrt_collections(baseurl, token, runid)
}
\arguments{
\item{baseurl}{URL of the SMRTLink installation, e.g. https://servername:8243}

\item{token}{A token obtained with \code{smrt_token()}}

\item{runid}{Run UUID}
}
\value{
A tibble with collections for a given run
}
\description{
The SMRTLink API endpoint used is \verb{SMRTLink/1.0.0/smrt-link/runs/\{runID\}/collections}.
The access token can be obtained with \code{smrt_token()}, runID can be obtained with \code{smrt_runs()}.
}
