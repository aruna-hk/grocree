                     GROCREE

Distributed online grocery Stores where buyers and delivery personnel are
placed relative to stores to ensure tailored listings based on location and
preference as well as to ensure faster delivery by pinging closest delivery
personel wheneve there is an order


File summary

 .log file - access.log and error.log for gunicorn logging
 data.py - generating sample data -documented
 grocree.service - daemonise gunicorn WSGI
 gunicorn.conf.py - WSGI configuration
 .pid file - store WSGI master process ID - set to rm -rf run.pid at start
 ngin.conf - nginx web server location for proxying to Flask app server
 setup.sql - create database, database user and  permision grants
 models - directory store application objects
 web-static folder - store static resource html/css/js/images 
 webapp folder - Flas web application folder 

Running the Application
#clone
git clone https://github.com/aruna-hk/grocree;
#creat WSGI interface
sudo ln -s grocree.service /etc/systemd/system/grocree.service
#edit nginx config file
#add the following inside server block in /etc/nginx/sites-enabled/default
   #include /path/to/where/cloned/repo/is/nginx.conf
#remove .pid file if present in the foder
#edit gunicorn gunicorn.config.py file, set working directory as u wish
#ensure sqlalchemy, flask-cors, flask, mysqldb are installed
#start the application
sudo service grocree start;
sudo systemctl grocree enable #emable autorestart on boot
sudo service nginx reload; #upate config

#incase of any error read error.log for gunicor error/gateway error
#for nginx error read nginx log file

#run to test
curl localhost/index.html #landing page
or go to browser and enter the url


<author><kiptooharon.hk@gmail.com>
