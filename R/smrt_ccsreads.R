
#' Get CCS data from a particular report
#'
#' The SMRTLink API endpoint used is `/smrt-link/datasets/{datasetType}/{datasetUUID}/reports`
#' Dataset types can be obtained a GET request at `/smrt-link/dataset-types`, the most relevant are
#' `subreads`, `ccsreads` and `transcripts`.
#' The access token can be obtained with `smrt_token()`
#'
#'
#' @param baseurl URL of the SMRTLink installation, e.g. https://servername:8243
#' @param token A token obtained with `smrt_token()`
#' @param ccsid ccs dataset UUID
#'
#' @import httr2
#' @importFrom stringr str_which
#'
#' @return A tibble with report information
#' @export
#'
#'
smrt_ccsreads <- function(baseurl, token, ccsid) {

  resp_list <-
    request(baseurl) %>%
    req_url_path_append(paste0('SMRTLink/1.0.0/smrt-link/datasets/ccsreads', '/', ccsid, '/reports')) %>%
    req_user_agent('smrtlinker (https://github.com/angelovangel/smrtlinker)') %>%
    req_options(ssl_verifypeer = 0) %>%
    req_headers(
      Authorization = paste0('Bearer ', token)
    ) %>%
    req_perform() %>%
    resp_body_json()

  #get the report file uid to download
  ccs_file_index <- purrr::map_chr(resp_list, 'reportTypeId') %>% str_which('report_ccs2')
  ccs_uuid <- resp_list[[ccs_file_index]]$dataStoreFile$uuid



  reportfile <-
    request(baseurl) %>%
    req_url_path_append(paste0('SMRTLink/1.0.0/smrt-link/datastore-files/', ccs_uuid, '/download')) %>%
    req_user_agent('smrtlinker (https://github.com/angelovangel/smrtlinker)') %>%
    req_options(ssl_verifypeer = 0) %>%
    req_headers(
      Authorization = paste0('Bearer ', token)
    ) %>%
    req_perform()

  json <- resp_body_string(reportfile) %>% jsonlite::fromJSON()
  purrr::set_names(rbind.data.frame(json$attributes$value), json$attributes$id) %>%
    tibble::as_tibble() %>%
    dplyr::select(-c('ccs2.median_accuracy')) %>%
    dplyr::mutate_all(as.numeric) %>%
    dplyr::mutate(datasetuid = datasetuid, ccs_uuid = ccs_uuid)
}
