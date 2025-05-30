# smrtlinker
An R package for working with the [Pacific Biosciences](https://www.pacb.com/) SMRTLink API.

## Description
This package is a wrapper for the PacBio SMRTLink API (v12.0). It includes functions for accessing several `SMRTLink` endpoints and aims to provide run/SMRTcell/analysis data in `tidy` format.
The API documentation can be found [here](https://www.pacb.com/wp-content/uploads/SMRT_Link_Web_Services_API_Use_Cases_v12.0.pdf).
 
## Installation
The package is not available on CRAN (and will not be), so install it with `devtools`:
```
devtools::install_github("angelovangel/smrtlinker")
```
## Usage
The `smrtlinker` functions were designed to obtain all the information present at a given API endpoint. The base URL for a SMRTLink installation is something like:  `https://<servername>:8243`.   
A good starting point is to get a table with all the runs:

```
library(smrtlinker)
runs <- smrt_runs(baseurl, user, pass)
```
Use caution when providing user and password information in scripts as this may expose them. An easy solution is to put them in your `.Renviron` and access them with `Sys.getenv()`.

With a Run ID, it is now easy to obtain cells (collections) information:

```
# get a token first, valid usually for 30 minutes
token <- smrt_token(baseurl, user, pass) %>% .$access_token

# get cells info for a given run
smrt_collections(baseurl, token, runid)

# or get cells for all runs
library(purrr)

map(runs$uniqueId, smrt_collections, baseurl = baseurl, token = token) %>%
  list_rbind()

```

It is also possible to obtain subreads and CCS information for a given collection:

```
smrt_subreads(baseurl, token, uid)   # uid is the collection UUID
smrt_ccsreads(baseurl, token, ccsid)  # ccsid is present in the `smrt_collections()` output
```

## Disclaimer
The author of this package is not associated with Pacific Biosciences.
