# nicar-22-eviction


## Here are the resources for the Eviction Lab's presentation at the 2022 IRE-NICAR conference 

#### Steps: 

1. Download evictions data from [here](https://evictionlab.org/eviction-tracking/get-the-data/). Data dictionary for these data are available [here](https://eviction-lab-data-downloads.s3.amazonaws.com/ets/data_dictionary_weekly_monthly.xlsx).
2. Download "eviction hotspots" [here](https://eviction-lab-data-downloads.s3.amazonaws.com/ets/hotspots_reports.zip)
       *More research about the role of "top eviction hotspots" [here](https://evictionlab.org/top-evicting-landlords-drive-us-eviction-crisis/)
       *Data are avaiable for select cities and updated quarterly - next update in March.
                                albuquerque  
                                bridgeport   
                                cincinnati   
                                cleveland    
                                columbus     
                                dallas   
                                gainesville  
                                greenville  
                                houston      
                                indianapolis 
                                jacksonville 
                                kansascity   
                                memphis      
                                minneapolis  
                                philadelphia 
                                phoenix      
                                southbend    
                                stlouis      
                                tampa     
          *  position = ranking among "top evictors"
          *  time period - there are 2 start dates in the file - one ranking for start of pandemic - present, another for the the 8-week period before the most recent quarterly update in December. 
          *  xplaintiff = name of the plaintiff in the eviction filing
          *  xstreet_clean = cleaned address 
          *  filings = number of filings 
          *  top100 = proportion of eviction filings made up by the top 100 highest evicting addresses
3. Open up workshop.R
