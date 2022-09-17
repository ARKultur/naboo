#!/bin/python

"""
    Install deps:
    pip3 install -U locust
"""

import time
import string
import random
from locust import HttpUser, task




class User(HttpUser):

    @task
    def create_domain_REST(self):



      @task
    def list_accounts(self):
        self.client.get('/api/account')

    def on_start(self):
        self.client.post('/api/login', {
            'email': 'sheev.palpatine@naboo.net',
            'password': 'sidious',
            })


