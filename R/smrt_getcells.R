
#' Get cells (collections) information for a particular PacBio run
#'
#' The SMRTLink API endpoint used is `SMRTLink/1.0.0/smrt-link/runs/{runID}/collections`.
#' The access token can be obtained with `smrt_gettoken()`, runID can be obtained with `smrt_getruns()`.
#'
#' @param baseurl URL of the SMRTLink installation, e.g. https://servername:8243
#' @param user Username
#' @param pass Password
#'
#' @import httr2
#' @importFrom purrr map_chr
#' @importFrom purrr map_int
#'
#' @return A tibble with run information
#' @export
#'
#'
smrt_getcells <- function(baseurl, token, runid) {

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

  tibble::tibble(
    run_uniqueId = map_chr(json, 'runId', .default = NA),
    cell_uniqueId = map_chr(json, 'uniqueId', .default = NA),
    cell_name = map_chr(json, 'name', .default = NA),
    well = map_chr(json, 'well', .default = NA),
    status = map_chr(json, 'status', .default = NA),
    started_at = lubridate::as_datetime(map_chr(json, 'startedAt', .default = NA)),
    completed_at = lubridate::as_datetime(map_chr(json, 'completedAt', .default = NA)),
    created_by = map_chr(json, 'createdBy', .default = NA)
  )
}
