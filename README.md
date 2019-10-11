# Tinkoff-News
Project idea: Using Core Data (for caching) and API Parsing for comfortable news browsing. 

Features list:
1. User Friendly UI experiense
2. Completed Requirements:
  * Pagination (downloading by 20 objects)
  * View's counter for each post
  * Caching data to Core Data
  
3. Main screen table view added features.
  * Overview. There are title, views counter for each post. 
  Animating sync icon in the nav bar (all data loadings). Autoscroll to the first element of list with the button.
  When post has been read its title color changes to gray.
  <p align="center">
   <img width="200" alt="portfolio_view" src="https://images2.imgbox.com/b1/a4/LBq42Jos_o.png">
  </p>
  
  * Action for each cell. After swapping post to the left it becomes "unread" (its color changes back to white).
  <p align="center">
   <img width="200" alt="portfolio_view" src="https://images2.imgbox.com/31/b3/CbLVbsgQ_o.png">
  </p>
  
  * Refreshing data (manual updating of news) - by swiping down. 
  <p align="center">
   <img width="200" alt="portfolio_view" src="https://images2.imgbox.com/22/ba/s8vF5A2b_o.png">
  </p>
  
4. *Offline* mode implementation + possible situations handling
  * While the first run (cache is empty).
  <p align="center">
   <img width="200" alt="portfolio_view" src="https://images2.imgbox.com/ea/3c/5p4SLOyy_o.png">
  </p>
  
  * When entering to an Offline mode.
  <p align="center">
   <img width="200" alt="portfolio_view" src="https://images2.imgbox.com/8f/6e/sIkEFCXb_o.png">
  </p>
  
  * When trying to get more news (older ones) by scrolling down the list but suddenly lost Internet connection -> moving to an offline mode.
  <p align="center">
   <img width="200" alt="portfolio_view" src="https://images2.imgbox.com/46/26/zZQxtUtE_o.png">
  </p>
  
  App would still continue working properly but to get the full cached content user should reload data manually.
  
  * Watching stored news content with modal view (its the same view as in the situation of the Internet access)
  <p align="center">
   <img width="200" alt="portfolio_view" src="https://images2.imgbox.com/99/87/CDtRPVeT_o.png">
  </p>
  
  * When trying to open news content that wasn't open in online mode (this post wasn't downloaded).
  <p align="center">
   <img width="200" alt="portfolio_view" src="https://images2.imgbox.com/82/a1/dCWbBPQ1_o.png">
  </p> 
  
