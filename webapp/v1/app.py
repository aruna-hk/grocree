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
from random import randrange
from sqlalchemy.exc import IntegrityError, PendingRollbackError
from flask_httpauth import HTTPBasicAuth
from redis import Redis
#from flask_socketio import SocketIO, emit

app = Flask(__name__)
CORS(app, origins='*')
cache = Redis()
@app.before_request
def before_request():
    #triangulation radius -- to be adjusted by endpoints if need be
    g.radius = 20

#get registered users and/or
#create delivery persons account
@app.route("/delivery", methods=['POST', 'GET'], strict_slashes=False)
def delivery():

    if request.method == 'POST':
        user = request.form.to_dict()
        #get gps location and update by fetch api to i.e openstreetmap
        #on clients side
        #for now -- randomize
        latitude = user_info.get("latitude", None)
        longitude = user_info.get("longitude", None)

        _user_img_profile = request.files.get('profile')
        _profile = "/home/hk/grocree/web-static/images/" + _user_img_profile.filename
        _user_img_profile.save(_profile)
        user['imgURL'] = _profile
        _delivery_personel = Delivery(**user)
        try:
            cache.geoadd("delivery", longitude, latitude, _delivery_personel.id)
        except Exception:
            pass
        storage.new(_delivery_personel)
        try:
            storage.save()
        except IntegrityError as e:
            #column violated
            column = e.orig.__repr__().replace('"', " ").replace('\\', ' ').replace("'", " ")\
                 .replace('(', ' ').replace(')', ' ')\
                 .strip(' ').split(' ')[-1].split(".")[-1]
            storage.rollback()
            #conflict
            return make_response(column, 409)
        return make_response(jsonify({"id": _delivery_personel.id}), 201)

    stmt = select(Delivery)
    result_proxy = storage.query(stmt)
    rows = result_proxy.fetchall()
    #every row to dict
    result = [i._data[0].to_dict() for i in rows]
    return make_response(jsonify(result), 200)

#update a/c and/or get account info
#if GET -get allocated orders and status
@app.route("/delivery/<delivery_person_id>/", \
           methods=['GET','PUT'], strict_slashes=False)
def delivery_update(delivery_person_id):
    if request.method == 'PUT':
        #dont update name and id
        skip_keys = ['name', 'nationalId']

        user_info = request.form.to_dict()
        try:
            latitude = user_info['latitude']
            longitude = user_info['longitude']
            cache.geoadd("delivery", longitude, latitude, delivery_person_id)
        except Exception:
            pass
        try:
            del user_info['latitude']
            del user_info['longitude']
        except KeyError:
            pass
        _profile = request.files.get("profile", None)
        if user_info is None:
            abort(400, "Update error")
        for key in skip_keys:
            try:
                user_info.pop(key)
            except KeyError as e:
                pass
        stmt = update(Delivery).values(user_info)\
                      .where(Delivery.id == delivery_person_id)
        if _profile:
            _img_url = '/home/hk/grocree/web-static/images/' + _profile.filename
            _profile.save(_img_url)

        try:
            storage.query(stmt)
            storage.save()
            return jsonify({200:"update sucessfull"})
        except IntegrityError as e:
            #violated column
            column = e.orig.__repr__().replace('"', " ").replace('\\', ' ').replace("'", " ")\
                 .replace('(', ' ').replace(')', ' ')\
                 .strip(' ').split(' ')[-1].split(".")[-1]
            #conflict
            return make_response(column, 409)

    #get delivery person + his/her orders
    delivery_personel = select(Delivery)\
                         .where(Delivery.id == delivery_person_id)
    delivery_person = storage.query(delivery_personel).first()
    if delivery_person is None:
        return make_response("not found", 404)
    delivery_person = delivery_person._data[0].to_dict()
    delivery_person.pop("updated_at")

    stmt = select(Order).where(Order.deliveryPersonId == delivery_person_id)
    rows = storage.query(stmt).fetchall()
    results = [i._data[0].to_dict() for i in rows]
    delivery_person_orders = {"deliveryPerson":delivery_person, "order":results}
    return make_response(jsonify(delivery_person_orders), 200)


#create customer account and/or
#view users
@app.route("/customers", methods=['POST', 'GET'], strict_slashes=False)
def create_ac():
    if request.method == 'POST':
        user = request.to_json()
        latitude = user_info.get("latitude", None)
        longitude = user_info.get("longitude", None)

        _user_img_profile = request.files.get('profile', None)
        if _user_img_profile:
            _profile = "/home/hk/grocree/web-static/images/" + _user_img_profile.filename
            _user_img_profile.save(_profile)
            user['imgURL'] = _profile
            _customer = Delivery(**user)
            try:
                cache.geoadd("customers", longitude, latitude, _delivery_personel.id)
            except Exception:
                pass
        storage.new(_customer)
        try:
            storage.save()
        except IntegrityError as e:
            #column violated
            column = e.orig.__repr__().replace('"', " ").replace('\\', ' ').replace("'", " ")\
                 .replace('(', ' ').replace(')', ' ')\
                 .strip(' ').split(' ')[-1].split(".")[-1]
            storage.rollback()
            #conflict
            return make_response(column, 409)
        return make_response(jsonify({"id": _delivery_personel.id}), 201)
    result_proxy = storage.query(select(Customer))
    rows = result_proxy.fetchall()
    result = [i._data[0].to_dict() for i in rows]
    return jsonify(result)


#get or update user info
@app.route("/customers/<user_id>", methods=["GET", 'PUT'], strict_slashes=False)
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

    stmt = select(Delivery.id, Delivery.username).where(
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
@app.route("/customers/<user_id>/orders", methods=['POST', 'GET'], strict_slashes=False)
def orders(user_id):
    if request.method == 'GET':
        stmt = select(Order).where(Order.customerId == user_id)
        result_proxy = storage.query(stmt)
        rows = result_proxy.fetchall()
        results = [i._data[0].to_dict() for i in rows]
        return jsonify(results)

    __info = {}
    __order = request.get_json()
    #get the closest store to dispatch product
    #cart items from diffrent close stores - centralise in closest and dispatch
    #store aim at ensuring same products -- all stores --cut costs
    #useful in bringin goods to buyers
    latitude, longitude = storage.query(select(Customer.latitude, Customer.longitude)\
                         .where(Customer.id == user_id)).first()
    #get closest store / inform to collect
    store_id = _close(latitude, longitude)
    delivery = get_delivery(store_id)
    an_order = Order(customerId=user_id, storeId=store_id, deliveryPersonId=delivery.id, orderStatus="pending")
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
    __info['DeliveryPerson'] = delivery.username
    __info['Time'] = an_order.created_at.isoformat().split('.')[0]
    __info['status'] = 'pending'
    return make_response(jsonify(__info), 201)

#track order
@app.route("/customers/<user_id>/orders/<order_id>",\
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
#customer login page
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


#delivery personel login
@app.route("/dlogin", methods=["GET"], strict_slashes=False)
def dlogin():
   stmt = select(Delivery.password, Delivery.imgURL, Delivery.id)\
            .where(Delivery.username == request.args.get('username'))
   _auth = storage.query(stmt).first()
   if _auth:
      if _auth[0] == request.args.get("password"):
          _user = {}
          _user['imgURL'] = _auth[1]
          _user['username'] = request.args.get("username")
          _user['id'] = _auth[2]

          return make_response(jsonify(_user), 200)
      else:
          abort(401, "unauthorized")
   return abort(404, "not found")

if __name__ == "__main__":
    app.run(host="0.0.0.0")
