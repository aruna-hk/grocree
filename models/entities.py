#!/usr/bin/python3
"""create customers table
   USING SQLALCHEMY CORE

   Execution
       $ ./enities.py <dbUser> <password> <dbName>
       where
         dbName - name of database to create the schema
         dbUser - database user with permission to operate on <db-name>database
         password - dbUser password
       if len(argv) == 0:
           it will use environment variables
              dbuser, dbpassword, dbname and dbhost env

"""
from sys import argv
from os import getenv
from sqlalchemy import Table, Column, DateTime, Numeric, Integer
from sqlalchemy import String, Text, ForeignKey, create_engine, MetaData
from sqlalchemy import CheckConstraint
from datetime import datetime

#database structure holder
dbstructure = MetaData()

#customers table
customers = Table("customers", dbstructure,
                  Column("id", String(60), primary_key=True),
                  Column("created_at", DateTime(), default=datetime.now),
                  Column("updated_at", DateTime(),
                         default=datetime.now, onupdate=datetime.now),
                  Column("name", String(35), nullable=False),
                  Column("username", String(25), nullable=False, unique=True),
                  Column("password", String(15), nullable=False),
                  Column("email", String(35), nullable=False, unique=True),
                  Column("phone", String(18), nullable=False, unique=True),
                  Column("latitude", Numeric(8, 3)),
                  Column("longitude", Numeric(8, 3)))

#groceries/ products table will call it groceries
groceries = Table("groceries", dbstructure,
                  Column("id", String(60), primary_key=True),
                  Column("created-at", DateTime(), default=datetime.now),
                  Column("updated-at", DateTime(),
                         default=datetime.now, onupdate=datetime.now),
                  Column("name", String(20), nullable=False, index=True, unique=True),
                  Column("description", Text, nullable=False),
                  Column("category", String(20), nullable=False))

#stores table construction
stores = Table("stores", dbstructure,
               Column("id", String(60), primary_key=True),
               Column("created-at", DateTime(), default=datetime.now),
               Column("updated-at", DateTime(),
                      default=datetime.now, onupdate=datetime.now),
               Column("name", String(30), nullable=False, index=True),
               Column("areaname", String(30), nullable=False, index=True, unique=True),
               Column("latitude", Numeric(8, 3)),
               Column("longitude", Numeric(8, 3)))

#delivery personel table-- separate from customers tho they can
#be customers, separated because of collection of
#different data ie NationalIds
delivery = Table("delivery", dbstructure,
                 Column("id", String(60), primary_key=True),
                 Column("created-at", DateTime(), default=datetime.now),
                 Column("updated-at", DateTime(),
                        default=datetime.now, onupdate=datetime.now),
                 Column("nationalId", Integer, nullable=False, unique=True),
                 Column("name", String(30), nullable=False),
                 Column("username", String(60), nullable=False, index=True, unique=True),
                 Column("password", String(15), nullable=False),
                 Column("email", String(35), nullable=False, unique=True),
                 Column("phone", String(18), nullable=False, unique=True),
                 Column("latitude", Numeric(8, 3)),
                 Column("longitude", Numeric(8, 3)))

#order table - each time user place order table is updated
#together with orderline table
orders = Table("orders", dbstructure,
               Column("id", String(60), primary_key=True),
               Column("created_at", DateTime(), default=datetime.now),
               Column("updated_at", DateTime(),
                      default=datetime.now, onupdate=datetime.now),
               Column("customerId", String(60), ForeignKey("customers.id")),
               Column("storeId", String(60), ForeignKey("stores.id")),
               Column("deliveryPersonId", String(60),
                      ForeignKey("delivery.id")),
               Column("orderStatus", String(12), nullable=False))

#associate many to may relationship btw order and groceries
orderLine = Table("orderLine", dbstructure,
                  Column("id", String(60), primary_key=True),
                  Column("orderId", String(60), ForeignKey("orders.id")),
                  Column("groceryId", String(60), ForeignKey("groceries.id")),
                  Column("quantity", Numeric(12, 2)))

#keep track of store inventories
inventory = Table("inventory", dbstructure,
                  Column("id", String(60), primary_key=True),
                  Column("storeId", String(60), ForeignKey("stores.id")),
                  Column("groceryId", String(60), ForeignKey("groceries.id")),
                  Column("Stock", Numeric(12, 3), CheckConstraint("stock >= 0", name="stock_level"), nullable=False),
                  Column("price", Numeric(12, 3), nullable=False),
                  Column("updated_at", DateTime(),
                         default=datetime.now, onupdate=datetime.now))

#parsist schema pass engine and metadata

def persistSchema(metadata, engine):
    """parsist database schema define in metadata"""
    try:
        return metadata.create_all(engine)
    except Exception as e:
        return e


if __name__ == "__main__":
      url = "mysql+mysqldb://{}:{}@{}/{}"
      if len(argv) == 1:
          print("---------------------------------------")
          print("Trying environmet variables to build database URL")
          print("---------------------------------------")
          user = getenv("dbuser", None)
          if user is None:
              user = str(input("database user not found enter USER: "))
          password = getenv("dbpassword", None)
          if password is None:
              password = str(input("no password variable db password: "))
          database = getenv("dbname", None)
          if database is None:
              database = str(input("db not in environment enter database name: "))
          host = getenv("dbhost", None)
          if host is None:
              host = "localhost"
         
          url = url.format(user, password, host, database)
          engine = create_engine(url, echo=True);
          result = persistSchema(dbstructure, engine);
      else:
          print("------------------------------------------")
          print("Trying command line args to build database URL")
          print("------------------------------------------")
          if len(argv) < 5:
              print("./entities.py <dbuser> <dbuserpassword> <dbhost> <dbname>")
          else:
              url = url.format(argv[1], argv[2], argv[3], argv[4])
              engine = create_engine(url, echo=True)
              result = persistSchema(dbstructure, engine);
