# nicar-22-eviction
## Here are the resources for the Eviction Lab's presentation at the 2022 IRE-NICAR conference 

#### Helpful packages: 

*  data acquisition
    * [court-reporter](https://github.com/biglocalnews/court-scraper) from Big Local News 
*  record linking packages 
    * [fastLink](https://github.com/kosukeimai/fastLink)
    * [BRL](https://search.r-project.org/CRAN/refmans/BRL/html/BRL.html)
* race imputation
    * [wru](https://github.com/kosukeimai/wru) 
* gender imputation
    * [genderizer](https://github.com/kalimu/genderizeR)
    * [gender](https://github.com/lmullen/gender)
    * [genderdata](https://github.com/lmullen/genderdata)

#### Steps: 
1. Clone [this Github repo](https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository)
2. Download evictions data at the city and state level [here](https://evictionlab.org/eviction-tracking/get-the-data/). Data dictionary for these data are available [here](https://eviction-lab-data-downloads.s3.amazonaws.com/ets/data_dictionary_weekly_monthly.xlsx). Download them into the same directory you clone the Git repo to. 
3. Download "eviction hotspots" [here](https://eviction-lab-data-downloads.s3.amazonaws.com/ets/hotspots_reports.zip).
4. Open up workshop.R

#### More information:          
* More research about the role of "top eviction hotspots" [here](https://evictionlab.org/top-evicting-landlords-drive-us-eviction-crisis/)
* Data are avaiable for select cities and updated quarterly - next update in March.
  * Albuquerque
  * Bridgeport   
  * Cincinnati   
  * Cleveland    
  * Columbus     
  * Dallas   
  * Gainesville  
  * Greenville  
  * Houston      
  * Indianapolis 
  * Jacksonville 
  * Kansas City   
  * Memphis      
  * Minneapolis  
  * Philadelphia 
  * Phoenix      
  * Southbend    
  * St.louis      
  * Tampa 

* Data dictionary:     
  *  position = ranking among "top evictors"
  *  time period - there are 2 start dates in the file - one ranking for start of pandemic - present, another for the the 8-week period before the most recent quarterly update in December. 
  *  xplaintiff = name of the plaintiff in the eviction filing
  *  xstreet_clean = cleaned address 
  *  filings = number of filings 
  *  top100 = proportion of eviction filings made up by the top 100 highest evicting addresses
