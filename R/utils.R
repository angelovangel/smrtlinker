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

get_all_datasets <- function(type = 'subreads', token) {
  resp <-
    request(baseurl) %>%
    req_url_path_append(paste0('SMRTLink/1.0.0/smrt-link/datasets/', type)) %>%
    req_user_agent('smrtlinker (https://github.com/angelovangel/smrtlinker)') %>%
    req_options(ssl_verifypeer = 0) %>%
    req_headers(
      Authorization = paste0('Bearer ', token)
    ) %>%
    req_perform()

  j <- resp_body_json(resp)

  purrr::map_df(j, dplyr::bind_rows) %>%
    dplyr::mutate(updatedAt = lubridate::as_datetime(updatedAt),
                  createdAt = lubridate::as_datetime(createdAt),
                  importedAt = lubridate::as_datetime(importedAt)
                  )
}

