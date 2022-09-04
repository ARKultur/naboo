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

I decided to test account creation, as it seemed to be a query that would be frequent enough. 
    -> Results for [queries not compiled](./absinthe-benchmarks/uncompiled.csv)
    -> Results for [queries compiled](./absinthe-benchmarks/compiled.csv)

### Conclusion

Currently, it does not seem that this techniques affects performance that much. Maybe we could use it later for readability; currently, it is not useful to implement it.
