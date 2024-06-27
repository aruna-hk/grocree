#!/usr/bin/python3
"""
   associate order and product

"""

from sqlalchemy import Table, Column, Numeric
from sqlalchemy import String, ForeignKey
from .base import base, Base


class Orderline(Base, base):
    """
       associate entity many to may relationship btw order and groceries
    """
   
    __tablename__ = "orderLine"
    orderId = Column(String(60), ForeignKey("orders.id"))
    groceryId = Column(String(60), ForeignKey("groceries.id"))
    quantity = Column(Numeric(12, 2))
