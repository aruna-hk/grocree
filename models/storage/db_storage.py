#!/usr/bin/python3
"""database storage login to database and update
   specific user does database updates and quering --shopkeeper
"""
from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import IntegrityError
from sqlalchemy import create_engine, insert, select, update, delete
from os import getenv, environ
from sqlalchemy.orm import scoped_session
from ..base import base
from ..customer import Customer
from ..inventory import Inventory
from ..grocery import Grocery
from ..orderline import Orderline
from ..order import Order
from ..store import Store
from ..delivery import Delivery

class Storage:
    __engine = None
    __session = None
    def __init__(self):
        """create db engine """

        print("---------------------------------")
        user = getenv("DB_USER")
        if user is None:
            user = "grocree"
        password = getenv("DB_PW")
        if password is None:
            password = "Aa48904890plmn$"
        host = getenv("DB_HOST")
        if host is None:
             host = "localhost"
        db = getenv("DB_USER")
        if db is None:
            db = "grocree"

        
        url = "mysql+mysqldb://{}:{}@{}/{}".format(user, password, host, db)
        self.__engine = create_engine(url)

        #create database representations 
        #and session manager
        #call session manager to get session
    def reload(self):
        print("---------engine------------------------")
        base.metadata.create_all(self.__engine)
        Session = sessionmaker(bind=self.__engine, expire_on_commit=False) 
        self.__session = Session()

    #add object(s) to session
    def new(self, object_s):
        #internal error handling
        self.__session.add(object_s)

    #save
    #errors to be handled by calling function
    def save(self):
        self.__session.commit()

    #database querying
    #storage.query(statement)
    #errors by calling function
    def query(self, statement):
        result_proxy = self.__session.execute(statement)

        return result_proxy
       
    #close
    def close(self):
        self.__session.close()
