#!/usr/bin/python3
"""
    create metadata object and engine object
    to be imported by modules needing them
"""
from sqlalchemy.orm import declarative_base
from sqlalchemy import Column, String, DateTime
from datetime import datetime
import uuid

#base class -- builds database schema
base = declarative_base()

class Base:
    """ shared attributes """
    id = Column(String(60), primary_key=True)
    created_at = Column(DateTime(), default=datetime.now)
    updated_at = Column(DateTime(), default=datetime.now, onupdate=datetime.now)

    def __init__(self, *args, **kwargs):
        """init for objects"""
        self.id = str(uuid.uuid4())
        if kwargs:
            for key, value in kwargs.items():
                setattr(self, key, value)

    def __str__(self):
        """print str represntatiom""" 
        return self.id + " " + str(self.__dict__)

    def to_dict(self):
        obj_dictionary = self.__dict__
        return_dict = {}
        for key, value in obj_dictionary.items():
            if key == 'created_at' or key == 'updated_at':
                return_dict[key] = value.isoformat()
            elif key == '_sa_instance_state':
                pass
            else:
                return_dict[key] = value
        return return_dict

