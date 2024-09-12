#include <iostream>
#include <vector>
#include <fstream>
#include <algorithm>
#include <cmath>
#include "hash.h"
#include <bitset>
#include "utils.h"
using namespace std;
hash_entry::hash_entry(int key, int value) : key(key), value(value) {
    next = nullptr;
}
hash_bucket::hash_bucket(int hash_key, int depth) : hash_key(hash_key), local_depth(depth) {
    num_entries = 0;
    first = nullptr;
}
int H(int key, int depth) {
	return key & ((1 << depth) - 1);
}
int hash_bucket::other_index(){
    const int ss = 1 << (local_depth - 1); 
    const int v = hash_key ^ ss; 
    return v;
}
void hash_bucket::clear(){
    hash_entry* ptr = first;
    while (first != nullptr) {
        hash_entry* tmp = first;
        first = first -> next;
        delete tmp;
    }
}
hash_table::hash_table(int table_size, int bucket_size, int num_rows, const vector<int>& key, const vector<int>& value){
    this -> table_size = table_size;
    this -> bucket_size = bucket_size;
    this -> global_depth = 1;
    bucket_table = vector<hash_bucket*>(table_size);
    for (int i = 0; i < table_size; ++i)
        bucket_table[i] = new hash_bucket(i, 1);
    for (int i = 0; i < num_rows; ++i) 
        insert(key[i], value[i]);
}
/* When insert collide happened, it needs to do rehash and distribute the entries in the bucket.
** Furthermore, if the global depth equals to the local depth, you need to extend the table size.
*/
void hash_table::extend(hash_bucket* bucket) {
	if (global_depth == bucket -> local_depth) {
		int n = table_size;
        table_size *= 2;
        bucket_table.resize(table_size);
		global_depth++;
        for (int i = 0; i < n ; ++i)
            bucket_table[i + n] = bucket_table[i];
    }
	int depth = bucket -> local_depth;
	hash_bucket* new_bucket = new hash_bucket(H((1 << depth) + bucket -> hash_key, depth + 1), depth + 1);
	bucket -> local_depth++;
	hash_entry* current = bucket -> first;
	hash_entry* prev = nullptr;
	while (current != nullptr) {
		if (H(current -> key, bucket -> local_depth) != bucket -> hash_key) {
			if (prev == nullptr)
				bucket -> first = current -> next;
			else
				prev -> next = current -> next;
			bucket -> num_entries--;
			hash_entry* next_entry = current -> next;
			current -> next = new_bucket -> first;
			new_bucket -> first = current;
			new_bucket -> num_entries++;
			current = next_entry;
		}
		else {
			prev = current;
			current = current -> next;
		}
	}
    int n = 1 << bucket -> local_depth;
	for (int i = bucket -> hash_key + (1 << (bucket -> local_depth - 1)); i < table_size; i += n)
	    bucket_table[i] = new_bucket;
}
/* When construct hash_table you can call insert() in the for loop for each key-value pair.
*/
void hash_table::insert(int key, int value) {
	hash_bucket* bucket = bucket_table[key & ((1 << global_depth) - 1)];
	hash_entry* current = bucket -> first;
	while (current != nullptr) {
		if (current -> key == key) {
			current -> value = value; 
			return;
		}
		current = current -> next;
	}
	if (bucket -> num_entries == bucket_size) {
		extend(bucket);
		insert(key, value);
		return;
    }
	hash_entry* new_entry = new hash_entry(key, value);
	new_entry -> next = bucket -> first;
	bucket -> first = new_entry;
	bucket -> num_entries++;
}
/* The function might be called when shrink happened.
** Check whether the table necessory need the current size of table, or half the size of table
*/
void hash_table::half_table(){
    int n = bucket_table.size();
    for (int i = 0; i < n; ++i) {
        if (bucket_table[i] -> local_depth == global_depth) 
            return;
    }
    bucket_table.resize(bucket_table.size() / 2);
    global_depth--;
    half_table();
}
/* If a bucket with no entries, it need to check whether the pair hash index bucket 
** is in the same local depth. If true, then merge the two bucket and reassign all the 
** related hash index. Or, keep the bucket in the same local depth and wait until the bucket 
** with pair hash index comes to the same local depth.
*/
void hash_table::shrink(hash_bucket* bucket) {
    int idx = bucket -> hash_key;
    const int pair_index = bucket -> other_index();
    const int index_diff = 1 << (bucket -> local_depth);
    hash_bucket* pair_bucket = bucket_table[pair_index];
    if (pair_bucket -> local_depth == bucket -> local_depth) {
        pair_bucket -> local_depth--;
        bucket_table[idx] = pair_bucket;
        for (int i = idx - index_diff; i >= 0; i -= index_diff)
            bucket_table[i] = pair_bucket;
        const int dir_size = 1 << global_depth;
        for (int i = idx + index_diff; i < dir_size; i += index_diff)
            bucket_table[i] = pair_bucket;
    }
    if (pair_bucket -> num_entries == 0)
        shrink(pair_bucket);
    hash_bucket* another = bucket_table[pair_bucket -> other_index()];
    if (another -> num_entries == 0)
        shrink(another);
}
/* When executing remove_query you can call remove() in the for loop for each key.
*/
void hash_table::remove(int key){
    if (find(key) == nullptr)
        return;
    int n = bucket_table.size();
    hash_bucket* target = bucket_table[key & (n - 1)];
    if (target -> first -> key == key) {
        hash_entry* tmp = target -> first;
        target -> first = target -> first -> next;
        target -> num_entries--;
        delete tmp;
    }
    else {
        hash_entry* ptr = new hash_entry(0, 0);
        hash_entry* tmp = ptr;
        ptr -> next = target -> first;
        while (ptr -> next != nullptr && ptr -> next -> key != key) {
            ptr = ptr -> next;
        }
        if (ptr -> next != nullptr) {
            ptr -> next = ptr -> next -> next;
            target -> num_entries--;
        }
        delete tmp;
    }
    if (target -> num_entries == 0) 
        shrink(target);
    hash_bucket* pair_bucket = bucket_table[target -> other_index()];
    if (pair_bucket -> num_entries == 0)
        shrink(pair_bucket);
}
void hash_table::key_query(const vector<int>& query_keys, const string& file_name){
    ofstream file;
    file.open(file_name);
    for (int key : query_keys) {
        hash_entry* result = find(key);
        if (result == nullptr)
            file << -1 << ',' << bucket_table[key & (bucket_table.size() - 1)] -> local_depth << '\n';
        else
            file << result -> value << ',' << bucket_table[key & (bucket_table.size() - 1)] -> local_depth << '\n';
    }
}
void hash_table::remove_query(const vector<int>& query_keys){
    int n = query_keys.size();
    for (int i = 0; i < n; ++i)
        remove(query_keys[i]);
    half_table();
}
/* Free the memory that you have allocated in this program
*/
void hash_table::clear(){
    for (hash_bucket* bucket : bucket_table) {
        bucket -> clear();
    }
    bucket_table.clear();
}
hash_entry* hash_table::find(int key) {
    int n = bucket_table.size();
    hash_bucket* target = bucket_table[key & (n - 1)];
    hash_entry* ptr = target -> first;
    while (ptr && ptr -> key != key) 
        ptr = ptr -> next;
    return ptr;
}