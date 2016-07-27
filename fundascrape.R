##################
#
# Scraping funda


library(rvest)
library(RCurl)
library("httr")
library(stringr)
library("textcat")


i=1
startloc = "http://www.funda.nl/koop/heel-nederland/p"

out = data.frame()


for(i in 1:12700){
  
  # Haal lijst op van huizen in startloc
  print(i)
  httploc = paste(startloc, i, sep="")
  print(httploc)
  
  hoofd       = read_html(httploc)
  
  # pak de straat 
  adres       = html_nodes(hoofd, ".search-result-title") %>% html_text() %>% str_replace_all("\n","") %>% str_trim()
  postcode    = str_extract(adres, "[0-9]{4}\\s[A-Z]{2}")
  
  #sinds       = html_nodes( hoofd, xpath = "//span[@class='search-result-info-small']")  %>% html_text() 
  
  tmpprijs   = html_nodes( hoofd, xpath = "//span[@class='search-result-price']")  %>% html_text() %>% str_replace_all("\\.","")
  prijsselect = !tmpprijs %>% str_detect("mnd") 
  prijs       = tmpprijs [prijsselect]  %>% str_extract("[0-9]+") %>% as.numeric()
  KK          = tmpprijs [prijsselect]  %>% str_detect("k")
  
  oppervlakte = html_nodes( hoofd, xpath = "//span[@title='Woonoppervlakte']")  %>% html_text() %>% str_replace_all("\\.","") %>% str_replace_all("m²","") %>% as.numeric()
  perceeloppervlakte = html_nodes( hoofd, xpath = "//span[@title='Perceeloppervlakte']")  %>% html_text() %>% str_replace_all("\\.","") %>% str_replace_all("m²","") %>% as.numeric()
  
  makelaar    = html_nodes( hoofd, xpath = "//span[@class='search-result-makelaar-name']")  %>% html_text() 
  
  info = html_nodes( hoofd, xpath = "//span[@class='search-result-info']") %>% html_text()
  info2 = info[str_detect(info,"kamer")]
  if (length(info2) == 0 ){
    info3 = rep(NA,15)
  }else{
    info3 = str_match(info2, "([0-9]+) kamers")[,2] %>% as.numeric
  }
  if(length(info3) == 15 && length(KK)==15 && length(makelaar) == 15)
  {
    out = rbind(out, data.frame(scrapedate = Sys.Date(), adres, postcode, prijs, oppervlakte, perceeloppervlakte, KK, makelaar, kamers=info3))
  }
  
  if (i%%100 == 0){
    saveRDS(out,paste0("/home/longhowlam/RProjects/Funda_New/FundaOut.Rds"))
    saveRDS(i,"i.Rds")
    write.csv(i,file=paste0("/home/longhowlam/RProjects/Funda_New/iter",Sys.Date(),".csv"),row.names = FALSE)
    
  }
  Sys.sleep(10)
}


write.csv(out,file=paste0("/home/longhowlam/RProjects/Funda_New/Funda",Sys.Date(),".csv"),row.names = FALSE)
saveRDS(out, paste0("/home/longhowlam/RProjects/Funda_New/Funda",Sys.Date(),".Rds"))

#out=readRDS("FundaOut.Rds")

