
#' Get run information from a PacBio SMRTLink server v12.0
#'
#' The API endpoint used is `SMRTLink/1.0.0/smrt-link/runs`. This function uses `smrt_token()` internally to obtain
#' an access token, meaning that a new token is obtained with each invocation.
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
smrt_runs <- function(baseurl, user, pass) {

  token <- smrt_token(baseurl, user, pass) %>% .$access_token

  resp <-
    request(baseurl) %>%
    req_url_path_append('SMRTLink/1.0.0/smrt-link/runs') %>%
    req_user_agent('smrtlinker (https://github.com/angelovangel/smrtlinker)') %>%
    req_options(ssl_verifypeer = 0) %>%
    req_headers(
      Authorization = paste0('Bearer ', token)
    ) %>%
    req_perform()
  json <- resp_body_json(resp)

  tibble::tibble(
    run_uniqueId = map_chr(json, 'uniqueId', .default = NA),
    run_name = map_chr(json, 'name', .default = NA),
    run_summary = map_chr(json, 'summary', .default = NA),
    status = map_chr(json, 'status', .default = NA),
    instrument_name = map_chr(json, 'instrumentName', .default = NA),
    instrument = map_chr(json, 'instrumentType', .default = NA),
    chip = map_chr(json, 'chipType', .default = NA),
    runID = map_chr(json, 'context', .default = NA),
    total_cells = map_int(json, 'totalCells', .default = NA),
    num_cells = map_int(json, 'numCellsCompleted', .default = NA),
    started_at = lubridate::as_datetime(map_chr(json, 'startedAt', .default = NA)),
    completed_at = lubridate::as_datetime(map_chr(json, 'completedAt', .default = NA)),
    created_by = map_chr(json, 'createdBy', .default = NA),
    ccs_mode = map_chr(json, 'ccsExecutionMode', .default = NA)
  )
}
