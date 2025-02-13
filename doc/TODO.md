
- [] Inline methods 
It seems like compiler has a hard time optimize method that is inlined.
Perhapes a rewrite of find methods or deletion of inline keywords to see the performance.
- [] Multilevel hashtable fairness (make multilevel hashtable use same memory).
We need to make sure multilevel hashtable uses same amount of memory as specified.
- [] new prefetch engine 
Implement a simpler prefetch engine

```

prev_item = batch[0];
prefetch(prev_item);

flush_queue_until_batch_size(); // ensure queue has enough space for new batch.

for item in batch {
    prefetch(item);
    do_op(prev_item);
    prev_item = item;
}

```



