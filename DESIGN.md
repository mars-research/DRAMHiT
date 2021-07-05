
### Components
----

#### Pipeline

```
 ==============       ==============       ================
| Distribution | --> |   Dataset    | --> |  Hashtables    |
|______________|     |______________|     |________________|
```


* **Probability distributions**: We require probability distributions to test our
  hashtable. Uniform distribution represents a normal workload, whereas Zipfian
  models the realworld workload where there is a skew (large fraction of requests
  come for a small fraction of keys).
	- Uniform (Monotonically incrementing counter)
	- Zipfian (Borrow from gh/efficient/mica2 or abseil)

* **Data generator**: Data generator feeds data to the pipeline based on the
  requested distribution. For e.g., YCSB dataset consists of urls (keys) and
  visits (values). We initialize a distribution and draw a sample and feed the
  data at that index.

* **Hashtables**: The data is fed into the hash table. We compare against two
  hashtables (cas and cas++). The hashtables take two template parameters (for
  Queue and the <k,v> data structure). The KVQ need not be templatized as it is
  almost similar across different <k,v> types
  	- CAS (compare and swap)
  	- CASHT++ (compare and swap with prefetch queue)
  	- KVStore (partitioned hashtable with prefetch)

* **Threading**: The application should spawn a set of reader/writer threads for
  managing get/set requests. As the incoming requests could be skewed, we need
  to dynamically scale the number of readers/writers up or down based on the
  requirement. The design details of such scaling needs to be discussed.

* **Workload**
	- YCSB (https://github.com/brianfrankcooper/YCSB)
