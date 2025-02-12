[Classic ASP](https://learn.microsoft.com/en-us/previous-versions/iis/6.0-sdk/ms524929(v=vs.90)) project I authored circa 2005.

I had prior experience with PHP+MySQL+Apache web stack, so using ASP+Access+IIS did not represent a steep learning curve for me.
The goal of this site was to enable a social network of users "buddies" that allowed you to track their locations.
The main use case was to enable serendipitous ocurrences of buddies that are normally distant in the globe to meet up if they happened to be in close proximity.

The advent of social networks such as facebook or myspace made this site obsolete and it was retired, still this was a great learning oportunity for me, and I feel proud of my hard work on this site.
I worked singlehandedly on all aspects of this site, from coding the ASP files, registering and managing the domain name, designing and optimizing the DB schema in SQL (I used MS Access), building a Java Applet for visualization (see my [MapPlotter](https://github.com/LuisMSuarez/MapPlotter) repository), authoring all image and Adobe Flash assets, etc.

I was particularly pleased with:

    - Modularity of the code using ~50 separate ASP files that could be combined together (header, footer, db query, etc...)
    - Localization enabled, providing resource files in Spanish, English and French, which I translated myself.    
    - De-normalized database to allow efficient queries.
    - My own secure login logic using salted+hashed passwords.
    - Separation of styling using CSS.
    - Usage of minification to further speed up load times.
    - Usage of NASA satellite images.
    - Usage of GIS database (https://www.usgs.gov/) with names and GPS coordinates of cities around the world.
    - Domain registration and webmaster responsabilities of a live site.

Given the obsolete nature of the ASP stack, I don't expect the code to be of much use to the community, I mostly published it for my own records, but feel free to browse!
