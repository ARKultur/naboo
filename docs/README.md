# naboo notes and documentation

## Who is this for ?

This directory is meant as a notes repository, with benchmarks and areas of research for future work.
You can find various subjects here, documented as well as time allowed us.

Please enhance this documentation when you have the opportunity to do so.

## Compiled queries on Absinthe

GraphQL is quite popular and powerful. We want to measure GraphQL query/mutation performance and see if there are bits of code that we can improve. We also want to understand if it is useful to _compile_ a query.

Results shall be saved in this file. The code used to run those benchmarks could be made into a CI test suite.

### testing method

Since I am currently using Windows (with WSL when I need), I will build a [python script](./load_tests.py) that should run and time HTTP queries against the server.


#### Running Locust

You can run this by installing the [Locust](https://docs.locust.io/en/stable/quickstart.html) package.
Then, type `envup .env.dev && make run` in one terminal and `cd docs/ && python -m locust` in another

You can then go to `localhost:8089` to access the Locust interface.

> if you're using WSL, type `wsl hostname -I` in a Powershell shell to get the local address
> of your WSL instance

The code is available here as well for posterity:
```python
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

```

I decided to test account creation, as it seemed to be a query that would be frequent enough.

    -> Results for [queries not compiled](./absinthe-benchmarks/uncompiled.csv)

    -> Results for [queries compiled](./absinthe-benchmarks/compiled.csv)

### Conclusion

Currently, it does not seem that this techniques affects performance that much. Maybe we could use it later for readability; currently, it is not useful to implement it.


## Benchmarking GraphQL queries vs REST for creating and listing domains

Currently (0.3.0), we can create Domain objects through our REST api
(using controllers and stuff, you know the drill), and through GraphQL.
The point of this benchmarks is to call both methods to see which one works the best for us.

Here is our locust test file:
```python
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

```

You can find the configuration used for the tests [here](./rest-gql-benchmarks/load_tests_params.PNG)

The final [results](./rest-gql-benchmarks/final_report.html) suggest that GraphQL requests may be slower for us, but in all fairness it is not really a fair comparaison as GraphQL requests are better suited for nested queries.

We should revisit this topic once we have a better understanding of how GraphQL requests are handled and when a user can "own" domains.

I'm thinking of using graphql for importing such properties because you can have queries running concurrently, which may be good for us.
Also, we don't have Nested Fields implemented in GQL yet, which may give it an advantage.
