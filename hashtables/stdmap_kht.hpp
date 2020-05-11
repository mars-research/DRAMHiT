#ifndef _STDMAP_KHT_H
#define _STDMAP_KHT_H

#include "../include/base_kht.hpp"
#include "data_types.h"
// #include "kmer_struct.h"
#include "kmer_class.h"

class StdmapKmerHashTable : public KmerHashTable
{
  std::unordered_map<Kmer, Kmer_value_t, Kmer_hash, Kmer_equal> std_kmer_umap;

  StdmapKmerHashTable(uint64_t c)
  {
    /* One element per bucket */
    std_kmer_umap.max_load_factor(1);
  }

  ~StdmapKmerHashTable() { free(std_kmer_umap); }

  /* insert and increment if exists */
  bool insert(const void *kmer_data)
  {
    Kmer kmer(kmer_data, KMER_DATA_LENGTH);
    Kmer_value_t val;
    auto it =
        this->stdu_kmer_ht.insert(std::pair<Kmer, Kmer_value_t>(kmer, val));
    if (!it.second)
    {
      (it.first)->second.counter++;
    }
    return true;
  }

  void flush_queue() { return; }

  /* TODO */
  //   Kmer_r *find(const void *kmer_data)
  //   {}

  void display()
  {
    for (auto it = this->std_kmer_umap.begin(); it != this->std_kmer_umap.end();
         ++it)
    {
      std::cout << it->first << " : " << it->second << std::endl;
    }
  }

  size_t get_fill() { return this->std_kmer_umap.size(); }

  size_t get_capacity()
  {
    return (size_t)this->std_kmer_umap.size() /
           this->std_kmer_umap.load_factor();
  }

  size_t get_max_count()
  {
    size_t count = 0;
    for (auto it = this->std_kmer_umap.begin(); it != this->std_kmer_umap.end();
         ++it)
    {
      std::cout << it->first << " : " << it->second << std::endl;
      if (it->second > count) count = it->second;
    }
    return count;
  }

  void print_to_file(std::string outfile)
  {
    std::ofstream f;
    f.open(outfile);
    for (size_t i = 0; i < this->get_capacity(); i++)
    {
      if (this->hashtable[i].kmer_count > 0)
      {
        f << this->hashtable[i] << std::endl;
      }
    }
  }
};

// TODO bloom filters for high frequency kmers?

#endif /* _STDMAP_KHT_H */
