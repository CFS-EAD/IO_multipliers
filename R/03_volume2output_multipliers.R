iotab <- data.frame()

for(m in 1:nrow(ptab)) {
  
  message(paste0('Prov/Terr = ', ptab$province[m]))

  ################################
  ## 5-year mean harvest volume  
  harVol <- mean(hartab$harvested[hartab$ISO == ptab$pt[m]])

  ###################
  ## Output
  otab <- bind_cols(ptab[m,c(2:3)],
                    type = 'Direct',
                    category = 'Output',
                    constrained = NA,
                    filter(output, GEO == ptab$province[m]) %>%
                      group_by(Industry) %>%
                      summarize(conversion.factor = (mean(VALUE) * 1e6) / harVol))
  
  otab <- rbind(otab, 
                cbind(otab[1,c(1:5)], Industry = 'Total Forest Sector', 
                      conversion.factor = sum(otab$conversion.factor)))
              
  ##############
  ## GDP
  gdptab <- bind_cols(ptab[m,c(2:3)],
                      type = 'Direct',
                      category = 'GDP',
                      constrained = NA,
                      filter(gdp, GEO == ptab$province[m]) %>%
                        group_by(Industry) %>%
                        summarize(conversion.factor = (mean(VALUE) * 1e6) / harVol))
    
  gdptab <- rbind(gdptab, 
                cbind(gdptab[1,c(1:5)], Industry = 'Total Forest Sector', 
                      conversion.factor = sum(gdptab$conversion.factor)))
  
  #############
  ## Jobs
  jtab <- bind_cols(ptab[m,c(2:3)],
                    type = 'Direct',
                    category = 'Jobs',
                    constrained = NA,
                    filter(jobs, GEO == ptab$province[m]) %>%
                      group_by(Industry) %>%
                      summarize(conversion.factor = (mean(VALUE)) / harVol))
  
  jtab <- rbind(jtab, 
                cbind(jtab[1,c(1:5)], Industry = 'Total Forest Sector', 
                      conversion.factor = sum(jtab$conversion.factor)))
  
  iotab <- rbind(iotab, rbind(otab, gdptab, jtab))
  
}


################################
## compute and append indirect, induced (constrained and unconstrained)

for(m in 1:nrow(ptab)) {
  
  message(paste0('Prov/Terr = ', ptab$province[m]))
  
  ## 5-year mean harvest volume  
  harVol <- mean(hartab$harvested[hartab$ISO == ptab$pt[m]])

  ## Output
  otab <- filter(output, GEO == ptab$province[m]) %>%
    group_by(Industry) %>% 
    mutate(VALUE = VALUE * 1e6) %>%
    select(REF_DATE,Industry,IOIC,VALUE)
  
  iotab <- rbind(iotab, do.call(rbind, lapply(unique(otab$IOIC), function(ind) {
    
    multitab <- io[io$province == prov & 
                     io$IOIC == ind &
                     io$type == 'Output', ] %>%
      select(Indirect.Multiplier:Induced.Multiplier)
    
    x <- cbind.data.frame(province = ptab$province[m],
                          pt = ptab$pt[m],
                          type = c('Indirect', 'Induced')[c(1,1,2,2)],
                          category = 'Output',
                          constrained = c(TRUE,FALSE)[c(1,2,1,2)],
                          Industry = otab$Industry[match(ind, otab$IOIC)],
                          conversion.factor = 
                            unlist(Reduce('+', lapply(unique(otab$REF_DATE), function(yr) {
                              unname(unlist(otab[otab$IOIC == ind & otab$REF_DATE == yr, 'VALUE'][1,1])) * multitab
                            })) / length(unique(otab$REF_DATE)) / harVol)) %>%
      tibble::remove_rownames()
    
    ## GDP
    gdptab <- filter(gdp, GEO == ptab$province[m]) %>%
      group_by(Industry) %>% 
      mutate(VALUE = VALUE * 1e6) %>%
      select(REF_DATE,Industry,IOIC,VALUE)
    
    y <- cbind.data.frame(province = ptab$province[m],
                          pt = ptab$pt[m],
                          type = c('Indirect', 'Induced')[c(1,1,2,2)],
                          category = 'GDP',
                          constrained = c(TRUE,FALSE)[c(1,2,1,2)],
                          Industry = gdp$Industry[match(ind, gdptab$IOIC)],
                          conversion.factor = 
                            unlist(Reduce('+', lapply(unique(gdp$REF_DATE), function(yr) {
                              unname(unlist(gdptab[gdptab$IOIC == ind & gdptab$REF_DATE == yr, 'VALUE'][1,1])) * multitab
                            })) / length(unique(gdptab$REF_DATE)) / harVol)) %>%
      tibble::remove_rownames()
    
    ## Jobs
    jtab <- filter(jobs, GEO == ptab$province[m]) %>%
      mutate(VALUE = VALUE * 1e6) %>%
      select(REF_DATE,Industry,IOIC,VALUE) %>%
      mutate(IOIC = paste0(IOIC, sapply(8 - nchar(IOIC), function(t) str_c(rep('0', t), collapse = ''))))
    
    z <- cbind.data.frame(province = ptab$province[m],
                          pt = ptab$pt[m],
                          type = c('Indirect', 'Induced')[c(1,1,2,2)],
                          category = 'Jobs',
                          constrained = c(TRUE,FALSE)[c(1,2,1,2)],
                          Industry = jobs$Industry[match(ind, jtab$IOIC)],
                          conversion.factor = 
                            unlist(Reduce('+', lapply(unique(jtab$REF_DATE), function(yr) {
                              unname(unlist(jtab[jtab$IOIC == ind & jtab$REF_DATE == yr, 'VALUE'])) * multitab
                            })) / length(unique(jtab$REF_DATE)) / harVol)) %>%
      tibble::remove_rownames()
    
    bind_rows(x, y, z)
    
  })))
  
}

## Add conversion factor for Total Forest Sector (induced, indirect)
## = sum of subsector conversion factors
iotab <- bind_rows(iotab, 
                   filter(iotab, type != 'Direct') %>%
                     group_by(province, pt, type, category, constrained) %>%
                     summarize(conversion.factor = sum(conversion.factor)) %>%
                     mutate(Industry = 'Total Forest Sector', .before = conversion.factor)) %>%
  arrange(province, type, constrained)

## Write to file
write.csv(iotab, file = 'output/IO_conversion_factors_2021.csv')

## report m3 * Direct, indirect + induced Total Forest Sector conversion factors
