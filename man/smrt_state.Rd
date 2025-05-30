% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/smrt_state.R
\name{smrt_state}
\alias{smrt_state}
\title{Get instruments state information from a PacBio SMRTLink server v12.0}
\usage{
smrt_state(baseurl, token)
}
\arguments{
\item{baseurl}{URL of the SMRTLink installation, e.g. https://servername:8243}

\item{token}{token}
}
\value{
A tibble with instrument state information
}
\description{
Get instruments state information from a PacBio SMRTLink server v12.0
}
