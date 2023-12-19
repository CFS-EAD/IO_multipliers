## 3) import and compile summary 
ptab <- data.frame(fname = list.files(inputPath, full.names = T)) %>%
  mutate(province = str_sub(fname, start = 6L, end = -14L),
         pt = c('AB','BC','CAN','MB','NB','NL','NW','NS','ON','PE','QC','SK','YT')) %>%
  slice(-3)

io <- do.call(rbind, lapply(1:nrow(ptab), function(m) {
  
  do.call(rbind, lapply(getSheetNames(ptab$fname[m])[-c(2,12)], function(sheetName) {
    
    fout <- read.xlsx(ptab$fname[m], sheet = sheetName, rows = 6:21, cols = c(1,8:11))
    fgdp <- read.xlsx(ptab$fname[m], sheet = sheetName, rows = 26:41, cols = c(1,8:11))
    fjobs <- read.xlsx(ptab$fname[m], sheet = sheetName, rows = 46:61, cols = c(1,8:11))
    
    names(fout)[1] <- 'province'
    names(fgdp)[1] <- 'province'
    names(fjobs)[1] <- 'province'
    
    cbind(fname = ptab$fname[m],
          province = ptab$province[m],
          IOIC = ifelse(!sheetName=='Total Sector',
                        paste0('BS', sheetName, str_c(rep('0', 6 - nchar(sheetName)), collapse = '')),
                        sheetName),
          bind_rows(cbind(constrained = TRUE,
                          type = c('Output','GDP','Jobs'),
                          rbind(fout[fout$province == ptab$province[m], -1],
                                fgdp[fgdp$province == ptab$province[m], -1],
                                fjobs[fjobs$province == ptab$province[m], -1])),
                    
                    cbind(constrained = FALSE,
                          type = c('Output','GDP','Jobs'),
                          rbind(fout[fout$province == 'Canada', -1],
                                fgdp[fgdp$province == 'Canada', -1],
                                fjobs[fjobs$province == 'Canada', -1])))) %>%
      tibble::remove_rownames()
    
  }))
  
}))

if(!file.exists(outputPath)) dir.create(outputPath)
saveRDS(io, file = paste0(outputPath, '/IO_tables_2021.rds'))

