#!usr/bin/python3
"""base model for creation of objects unique universal identifiers
UUID for use in database as row keys
also object creation time and updation time created i base model
"""

from datetime import datetime
from uuid import uuid4

class base:
    """base class"""

    def __init__(self, dic={}):
        self.id = str(uuid4())
        self.created_at = datetime.now().isoformat()
        self.updated_at = self.created_at
        if len(dic) != 0:
            for key, value in dic.items():
                self.__setattr__(key, value)

    def to_dict(self):
        object_dict = self.__dict__
        object_dict["class"] = self.__class__.__name__
        return object_dict
