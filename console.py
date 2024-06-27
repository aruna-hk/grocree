#!/usr/bin/python3
import cmd
from models import Customer, Order, Orderline, Inventory
from models import Store, Grocery, Delivery
from models import storage

classes = {"custiomer" : Customer, "order": Order, "ordeline":Orderline,
           "inventory":Inventory, "store":Store, "grocery": Grocery, "delivery": Delivery}
class grocree(cmd.Cmd):
    prompt = "grocree >>$ " 
    #enmpty line
    def do_EOF(self, line):
        print()
        exit()

    #empty line
    def do_emptyline(self, line):
        return True

    #exit
    def do_exit(self, line):
        print()
        exit()

    #create object
    #create <objName> <**kwarg**
    def do_create(self, line): 
        print("----------------------------------------")
        print("creating")
        print(line)
        print("----------------done------------------------")
    #update created object
    #update <objname> <objectId> <**kwargs>
    def do_update(self, line):
        print("------------------------------------------")
        print("updating")
        pass
        print("------------------done------------------")

    def do_delete(self, line):
        print("----------------------------------------")
        print("deleting")
        pass
        print("------------------done-----------------------")
    #read content
    #id or all object base on call
    #read <objname> <objid> 
    #read <objName> -- read all class objects
    #read - read all objects

    def do_read(self, line):
        print("---------------------------------------------------")
        print("reading objects")
        pass;
        print("----------------------done------------------------")



if __name__ == "__main__":
    grocree().cmdloop() 
