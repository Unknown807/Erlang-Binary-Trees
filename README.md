# Erlang-Binary-Trees

Trees and nodes are interchangeable here. Nodes have a key and a value, the value can be anything, but the key is what is important for inserting and organising the tree.

Since each node (even empty ones) are processes, they have a set of protocols which they wait for, receive and then act accordingly:
- {is_empty, PID} -> sends 'true' or 'false', returns nothing
- {get, K, PID} -> sends {just, V} or 'nothing'
- {put, K, V, PID} -> sends 'done'
- {fold, FE, FB, PID} -> sends '{folded, FB(LV, KK, VV, RV), self()}', where self() is the PID of the process and LV, RV are the values of the node's left and right subtree respectively


Example tree below:

![](/img.PNG)
