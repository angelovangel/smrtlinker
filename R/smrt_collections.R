#' Get collections information for a particular PacBio run
#'
#' The SMRTLink API endpoint used is `SMRTLink/1.0.0/smrt-link/runs/{runID}/collections`.
#' The access token can be obtained with `smrt_token()`, runID can be obtained with `smrt_runs()`.
#'
#' @param baseurl URL of the SMRTLink installation, e.g. https://servername:8243
#' @param token A token obtained with `smrt_token()`
#' @param runid Run UUID
#'
#' @import httr2
#'
#' @return A tibble with collections for a given run
#' @export
#'
#'
smrt_collections <- function(baseurl, token, runid) {

  resp <-
    request(baseurl) %>%
    req_url_path_append(paste0('SMRTLink/1.0.0/smrt-link/runs/', runid, '/collections')) %>%
    req_user_agent('smrtlinker (https://github.com/angelovangel/smrtlinker)') %>%
    req_options(ssl_verifypeer = 0) %>%
    req_headers(
      Authorization = paste0('Bearer ', token)
    ) %>%
    req_perform()
  json <- resp_body_json(resp)

  purrr::map_df(json, dplyr::bind_rows) %>%
    dplyr::mutate(
      completedAt = lubridate::as_datetime(startedAt),
      importedAt = lubridate::as_datetime(importedAt),
      startedAt = lubridate::as_datetime(startedAt)
    )
}
