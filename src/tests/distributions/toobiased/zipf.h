/*******************************************************************************
 * utils/hashfct.h
 *
 * Zipf distributed key generation -- using an explicitly computed probability
 * distribution and a binary search
 *
 * Part of Project growt - https://github.com/TooBiased/growt.git
 *
 * Copyright (C) 2015-2016 Tobias Maier <t.maier@kit.edu>
 *
 * All rights reserved. Published under the BSD-2 license in the LICENSE file.
 ******************************************************************************/

#warning first here!

#ifndef ZIPF_H_
#define ZIPF_H_

#include <math.h>
#include <atomic>

#include "../rand.h"
#include "../common.h"



struct run_once
{
    template <typename T>
    run_once(const T&& lambda)
    {
        lambda();
    }
};

static double* precomp = nullptr;
static Rand r;
static uint64_t universe;
//static atomic_bool precomp_done(false);
inline void ZipfGen(uint64_t uni, double exp, uint64_t seed)
{
    //static atomic_bool precomp_done(false);
    //static double*          precomp(nullptr);
    universe = uni;
    static run_once a([uni, exp]()
        {
            precomp = new double[uni+1];
            precomp[0] = 0.;
            auto temp  = 0.;
            for (uint i = 1; i <= uni; ++i)
            {
                temp += 1./pow(i,exp);
                precomp[i] = temp;
            }
            //precomp_done.store(true, memory_order_release);
        });
    r = Rand(seed);
    //while (!precomp_done.load(memory_order_acquire));
}

uint64_t next()
{
    //CMD = Hks/Hns
    auto t_p = r.next_f64() * precomp[universe];
               // ADAPTED PROBABILITY BECAUSE THE ARRAY IS PRECOMP IS NOT NORMED


    //  SPECIAL TREATMENT FOR FIRST FEW POSSIBLE KEYS
    for(size_t i = 1; i < 8; ++i)
    {
        if (precomp[i] > t_p) return i-1;
    }

    //  BINARY SEARCH METHOD
    size_t l = 0;
    size_t r = universe;

    while (l < r-1)
    {
        size_t m = (r+l)/2;    //               |            -------/
        if (precomp[m] > t_p)  // Hks(m,s)  t_p |======o----/
        {                      //               |   --/|
            r = m;             //               |  /   |
        }                      //               | /    |
        else                   //               |/_____|________________
        {                      //                l    ret   m         r
            l = m;
        }
    }

    return l;
}

/*struct run_once
{
    template <typename T>
    run_once(const T&& lambda)
    {
        lambda();
    }
};

inline size_t ZipfGen(uint universe, double exp, double prob)
{
    static atomic_bool precomp_done(false);
    static double*          precomp(nullptr);

    static run_once a([universe, exp]()
        {
            precomp = new double[universe+1];
            precomp[0] = 0.;
            auto temp  = 0.;
            for (uint i = 1; i <= universe; ++i)
            {
                temp += 1./pow(i,exp);
                precomp[i] = temp;
            }
            precomp_done.store(true, memory_order_release);
        });

    while (!precomp_done.load(memory_order_acquire));

    //CMD = Hks/Hns
    auto t_p = prob * precomp[universe];
               // ADAPTED PROBABILITY BECAUSE THE ARRAY IS PRECOMP IS NOT NORMED


    //  SPECIAL TREATMENT FOR FIRST FEW POSSIBLE KEYS
    for (size_t i = 1; i < 8; ++i)
    {
        if (precomp[i] > t_p) return i-1;
    }

    //  BINARY SEARCH METHOD
    size_t l = 0;
    size_t r = universe;

    while (l < r-1)
    {
        size_t m = (r+l)/2;    //               |            -------/
        if (precomp[m] > t_p)  // Hks(m,s)  t_p |======o----/
        {                      //               |   --/|
            r = m;             //               |  /   |
        }                      //               | /    |
        else                   //               |/_____|________________
        {                      //                l    ret   m         r
            l = m;
        }
    }

    return l;

}*/

#endif // KEYGEN_H