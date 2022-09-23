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

Currently (0.3.0), we can create Domain objects through our REST api (using controllers and stuff, you know the drill), and through GraphQL. The point of this benchmarks is to call both methods to see which one works the best for us.

Here is our locust test file:
```python

```

