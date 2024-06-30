#!/usr/bin/python3
"""
    customers table modeling
    import dbstructure instance of metadata to hold database schema
"""

from .base import base, Base
from sqlalchemy import Table, Column, String, DateTime, Numeric
from datetime import datetime

class Customer(Base, base):

    """customer"""
    __tablename__ = "customers"
    name = Column(String(35), nullable=False)
    username = Column(String(25), nullable=False, unique=True)
    password = Column(String(15), nullable=False)
    email = Column(String(35), nullable=False, unique=True)
    phone = Column(String(18), nullable=False, unique=True)
    latitude = Column(Numeric(8, 3))
    longitude = Column(Numeric(8, 3))
    imgURL = Column(String(60))
