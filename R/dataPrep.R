source('R:/00_global.R')

## 1) create local data directory 
dir.create('data')

## 2) download StatCan summary tables from GCDocs (via SilvaCloud)
## GCDocs URL: https://gcdocs.gc.ca/nrcan-rncan/llisapi.dll?func=ll&objId=87876987&objAction=browse&viewType=1#
x <- drive_ls(as_id('10vQ9OmX20xkvtBVQL1E_hUVuOhdZb5Fp')) %>%
  dplyr::filter(str_detect(name, '.xlsx'))

for(m in 1:nrow(x)) {
  drive_download(as_id(x$id[m]),
                 path = paste0('data/', x$name[m]))
}


