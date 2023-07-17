# a helper to get subread data associated with a cell (collection), based on instrument type
# For Sequel 2  (64068), subread dataset UID == collection UID
# For Sequel 2e (64468e), subread dataset UID == ccs UID


get_subreadsdata <- function(cell_id, ccs_id, instrument_name, ...) {
  if (instrument_name == '64468e') {
    smrt_subreads(baseurl = baseurl, token = token, uid = ccs_id)
  } else {
    smrt_subreads(baseurl = baseurl, token = token, uid = cell_id)
  }
}

# use in pmap
# pmap(cells_df, get_subreadsdata, baseurl = baseurl, token = token)

