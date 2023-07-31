
#' Get instruments state information from a PacBio SMRTLink server v12.0
#'
#' @param baseurl URL of the SMRTLink installation, e.g. https://servername:8243
#' @param token token
#'
#' @import httr2
#' @importFrom purrr map_chr
#' @importFrom purrr map_int
#'
#' @return A tibble with instrument state information
#' @export
#'

smrt_state <- function(baseurl, token) {
  resp <-
    request(baseurl) %>%
    req_url_path_append('SMRTLink/1.0.0/smrt-link/instruments') %>%
    req_user_agent('smrtlinker (https://github.com/angelovangel/smrtlinker)') %>%
    req_options(ssl_verifypeer = 0) %>%
    req_headers(
      Authorization = paste0('Bearer ', token)
    ) %>%
    req_perform()

  mylist <- resp_body_json(resp)
  state <- purrr::map(mylist, 'state')
  runData <- purrr::map(state, 'runData')

  tibble::tibble(
    serial = map_chr(mylist, 'serial'),
    instrumentName = map_chr(state, 'instrumentName'),
    status = map_chr(state, 'state'),
    numcells = map_int(1:length(runData), function(x) runData[[x]]$collections %>% length()),
    cells_status = map_chr(
      1:length(runData), function(x) map_chr(runData[[x]]$collections, 'state') %>%
        stringr::str_flatten(collapse = " | ", na.rm = T)
      ),
    updatedAt = map_chr(mylist, 'updatedAt') %>% lubridate::as_datetime(tz = Sys.timezone()),
    timestamp = map_chr(runData, 'timestamp') %>% lubridate::as_datetime(tz = Sys.timezone()),
    startedAt = map_chr(runData, 'startedAt') %>% lubridate::as_datetime(tz = Sys.timezone()),
    secondsRemaining = map_int(runData, 'estimatedSecondsRemaining'),
    completedAt = map_chr(runData, 'completedAt') %>% lubridate::as_datetime(tz = Sys.timezone()),
    projectedEnd = dplyr::if_else(status == 'Running', timestamp + secondsRemaining, NA)
    )
}
