#!/usr/bin/python3
"""database storage login to database and update
   specific user does database updates and quering --shopkeeper
"""
from sqlalchemy import create_engine
from os import getenv

class db_storage:
    __engine = None;
    __session = None;

   def __init__(self):
       """create db engine """

       user = getenv("DB_USER")
       password = getenv("DB_PW")
       host = getenv("HOST")
       db = getenv("DB")

       url = "mysql+mysqldb://{}:{}@{}/{}".format(user, password, host, db)
       self.__engine = create_engine(url)
