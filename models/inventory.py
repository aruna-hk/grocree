#!/usr/bin/python3
"""
    inventory table
       store stores inventory information,
       available products, inventory volumes
"""
from sqlalchemy import Table, Column, DateTime, Numeric
from sqlalchemy import CheckConstraint, String, ForeignKey
from datetime import datetime
from .base import base, Base

class Inventory(Base, base):
    """ keep track of store inventories """
    __tablename__ = "inventory"
    storeId = Column(String(60), ForeignKey("stores.id"), primary_key=True)
    groceryId = Column(String(60), ForeignKey("groceries.id"), primary_key=True)
    stock = Column(Numeric(12, 3),
                   CheckConstraint("stock >= 0", name="stock_level"),
                   nullable=False)
    price = Column(Numeric(12, 3), nullable=False)
    updated_at = Column( DateTime(),
                         default=datetime.now, onupdate=datetime.now)
