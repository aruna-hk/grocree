#!/usr/bin/python3
"""
   products tables -- groceries available for sale in the firm
   stores can be selling different items, this table contains items across
   all stores
"""

from .base import Base, base
from sqlalchemy import Table, Column, String, Text, DateTime
from datetime import datetime


class Grocery(Base, base):
    """grocery items"""
    __tablename__ = "groceries"
    name = Column(String(20), nullable=False, index=True, unique=True)
    description = Column(Text, nullable=False)
    category = Column(String(20), nullable=False)
    imgURL = Column(String(30), nullable=False)
