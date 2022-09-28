#!/bin/python

"""
    Install deps:
    pip3 install -U locust
"""

import json
import string
import random
from locust import HttpUser, task




class User(HttpUser):
    @task
    def create_domain_GRAPHQL(self):

        auth_header = {
                'Authorization': f'Bearer {self.token}'
        }

        query = """
            mutation CreateSimpleAddress(
                $city: String!,
                $country: String!,
                $country_code: String!,
                $postcode: String!,
                $state: String!,
                $state_district: String!
            ) {
            createAddress(
                city: $city,
                country: $country,
                countryCode: $country_code,
                postcode: $postcode,
                state: $state,
                stateDistrict: $state_district
            ) {
                id
                city
                country
                state
            }
        }
        """

        variables = """
                {
                "city": "Paris",
                "country": "France",
                "country_code": "FR",
                "postcode": "75019",
                "state": "something",
                "state_district": "Paris"
                }
                """.replace('\n \t', ' ')

        resp = self.client.post("/graphql", data={
            "query": query,
            "variables": variables
            }, headers=auth_header)

        as_json = json.loads(resp.text)
        id = as_json["data"]["createAddress"]["id"]

        query = """
            mutation CreateSimpleNode(
                $addr: ID!,
                $latitude: String!,
                $longitude: String!,
                $name: String!,
            ) {
                createNode(
                    addrId: $addr,
                    latitude: $latitude,
                    longitude: $longitude,
                    name: $name,
                ) {
                    id
                    latitude
                    longitude
                }
                }
            """.replace('\n \t', ' ')

        variables = """{
            "addr": "id",
            "name": "something cool",
            "longitude": "some longitude",
            "latitude": "some latitude"
        }""".replace('\t \n', ' ').replace('id', id)

        resp = self.client.post("/graphql", data={
            "query": query,
            "variables": variables
            }, headers=auth_header)


    @task
    def create_domain_REST(self):
        payload = {
            "address": {
                "city": "Paris",
                "country": "France",
                "country_code": "FR",
                "postcode": "75019",
                "state": "Something",
                "state_district": "Paris"
            }
        }

        auth_header = {
                'Authorization': f'Bearer {self.token}'
        }

        response = self.client.post('/api/address', json=payload, headers=auth_header)

        as_json = json.loads(response.text)
        addr_id = as_json["data"]["id"]

        payload = {
            'node': {
                'addr_id': f'{addr_id}',
                'name': 'something',
                'longitude': 'some longitude',
                'latitude': 'some latitude'
            }
        }

        self.client.post('/api/node', json=payload, headers=auth_header)


    def on_start(self):
        size = 7
        str = ''.join(random.choices(string.ascii_uppercase + string.digits, k=size))

        self.email = f'{str}@email.com'

        gql_query = """
            mutation CreateSimpleAccount(
                $e: String!,
                $n: String!,
                $p: String!,
                $i: String!,
            ) {
                createAccount(email: $e, name: $n, password:$p, isAdmin:$i) {
                    id,
                }
            }
            """.replace('\n \t', ' ')


        gql_vars =  """
                        {
                            "e": "email",
                            "n": "name",
                            "p": "sidious",
                            "i": "false"
                        }
                    """.replace('\n\t ', ' ').replace('email', self.email).replace('name', str)


        resp = self.client.post("/graphql", data={
            "query": gql_query,
            "variables": gql_vars
            })

        response = self.client.post('/api/login', data={
            "email": self.email,
            "password": "sidious",
        })

        as_json = json.loads(response.text)
        self.token = as_json.get('jwt')


