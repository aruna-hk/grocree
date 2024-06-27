# OBJECTS MODELS

                          OVERVIEW
This directory contains objects for the project,
        Customer - instatiate customer object & mapped to customers database table
        grocery - grocery product to sell, mapped to groceries table
        Order - instatiate order & mapped to order database table
        Delivery - delivery personel & mapped to deliveryPersonel table
        Ordeline - association class associate orders and groceries mapped to orderline table
        store - instatiate store object, house groceries and facilitate tailoring listings
                to customers mapped to stores table
        inventory - associate store and products, mapped to inventory tale
                    keep stores inventory levels
      
File entities.py contain database chema definition using sqlalchemy core module
This is a fast way do develop database schema using sqlalchemy core
To create database schema fast run
     $ ./entities.py > entities.txt
     $ #ensure proper user and db are passed to the engine to create database interface
     $ #change the database url string as you wish

     $ log will be written to entities.txt (you can read them)
/******************************************************************************/
NB - key worder values passed to create_engine are packed into a dictionary and 
passed as parameter to DBAPI, to know the full list of prefered key-worder arguments
consult DBAPI i.e mysqldb for mysql , pycopg for postgreSQl etc
/*******************************************************************************/

          STEP BY STEP DEMO

To work through this tutorial first
$ git clone https://github.com/aruna-hk/grocree.git
$ cd grocree/models

first create a database and user to user for this project
use root to login to mysql or any other with root privilegs to login and create a database and a user
with all privileges on database crated
    $ sudo mysql #and enter password
    > -- sql promt
    > create database <databaseName>
    > create user if not exists <usersName>
    > grant all privileges on <databaseName>.* to <usersName>@'localhost';
    > commit;
replace parameter in angular brackets with respective values

execute entities.py with command line arguments or will get info from environment
make sure to export variable to use them with getenv if building connection url will depend
on environment variables

i.e
$ export dbuser=<dbuserName>
$ export dbname=<dbname>
$ export dbpassword=<password>
$ export dbhost=<hostname>
$ ./entities.py -- will build conection string using environment variables above

if passing argument execute entities.py script as follow, order of parameters to be kept
$ ./entities.py <dbuser> <userpassword> <dbhost> <dbname>
$ #echo is set to true in create engine there output by default to stdout,
$ #you can redirect the output to a file as follows
$ ./entities.py > entities.txt
$ ./entities <dbuser> <userspassword> <dbhost> <dbname> > entities.txt

Using the execution format ./entities.py to execute the script beause sheng line #!/usr/bin/python3 specifies
location of python if python not in path /usr/bin/python3 run the script with python as follows

$ python3 -m entities

<author><kiptoohron.hk@gmail.com>
