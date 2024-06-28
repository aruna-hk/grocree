#!/usr/bin/python3
######################################################
####GREEN UNICORN WSGI CONFIG########################

#import eventlet
bind = 'localhost:8080'
workers = 3
#worker_class = 'eventlet' #gevent, sync, tornado
#access/error log
accesslog = '/home/hk/grocree/access.log'
errorlog =  '/home/hk/grocree/error.log'
#request timeout
timeout = 60 #one minute
