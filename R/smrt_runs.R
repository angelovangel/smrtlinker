
#' Get run information from a PacBio SMRTLink server v12.0
#'
#' The API endpoint used is `SMRTLink/1.0.0/smrt-link/runs`. This function uses `smrt_token()` internally to obtain
#' an access token, meaning that a new token is obtained with each invocation.
#'
#' @param baseurl URL of the SMRTLink installation, e.g. https://servername:8243
#' @param token token
#'
#' @import httr2
#' @importFrom purrr map_chr
#' @importFrom purrr map_int
#'
#' @return A tibble with run information
#' @export
#'
#'
smrt_runs <- function(baseurl, token) {

  #token <- smrt_token(baseurl, user, pass) %>% .$access_token

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

  purrr::map_df(json, dplyr::bind_rows) %>%
    dplyr::mutate(
      completedAt = lubridate::as_datetime(completedAt),
      createdAt = lubridate::as_datetime(createdAt),
      startedAt = lubridate::as_datetime(startedAt),
      transfersCompletedAt = lubridate::as_datetime(transfersCompletedAt)
    )

}
