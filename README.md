# smrtlinker
An R package for working with the [Pacific Biosciences](https://www.pacb.com/) SMRTLink API.

## Description
This package is a wrapper for the PacBio SMRTLink API (v12.0). It includes functions for accessing several `SMRTLink` endpoints and aims to provide run/SMRTcell/analsis data in `tidy` format.
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
smrt_cells(baseurl, token, runid)

# or for all runs
map_df(runs$run_uniqueId, smrt_cells, baseurl = baseurl, token = token)
```

It is also possible to obtain CCS analysis information for a given cell (`datasetuid` is present in the `smrt_cells()` output):
```
smrt_ccs(baseurl, token, datasetuid)
```

## Disclaimer
The author of this package is not associated with Pacific Biosciences.
