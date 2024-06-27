#!/usr/bin/python3
"""
    stores table
"""

from sqlalchemy import Table, Column, DateTime, Numeric
from sqlalchemy import String, ForeignKey
from datetime import datetime
from .base import base, Base

class Store(Base, base):
     """
         stores table construction
     """
     __tablename__ = "stores"
     name = Column(String(30), nullable=False, index=True)
     areaName = Column(String(30), nullable=False, index=True, unique=True)
     latitude = Column(Numeric(8, 3))
     longitude = Column(Numeric(8, 3))
