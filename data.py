#!/usr/bin/python3

from models import *
from random import randrange
from sqlalchemy.exc import IntegrityError

###############################################################
#####RANDOM DATA GENERATION###################################


##################stores##########################
#randomize store
#visualize map latitude and longitude
print("stores ..")
stores = []
for i in range(0, 100):
    store = {}
    store['name'] = 'store{}'.format(i + 100)
    store['latitude'] = float(randrange(-90, 91))
    store['longitude'] = float(randrange(-180, 181))
    #get location name using geolocation api
    store['areaName'] = store['name'] + '@' + \
                     str(store['latitude']) + str(store['longitude'])
    new = Store(**store)
    stores.append(new)
    storage.new(new)
print("..stores")
print("products..")
################groceries#######################
items = []
_items = [
        {'name':'banana', 'description':'10$ each',
         'category':'fruits', 'imgURL':'/images/0.png'},
        {'name':'spinach', 'description':'for 50$',
         'category':'vegetables', 'imgURL':'/images/1.png'},
        {'name':'pork', 'description':'1kg == money',
         'category':'meat', 'imgURL':'/images/2.png'},
        {'name':'cow meat', 'description':'100$ per kg',
         'category':'meat', 'imgURL':'/images/3.png'},
        {'name':'eggs', 'description':'20$ per egg',
         'category':'dairy', 'imgURL':'/images/4.png'},
        {'name':'milk', 'description':'70$ per kg/per litre',
         'category':'dairy', 'imgURL':'/images/5.png'},
        {'name':'cabbage', 'description':'50$ each',
         'category':'vegetables', 'imgURL':'/images/6.png'},
        {'name':'yoghurt', 'description':'browse for packing',
         'category':'dairy', 'imgURL':'/images/7.png'},
        {'name':'fish', 'description':'at 250 each',
         'category':'meat', 'imgURL':'/images/6.png'},
        {'name':'hen', 'description':'at 650$ ',
         'category':'meat', 'imgURL':'/images/6.png'}
      ]

for item in _items:
    new_item = Grocery(**item)
    items.append(new_item)
    storage.new(new_item)
print("..products")
storage.save()
print("inventory..")
################inventory######################

# randomizing using entries
#try to save
#error == pass/<some funct>
inventory = []
#only 20 entries or less

for i in range(0, 20):
    obj = {}
    obj['storeId'] = stores[randrange(0, len(stores))].id
    obj['groceryId'] = items[randrange(0, len(items) - 1)].id
    obj['stock'] = float(randrange(5, 1000))
    obj['price'] = float(randrange(50, 500))
    _inventory_entry = Inventory(**obj)
    storage.new(_inventory_entry)
    try:
        storage.save()
    except IntegrityError as e:
        pass
print("..inventory")
print("delivery personel..")
#############delivery personel#####################
delivery_personel = []
#delivery personel test data generato
id_start = 1000 #id increment from 1000
for i in range(0, 500):
    _delivery_person = {}
    _delivery_person['nationalId'] = id_start
    id_start = id_start + 1
    _delivery_person['name'] = 'delivery_guy{}'.format(i)
    _delivery_person['username'] = 'delivery_user_{}'.format(i)
    _delivery_person['password'] = 'password{}'.format(i)
    _delivery_person['email'] = _delivery_person['username'] + '@gmail.com'
    _delivery_person['phone'] = '07{}'.format(i) + str(randrange(600000,1000000))
    _delivery_person['latitude'] = float(randrange(-90, 91))
    _delivery_person['longitude'] = float(randrange(-180, 181))
    _delivery_person['imgURL'] = "/icon/user.png"
    new = Delivery(**_delivery_person)
    delivery_personel.append(new)
    storage.new(new)
print("..delivery personel")
print("Customers..")
#################customers##########################
#--manual inpt
customers = []
users = [
         {'name':'kiptoo haron', 'username':'hk', 'password':'Aa48904890plmn$',
           'email':'kiptooharon.hk@gmail.com', 'phone':'0714261231', 'latitude': 0.0,
           'longitude':45, 'imgURL': "/icons/user.png"},
         {'name':'varun', 'username':'vrn', 'password':'Aa48904890plmn$',
           'email':'varun.hk@gmail.com', 'phone':'01015621067', 'latitude': 0.0,
           'longitude':45, 'imgURL': "/icons/user.png"},
         {'name':'jacinta', 'username':'jass', 'password':'Aa48904890plmn$',
           'email':'jass@gmail.com', 'phone':'714261231', 'latitude': -55,
           'longitude':90, 'imgURL':"/icons/user.png"},
         {'name':'bill', 'username':'billy', 'password':'Aa48904890plmn$',
           'email':'bill@gmail.com', 'phone':'14261231', 'latitude': -55,
           'longitude':90, 'imgURL':"/icons/user.png"},
         {'name':'delores', 'username':'delores', 'password':'Aa48904890plmn$',
           'email':'delores@gmail.com', 'phone':'4261231', 'latitude': 0.0,
           'longitude':30, 'imgURL':"/icons/user.png"},
         {'name':'robot', 'username':'mrrobot', 'password':'Aa48904890plmn$',
           'email':'robot@gmail.com', 'phone':'261231', 'latitude': 0.0,
           'longitude':30, 'imgURL':"/icons/user.png"},
         {'name':'dom', 'username':'dom', 'password':'Aa48904890plmn$',
           'email':'dom@gmail.com', 'phone':'61231', 'latitude': 60,
           'longitude':-135, 'imgURL':"/icons/user.png"},
         {'name':'tyrell', 'username':'wellick', 'password':'Aa48904890plmn$',
           'email':'wellick@gmail.com', 'phone':'231', 'latitude': 60,
           'longitude':-135, 'imgURL':"/icons/user.png"},
         {'name':'White Rose', 'username':'wR', 'password':'Aa48904890plmn$',
           'email':'wr@gmail.com', 'phone':'31', 'latitude': 60,
           'longitude':-135, 'imgURL':"/icons/user.png"},
         {'name':'angela', 'username':'moss', 'password':'Aa48904890plmn$',
           'email':'angela@gmail.com', 'phone':'0714261', 'latitude': 30,
           'longitude':-150, 'imgURL':"/icons/user.png"},
         {'name':'tallman', 'username':'richard', 'password':'Aa48904890plmn$',
           'email':'richartallman@gmail.com', 'phone':'0714', 'latitude': 30,
           'longitude':-150, 'imgURL':"/icons/user.png"},
         {'name':'alex', 'username':'gencoing', 'password':'Aa48904890plmn$',
           'email':'alex@gmail.com', 'phone':'07142461231', 'latitude': 30,
           'longitude':-150, 'imgURL':"/icons/user.png"},
         {'name':'darleen', 'username':'mrrbt', 'password':'Aa48904890plmn$',
           'email':'darleen@gmail.com', 'phone':'071424612301', 'latitude': 0,
           'longitude':0, 'imgURL':"/icons/user.png"},
         {'name':'cisco', 'username':'csco', 'password':'Aa48904890plmn$',
           'email':'cisco@gmail.com', 'phone':'0731', 'latitude': 0,
           'longitude':-0, 'imgURL':"/icons/user.png"},
         {'name':'jared', 'username':'jrd', 'password':'Aa48904890plmn$',
           'email':'jared@gmail.com', 'phone':'00011', 'latitude': 20,
           'longitude':90, 'imgURL':"/icons/user.png"},
         {'name':'mitch', 'username':'mtch', 'password':'Aa48904890plmn$',
           'email':'mitch@gmail.com', 'phone':'0002', 'latitude': -30,
           'longitude':60, 'imgURL':"/icons/user.png"},
         {'name':'recude', 'username':'koko', 'password':'Aa48904890plmn$',
           'email':'koko@gmail.com', 'phone':'0003', 'latitude': 0.0,
           'longitude':0.0, 'imgURL':"/icons/user.png"}
        ]
for item in  users:
    new_user = Customer(**item)
    customers.append(new_user)
    storage.new(new_user)

# ----- auto generate 2000 users
for i in range(0, 2000):
    _customer = {}
    _customer['name'] = 'customer_{}'.format(i)
    _customer['username'] = 'user{}'.format(i)
    _customer['password'] = 'user_{}passwd'.format(i)
    _customer['email'] = "customer_{}@gmail.com".format(i)
    _customer['phone'] = '07{}'.format(i) + str(randrange(600000,1000000))
    _customer['latitude'] = float(randrange(-90, 91))
    _customer['longitude'] = float(randrange(-180, 181))
    _customer['imgURL'] = "/icons/user.png"
    new = Customer(**_customer)
    customers.append(new)
    storage.new(new)

storage.save()
print("..customers")

print("orders..")
################orders################################
#randomize customers and stores
options = ['pending', 'ontransit']
#40 orders;
orders = []
for i in range(0, 40):
    _order = {}
    _order['customerId'] = customers[randrange(0, len(customers))].id
    _order['storeId'] = stores[randrange(0, len(stores))].id
    _order['deliveryPersonId'] = delivery_personel[randrange(0, len(delivery_personel))].id
    _order['orderStatus'] = options[randrange(0, 2)]
    _new_order = Order(**_order)
    orders.append(_new_order)
    storage.new(_new_order)
print("..orders")

print("ordeline..")
###################orderline##############################
#for every order assign products
min=1#minimum amt of items
max=50
for order in orders:
    _items = randrange(min, max)
    for i in range(0, _items):
        _order = {}
        _order['orderId'] = order.id
        _order['storeId'] = stores[randrange(0, len(stores))].id
        _order['groceryId'] =  items[randrange(0, len(items))].id
        _order['quantity'] = randrange(4, 50)
        _new = Orderline(**_order)
        storage.new(_new)
storage.save()
print("..orderline")
