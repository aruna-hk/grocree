#!/usr/bin/python3
from flask import Flask, g, request, abort, jsonify
from flask import session, redirect, make_response
from flask import url_for
from models import Customer, Order, Orderline, Grocery
from models import storage, Delivery, Store, Inventory
from flask import render_template
from sqlalchemy import select, update, and_, or_, join
from sqlalchemy.sql import func
import json
from flask_cors import CORS
from math import sqrt
from decimal import Decimal

app = Flask(__name__)
CORS(app, origins='*')
app.secret_key = "protect_cookies"
#before request
#radius
@app.before_request
def before_request():
    g.radius = 20

#delivery reqistration and/or
#get registered users
#create delivery persons account
@app.route("/users/delivery", methods=['POST', 'GET'], strict_slashes=False)
def delivery():
    if request.method == 'POST':
        user_info = request.get_json()
        if not user_info:
            abort(400, "Error invalid request")
        keys = user_info.keys()
        if "name" not in keys:
            abort(400, "Specify name")
        if "nationalId" not in keys:
            abort(400, "national id required")
        if "email" not in keys:
            abort(400, "email missing")
        if "phone" not in keys:
            abort(400, "phone missing")
        if "username" not in keys:
            abort(400, "set username")
        if "password" not in keys:
            abort(400, "set password")
        #get gps location and update
        #right now required for testing
        if "latitude" not in keys or "longitude" not in keys:
            abort(400, "location needed")
        _delivery_guy = Delivery(**user_info)
        storage.new(_delivery_guy)
        storage.save()
        return jsonify({201:"account create"})
    stmt = select(Delivery)
    result_proxy = storage.query(stmt)
    rows = result_proxy.fetchall()
    result = [i._data[0].to_dict() for i in rows]
    return jsonify(result)

#update a/c and/or get account info
#if GET -get user info with his/her orders
@app.route("/users/delivery/<delivery_person_id>/", \
           methods=['GET','PUT'], strict_slashes=False)
def delivery_update(delivery_person_id):
    if request.method == 'PUT':
        #dont updat name and id
        user_info = request.get_json()
        if user_info is None:
            abort(400, "Update error")
        skip_keys = ['name', 'nationalId']
        for key in skip_keys:
            try:
                user_info.pop(key)
            except KeyError as e:
                pass
        stmt = update(Delivery).values(user_info)\
                      .where(Delivery.id == delivery_person_id)
        try:
            storage.query(stmt)
            storage.save()
            return jsonify({200:"update sucessfull"})
        except IntegrityError as e:
            abort(400, "phone, email or username exists")
    #dict as key - delivery personel dictionary to list of order
    delivery_personel = select(Delivery)\
                         .where(Delivery.id == delivery_person_id)
    delivery_person = storage.query(delivery_personel).first()
    if delivery_person is None:
        abort(400, "User Doesn't exist")
    delivery_person = delivery_person._data[0].to_dict()

    stmt = select(Order).where(Order.deliveryPersonId == delivery_person_id)
    rows = storage.query(stmt).fetchall()
    results = [i._data[0].to_dict() for i in rows]
    delivery_person_orders = {"deliveryPerson":delivery_person, "order":results}
    return jsonify(delivery_person_orders)



#create customer account and/or
#view users
@app.route("/users/customers", methods=['POST', 'GET'], strict_slashes=False)
def create_ac():
    if request.method == 'POST':
        user = request.get_json()
        keys = user.keys()
        if 'name' not in keys:
            abort(400, "name missing")
        if 'username' not in keys:
            abort(400, "username missing")
        if 'password' not in keys:
            abort(400, "password missing")
        if 'email' not in keys:
            abort(400, "email missing")
        if 'phone' not in keys:
            abort(400, "phone missing")
        if 'latitude' not in keys or 'longitude' not in keys:
            abort(400, "lacation information missing")
        customer = Customer(**user)
        storage.new(customer)
        storage.save()
        return jsonify({201: "account created"})
    result_proxy = storage.query(select(Customer))
    rows = result_proxy.fetchall()
    result = [i._data[0].to_dict() for i in rows]
    return jsonify(result)


#get or update user info
@app.route("/users/customers/<user_id>", methods=["GET", 'PUT'], strict_slashes=False)
def account_management(user_id):
    if request.method == 'GET':
        statement = select(Customer).where(Customer.id == user_id)
        result = storage.query(statement).first()
        if result is None:
            abort(400, "invalid user")
        request.method = 'GET'
        _orders = orders(user_id)
        _user = {"customer":result[0].to_dict(), "orders": _orders.json}
        return jsonify(_user)

    skip_keys = ['created_at', 'name']
    update_info = request.get_json()
    if update_info is None:
        err(400, "Update dictionary missing")
    for key in update_info.keys():
        if key in skip_keys:
            update_info.pop(key)
    statement = update(Customer).where(Customer.id == user_id)
    statement = statement.values(update_info)
    storage.query(statement)
    storage.save()
    return jsonify({201: "update successful"})

#get store from which order is made
#based on location
#latitude and longitude
#some radius estimate
def allocate_store(latitude, longitude):
    stmt = select(Store.id).where(
                 and_(
                     latitude <= Store.latitude + g.radius,
                     latitude >= Store.latitude - g.radius)).where(
                 and_(
                         longitude <= Store.longitude + g.radius,
                         longitude >= Store.longitude - g.radius)
                    )
    result_proxy = storage.query(stmt)
    #notify the store of order
    store = result_proxy.fetchall()
    return store

#get delivery guy
def get_delivery(store_id):
    g.radius = g.radius / 2
    latitude_longitude = select(Store.latitude, Store.longitude).where(Store.id == store_id)
    latitude, longitude = storage.query(latitude_longitude).first()

    stmt = select(Delivery.id).where(
                   and_(
                     Delivery.latitude <= latitude + Decimal(g.radius),
                     Delivery.latitude >= latitude - Decimal(g.radius))).where(
                   and_(
                     Delivery.longitude <= longitude + Decimal(g.radius),
                     Delivery.longitude >= longitude - Decimal(g.radius)))
    #notify close delivery guys
    #get feedback update who picked the order
    #return deliveryguy id
    delivery_person = storage.query(stmt).fetchall()
    if len(delivery_person) == 0:
        g.radius = g.radius + (g.radius / 2)
        delivery_person = get_delivery(store_id)
    return delivery_person[0]

#closest store
def _close(latitude, longitude):
    #binary search--lll
    
    #half_radius = _radius / 2
    stmt = select(Store.id).where(
                 and_(
                     latitude <= Store.latitude + g.radius,
                     latitude >= Store.latitude - g.radius)).where(
                 and_(
                         longitude <= Store.longitude + g.radius,
                         longitude >= Store.longitude - g.radius)
                    )
    result_proxy = storage.query(stmt)
    #notify the store of order
    result = result_proxy.fetchall()
    if len(result) == 0:
       g.radius = g.radius + (g.radius / 2)
       result =  _close(latitude, longitude)
    elif len(result) > 2:
        g.radius = int(g.radius - sqrt(g.radius))
        result =  _close(latitude, longitude)
    return result[0].id

#place order
@app.route("/users/customers/<user_id>/orders", methods=['POST', 'GET'], strict_slashes=False)
def orders(user_id):
    if request.method == 'GET':
        stmt = select(Order).where(Order.customerId == user_id)
        result_proxy = storage.query(stmt)
        rows = result_proxy.fetchall()
        results = [i._data[0].to_dict() for i in rows]
        return jsonify(results)

    __order = request.get_json()
    #get the closest store to dispatch product
    #cart items from diffrent close stores - centralise in closest and dispatch
    #store aim at ensuring same products -- all stores --cut costs
    #useful in bringin goods to buyers
    latitude, longitude = storage.query(select(Customer.latitude, Customer.longitude)\
                         .where(Customer.id == user_id)).first()
    #get closest store / inform to collect
    store_id = _close(latitude, longitude)
    delivery = get_delivery(store_id).id
    an_order = Order(customerId=user_id, storeId=store_id, deliveryPersonId=delivery, orderStatus="pending")
    storage.new(an_order)
    storage.save()
    for key, value in __order.items():
        if key.split('$')[1] == store_id:
            _entry = Orderline(orderId=an_order.id, storeId=store_id, groceryId=key.split('$')[0], quantity=value)
            storage.new(_entry)
        else:
            _entry = Orderline(orderId=an_order.id, storeId=key.split('$')[1], groceryId=key.split('$')[0], quantity=value)
            storage.new(_entry)
    storage.save()

    return make_response(jsonify("Order created"), 201)

#track order
@app.route("/users/customers/<user_id>/orders/<order_id>",\
             methods=['GET'], strict_slashes=False)
def track_order(user_id, order_id):
    return "live location tracking"


#if product exist
def if_exist(name):
    statement = select(Grocery.id).where(Grocery.name == name)
    result = storage.query(statement).first()
    if result:
        return result[0]
    return None

#inventory update
def inventory_update(store_id, product_id, stock=None, price=None):
    stmt = select(Inventory.stock, Inventory.price).where(
                  and_(
                       Inventory.storeId == store_id,
                       Inventory.groceryId == product_id)
                   )
    response = storage.query(stmt).first()
    if response:
        update_dict = {}
        if stock:
            stock = stock + response[0]
            update_dict['stock'] = stock
        if price:
            price = price + response[1]
            update_dict['price'] = price
        stmt = update(Inventory).values(update_dict).where(
                   and_(
                        Inventory.storeId == store_id,
                        Inventory.groceryId == product_id)
                    )
        storage.query(stmt)
        storage.save()
        return jsonify({200:" stock level updated"})
    _new_entry = Inventory(storeId=store_id, groceryId=product_id, stock=stock, price=price)
    storage.new(_new_entry)
    storage.save()
    return jsonify({200:"new inventory entry created"})

#auth needed, restrict to stores only access/seller
#products update
#inventory update
#inventory check
@app.route("/stores/<store_id>/products/", methods=["PUT", "POST", "GET"],  strict_slashes=False)
def add_product(store_id):
    if request.method != 'GET':
        req = request.get_json()
        if not request:
            abort(400, "Products Creation/update Error")

    #update product and/or update inventory
    if request.method in ["POST", "PUT"]:
        check_product_exist = if_exist(req['name'])
        if check_product_exist:
            if ('stock' in req.keys()) or ('price' in req.keys()):
                try:
                    _stock = req['stock']
                except KeyError:
                    _stock = None,
                try:
                    _price = req['price']
                except KeyError:
                    _price = None
                return inventory_update(store_id, check_product_exist, _stock, _price)
            abort(400, "Inventory update Error")
        _stock = req.pop("stock")
        _price = req.pop("price")
        _product = Grocery(**req)
        try:
            storage.new(_product)
        except IntegrityError as e:
            storage.__session.rollback()
            abort(400, "Inventory update error")
        storage.save()
        return inventory_update(store_id, _product.id, _stock, _price)
    stmt = select(Inventory.groceryId, Inventory.stock, Inventory.price)\
                .where(Inventory.storeId == store_id)
    result = storage.query(stmt).fetchall()
    _items = []
    for _val in result:
        _entry = {}
        _entry['groceryId'] = _val.groceryId
        _entry['stock_level'] = _val.stock
        _entry['price'] = _val.price
        _items.append(_entry)

    return  jsonify(_items)

#return dictionary listings
def _listings(results):
    #keys = ['groceryId', 'name', 'description', 'category','name_1',
    #        'areaName', 'stock', 'price']
    listings = []
    for entry in results:
        _listing = {}
        _listing['id'] = entry.id
        _listing['name'] = entry.name
        _listing['description'] = entry.description
        _listing['category'] = entry.category
        _listing['img'] = entry.imgURL
    #    _listing['storeName'] = entry.name_1
    #    _listing['areaName'] = entry.areaName
        _listing['store'] = entry.id_1
        _listing['stock'] = entry.stock
        _listing['price'] = entry.price
        listings.append(_listing)

    return listings
#home/customer landing page tailor
@app.route("/home/customers/<user_id>", strict_slashes=False)
def home(user_id=None):
    listings_stmt = select(Grocery.id, Grocery.name, Grocery.category,\
                        Grocery.description,Grocery.imgURL, Store.id,\
                        Inventory.stock, Inventory.price).join(Grocery).join(Store)
    profile = "/icons/user.png"
    username = 'login/register';
    if user_id:
        #if user_id return json data
        stmt = select(Customer.username, Customer.imgURL, Customer.latitude, Customer.longitude).where(Customer.id == user_id)
        json_data = {}
        user = {}
        result = storage.query(stmt).first()
        user['name'] = result[0]
        user['image'] = result[1]
        user['id'] = user_id
        json_data['user'] = user

        close_stores = allocate_store(result[2], result[3])
        if len(close_stores) == 0:
            #best selling / non parishables
            _items = _listings(storage.query(listings_stmt).fetchall())
            json_data['items'] = _items
            return jsonify(json_data)
        #for every close store
        listings = []
        #narrow down the radius closest come'f first in listings
        for store in close_stores:
            __listings = storage.query(listings_stmt.where(Store.id == store[0])).fetchall()
            listings = listings + __listings
        _items = _listings(storage.query(listings_stmt).fetchall())
        json_data['items'] = _items
        return jsonify(json_data)

    #just home
    listings = storage.query(listings_stmt).fetchall()
    __items = _listings(listings)
    #if accept is json return json else html
    if request.headers['Accept'] == 'application/json':
        return __items
    return render_template("index.html", user=user_id, profile=profile, username=username, items=__items)

#home not logged in
@app.route("/home", strict_slashes=False)
@app.route("/home/customers", strict_slashes=False)
def home_1():
    return home()
#login page
@app.route("/login", methods=["GET"], strict_slashes=False)
def login():
   stmt = select(Customer.password, Customer.imgURL, Customer.id)\
            .where(Customer.username == request.args.get('username'))
   _auth = storage.query(stmt).first()
   if _auth:
      if _auth[0] == request.args.get("password"):
          _user = {}
          _user['imgURL'] = _auth[1]
          _user['username'] = request.args.get("username")
          url = url_for('home', user_id=_auth[2])
          url = "http://localhost" + url
          return redirect(url)
      else:
          abort(401, "unauthorized")
   return abort(404, "not found")

if __name__ == "__main__":
    app.run(host="0.0.0.0")
