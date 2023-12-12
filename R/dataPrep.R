source('R:/00_global.R')

## 1) create local data directory 
dir.create(inputPath)

## 2) download StatCan summary tables from GCDocs (via SilvaCloud)
## GCDocs URL: https://gcdocs.gc.ca/nrcan-rncan/llisapi.dll?func=ll&objId=87876987&objAction=browse&viewType=1#
x <- drive_ls(as_id('10vQ9OmX20xkvtBVQL1E_hUVuOhdZb5Fp')) %>%
  dplyr::filter(str_detect(name, '.xlsx'))

for(m in 1:nrow(x)) {
  drive_download(as_id(x$id[m]),
                 path = file.path(inputPath, x$name[m]))
}

## 3) import and compile summary 
fnames <- list.files(inputPath, full.names = T)

io <- do.call(rbind, lapply(fnames, function(f) {
  data.frame(fname = f,
             output = read.xlsx(f, rows = 20:21, cols = 11)[1,1],
             gdp = read.xlsx(f, rows = 40:41, cols = 11)[1,1],
             jobs = read.xlsx(f, rows = 60:61, cols = 11)[1,1])
}))
