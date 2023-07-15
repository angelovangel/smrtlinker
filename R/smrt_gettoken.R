
#' Obtain access token from a PacBio SMRTLink server v12.0
#'
#'The API endpoint used is `SMRTLink/1.0.0/token`
#'
#' @param baseurl URL of the SMRTLink installation, e.g. https://servername:8243
#' @param user Username
#' @param pass Password
#'
#' @import httr2
#'
#' @return A list, the access token is under `access_token`
#' @export
#'

smrt_gettoken <- function(baseurl, user, pass) {
  request(baseurl) %>%
    req_url_path_append('token') %>%
    req_user_agent('smrtlinker (https://github.com/angelovangel/smrtlinker)') %>%
    req_body_form(
      grant_type = 'password',
      username = user,
      password = pass,
      scope = c('analysis run-qc data-management')
    ) %>%
    req_options(ssl_verifypeer = 0) %>%
    req_perform() %>%
    resp_body_json()
}
