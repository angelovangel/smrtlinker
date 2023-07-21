# a helper to get subread data associated with a cell (collection), based on instrument type
# For Sequel 2  (64068), subread dataset UID == collection UID
# For Sequel 2e (64468e), subread dataset UID == ccs UID


get_subreadsdata <- function(uniqueId, ccsId, instrument_name, ...) {
  if (instrument_name == '64468e') {
    smrt_subreads(baseurl = baseurl, token = token, uid = ccsId)
  } else {
    smrt_subreads(baseurl = baseurl, token = token, uid = uniqueId)
  }
}

# use in pmap
# pmap(cells_df, get_subreadsdata, baseurl = baseurl, token = token)

get_all_datasets <- function(baseurl, token, type = 'subreads') {
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
    # this is robust and doesn't throw errors of some of the cols are missing
    dplyr::mutate_at(
      dplyr::vars(dplyr::any_of(
        c('createdAt', 'importedAt', 'updatedAt')
      )), lubridate::as_datetime
    )
  }

  prep_dump <- function(baseurl, user, pass) {

    token <- smrt_token(baseurl, user = user, pass = pass) %>% .$access_token

    runs <- smrt_runs(baseurl = baseurl, token = token) %>%
       dplyr::select(
         run_name = name,
         run_context = context,
         run_startedAt = startedAt,
         run_completedAt = completedAt,
         run_status = status,
         instrumentType = instrumentType,
         numCellsCompleted = numCellsCompleted,
         totalCells = totalCells,
         createdBy = createdBy,
         run_uniqueId = uniqueId
         )
    cols <- purrr::map(runs$run_uniqueId, smrt_collections, baseurl = baseurl, token = token) %>%
      purrr::list_rbind() %>%
      dplyr::select(
        coll_name = name,
        coll_context = context,
        coll_startedAt = startedAt,
        coll_completedAt = completedAt,
        coll_status = status,
        runId = runId,
        ccsId = ccsId,
        coll_uniqueId = uniqueId
      )

    df1 <- dplyr::left_join(runs, cols, by = c('run_uniqueId' = 'runId')) %>%
      # use this to make one call to smrt_subreads and join later
      dplyr::mutate(join_key = dplyr::if_else(instrumentType == 'Sequel2e', ccsId, coll_uniqueId))

    # get subreads --> for Sequel2 call smrt_subreads(coll_uid), for Sequel2e call smrt_subreads(ccs_uid)
    subrds  <- purrr::map(df1 %>%
                          dplyr::filter(coll_status == 'Complete') %>%
                          .$join_key, purrr::possibly(smrt_subreads), baseurl = baseurl, token = token
                        ) %>% purrr::list_rbind()

    # all machines use ccs_uid
    ccsrds <- purrr::map(df1 %>%
                    dplyr::filter(coll_status == 'Complete') %>%
                    .$ccsId, purrr::possibly(smrt_ccsreads), baseurl = baseurl, token = token
                  ) %>% purrr::list_rbind()

    # join all
    df1 %>%
      dplyr::left_join(subrds, by = c('join_key' = 'call_uid')) %>%
      dplyr::left_join(ccsrds, by = c('ccsId' = 'call_uid'))


    # sbrds <- get_all_datasets(baseurl, token, type = 'subreads') %>%
    #   dplyr::select(sbrds_metadataContextId = metadataContextId,
    #                 sbrds_totalLength = totalLength,
    #                 sbrds_numRecords = numRecords,
    #                 sbrds_parentUuid = parentUuid) %>%
    #   # filter out demuxed datasets
    #   dplyr::filter(is.na(sbrds_parentUuid))
    #
    # ccsrds <- get_all_datasets(baseurl, token, type = 'ccsreads') %>%
    #   dplyr::select(ccs_metadataContextId = metadataContextId,
    #                 ccs_totalLength = totalLength,
    #                 ccs_numRecords = numRecords,
    #                 ccs_parentUuid = parentUuid) %>%
    #   # filter out demuxed datasets
    #   dplyr::filter(is.na(ccs_parentUuid))


  }

