#!/usr/bin/python3
"""
    orders table
"""
from sqlalchemy import Table, Column, DateTime, Numeric
from sqlalchemy import String, ForeignKey
from datetime import datetime
from .base import base, Base

class Order(Base, base):
    """
       order table - each time user place order table is updated
       together with orderline table
    """
    __tablename__ = "orders"
    customerId = Column(String(60), ForeignKey("customers.id"))
    storeId = Column(String(60), ForeignKey("stores.id"))
    deliveryPersonId = Column(String(60), ForeignKey("delivery.id"))
    orderStatus = Column(String(12), nullable=False)
