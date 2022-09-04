#!/bin/python 

"""
    Install deps:
    pip3 install locust
"""

import time
import string
import random
from locust import HttpUser, task, between




class User(HttpUser):

    @task
    def health_check(self):
        self.client.get('/health')

    @task
    def create_account(self):
        size = 7
        str = ''.join(random.choices(string.ascii_uppercase + string.digits, k=size))

        print(f'[+] Creating account: {str}')

        self.client.post('/api/account', {
            'email': f'{str}@email.com',
            'password': str,
            'is_admin': False,
            'name': str,
        })

    @task
    def list_accounts(self):
        self.client.get('/api/account')

    def on_start(self):
        self.client.post('/api/login', {
            'email': 'sheev.palpatine@naboo.net',
            'password': 'sidious',
            })


