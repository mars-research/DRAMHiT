#ifndef HASHTABLES_ALL_HPP
#define HASHTABLES_ALL_HPP

#include "hashtables/base_kht.hpp"
#include "hashtables/array_kht.hpp"
#include "hashtables/cas23_kht.hpp"
#include "hashtables/cas_kht.hpp"

#ifdef GROWT
#include "hashtables/growt_kht.hpp"
#include "hashtables/tbb_kht.hpp"
#endif

#ifdef CLHT
#include "hashtables/clht_kht.hpp"
#endif

#ifdef PART_ID
#include "hashtables/multi_kht.hpp"
#include "hashtables/simple_kht.hpp"
#endif

#endif
