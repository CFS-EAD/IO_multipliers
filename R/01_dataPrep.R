source('R/00_global.R')

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

## 3) Import sums of volumes harvested on provincial lands by province by year
download.file(url="http://nfdp.ccfm.org/download/data/csv/NFD%20-%20Net%20Merchantable%20Volume%20of%20Roundwood%20Harvested%20by%20Category%20and%20Ownership%20-%20EN%20FR.csv",
              destfile="extdata/NFD - Net Merchantable Volume of Roundwood Harvested by Category and Ownership - EN FR.csv")

hartab <- read.delim('extdata/NFD - Net Merchantable Volume of Roundwood Harvested by Category and Ownership - EN FR.csv',
                     sep=',', fileEncoding='latin1') %>%
  select(c('Year','ISO','Jurisdiction','Category','Species.group','Tenure..En.','Volume..cubic.metres...En.','Data.qualifier')) %>%
  rename(Volume = Volume..cubic.metres...En.,
         Tenure = Tenure..En.) %>%
  filter((Year >= max(Year)-4 & Year <= max(Year))) %>% 
  group_by(ISO, Year) %>%
  summarize(harvested = sum(Volume, na.rm=T)) %>%
  ungroup()
             
## 4) StatCan Output Table (2016-2020)
download.file(url = 'https://www150.statcan.gc.ca/n1/tbl/csv/36100488-eng.zip',
              destfile = 'extdata/36100488-eng.zip')
unzip('extdata/36100488-eng.zip', exdir = 'extdata')

output <- read.csv('extdata/36100488.csv') %>%
  filter(REF_DATE %in% 2016:2020) %>%
  mutate(IOIC = str_sub(Industry, 
                        start = str_locate(Industry, '\\[')[,1] + 1,
                        end = -2L)) %>%
  filter(IOIC %in% c('BS113000','BS115300','BS321100','BS321200',
                     'BS321900','BS322100','BS322200'))

## 5) StatCan GDP Table (2016-2020)
download.file(url = 'https://www150.statcan.gc.ca/n1/tbl/csv/36100487-eng.zip',
              destfile = 'extdata/36100487-eng.zip')
unzip('extdata/36100487-eng.zip', exdir = 'extdata')

gdp <- read.csv('extdata/36100487.csv') %>%
  filter(REF_DATE %in% 2016:2020) %>%
  mutate(IOIC = str_sub(Industry, 
                        start = str_locate(Industry, '\\[')[,1] + 1,
                        end = -2L)) %>%
  filter(IOIC %in% c('BS113000','BS115300','BS321100','BS321200',
                     'BS321900','BS322100','BS322200'))

## 6) StatCan Jobs Table (2016-2020)
download.file(url = 'https://www150.statcan.gc.ca/n1/tbl/csv/36100480-eng.zip',
              destfile = 'extdata/36100480-eng.zip')
unzip('extdata/36100480-eng.zip', exdir = 'extdata')

jobs <- read.csv('extdata/36100480.csv') %>%
  filter(REF_DATE %in% 2016:2020 &
         Labour.productivity.and.related.measures == 'Total number of jobs') %>%
  mutate(IOIC = str_sub(Industry, 
                        start = str_locate(Industry, '\\[')[,1] + 1,
                        end = -2L)) %>%
  filter(IOIC %in% c('BS113','BS1153','BS3211','BS3212',
                     'BS3219','BS3221','BS3222'))
