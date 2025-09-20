/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

// Based on the following Java implementation:
// https://github.com/apache/commons-statistics/blob/master/commons-statistics-distribution/src/main/java/org/apache/commons/statistics/distribution/ZipfDistribution.java
// https://github.com/apache/commons-rng/blob/master/commons-rng-sampling/src/main/java/org/apache/commons/rng/sampling/distribution/RejectionInversionZipfSampler.java

#ifndef ZIPF_DISTRIBUTION_HPP_
#define ZIPF_DISTRIBUTION_HPP_

#include <stdexcept>
#include <vector>
#include <random>
#include <algorithm>
#include <stdexcept>
#include <cstdint>

namespace kmercounter {

class zipf_distribution_apache {
public:
  zipf_distribution_apache(uint64_t num_elements, double exponent, int64_t seed = 0xdeadbeef);
  uint64_t sample();
private:
  static constexpr double TAYLOR_THRESHOLD = 1e-8;
  static constexpr double F_1_2 = 0.5;
  static constexpr double F_1_3 = 1.0 / 3.0;
  static constexpr double F_1_4 = 0.25;

  const uint64_t num_elements;
  const double exponent;
  const double h_integral_x1;
  const double h_integral_num_elements;
  const double s;

  std::mt19937_64 generator;
  std::uniform_real_distribution<double> distribution;

  double h(double x);
  double h_integral(double x);
  double h_integral_inverse(double x);

  static double helper1(double x);
  static double helper2(double x);
};


class zipf_distribution_sync {
public:
    // Constructor: n = number of elements, s = exponent, max_threads, optional seed
    zipf_distribution_sync(uint64_t num_elements, double exponent, size_t max_threads, int64_t seed = 0xdeadbeef)
        : n(num_elements), s(exponent), cdf(num_elements)
    {
        if (n == 0) throw std::invalid_argument("num_elements must be > 0");
        if (s <= 0.0) throw std::invalid_argument("exponent must be > 0");
        if (max_threads == 0) throw std::invalid_argument("max_threads must be > 0");

        // Compute normalization constant and CDF
        double sum = 0.0;
        for (uint64_t k = 1; k <= n; ++k) {
            sum += 1.0 / std::pow(k, s);
        }

        double cumulative = 0.0;
        for (uint64_t k = 1; k <= n; ++k) {
            cumulative += 1.0 / std::pow(k, s) / sum;
            cdf[k-1] = cumulative;
        }

        // Initialize per-thread RNGs
        rngs.resize(max_threads);
        for (size_t i = 0; i < max_threads; ++i) {
            rngs[i].seed(seed + i);
        }
    }

    // Thread-safe sampling: provide thread_id (0..max_threads-1)
    uint64_t sample(size_t thread_id) {
        if (thread_id >= rngs.size()) {
            throw std::out_of_range("thread_id out of range");
        }

        std::uniform_real_distribution<double> dist(0.0, 1.0);
        double u = dist(rngs[thread_id]);

        // Binary search in CDF
        auto it = std::lower_bound(cdf.begin(), cdf.end(), u);
        return std::distance(cdf.begin(), it); // returns index [0, n-1]
    }

private:
    uint64_t n;
    double s;
    std::vector<double> cdf;
    std::vector<std::mt19937_64> rngs; // one RNG per thread
};

}

#endif
