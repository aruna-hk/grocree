                     <h1>GROCREE</h1>

</p>Distributed online grocery Stores where buyers and delivery personnel are
placed relative to stores to ensure tailored listings based on location and
preference as well as to ensure faster delivery by pinging closest delivery
personel whenever there is an order</p>

<br/>
 <ul>
   <li>.log - access.log and error.log for gunicorn logging</li>
   <li>data.py - generating sample data -documented</li>
   <li>grocree.service - daemonise gunicorn WSGI</li>
   <li>gunicorn.conf.py - WSGI configuration</li>
   <li>.pid file - store WSGI master process ID - set to rm -rf run.pid at start</li>
   <li>nginx.cnf files - nginx web server location for proxying to Flask app server</li>
   <li>setup.sql - create database, database user and  permision grants</li>
   <li>models - directory store application objects</li>
   <li>web-static folder - store static resource html/css/js/images </li>
   <li>webapp folder - Flask web application folder </li>
 </li>
<h3>Installing and Running the Application</h3>

#read install
 <ol>
   <li>clone https://github.com/aruna-hk/grocree;</li>
   <li>sudo ln -s grocree.service /etc/systemd/system/grocree.service
        ensure to edit paths #to crete servic file</li>
    <li>edit nginx config file add the following inside server block in /etc/nginx/sites-enabled/default
        include /path/to/where/cloned/repo/is/nginx.conf to include proxy pass block</li>
    <li>edit gunicorn gunicorn.config.py file, set working directory as u wish</li>
    <li>ensure sqlalchemy, flask-cors, flask, mysqldb are installed--al requirement in .txt file are met
    </li>
    <li>start the application
       <ol>
        <li>sudo service grocree start;</li>
        <li>sudo systemctl grocree enable #enable autorestart on boot</li>
       </ol>
    </li>
    <li>sudo service nginx reload; #upnate config</li>
 </ol>

incase of any error read error.log for gunicorn error/gateway error<br/>
for nginx error read nginx log file

<h3>Test</h3>
<br/>
curl localhost/landing.html #landing page <br/>
or go to browser and enter the url


<a href=mailto:kiptooharon.hk@gmail.com>kiptooharon.hk@gmail.com</a>
