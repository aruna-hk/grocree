#!/usr/bin/python3
"""
    delivery personel table
    import dbstructure - metadata object
    location attributes
      latutude and longitude necessary to place delivery personel relative
      to store
"""
from .base import Base, base
from sqlalchemy import Table, String, DateTime, Integer, Numeric, Column
from datetime import datetime


class Delivery(Base, base):
    """
        delivery personel table-- separate from customers tho they can
        be customers, separated because of collection of
        different data ie NationalIds not necessary for customers
     """
    __tablename__ = "delivery"
    nationalId = Column(Integer, nullable=False, unique=True)
    name = Column(String(30), nullable=False)
    username = Column(String(60), nullable=False,index=True, unique=True)
    password = Column(String(15), nullable=False)
    email = Column(String(35), nullable=False, unique=True)
    phone = Column(String(18), nullable=False, unique=True)
    latitude = Column(Numeric(8, 3))
    longitude = Column(Numeric(8, 3))
    imgURL = Column(String(60))
