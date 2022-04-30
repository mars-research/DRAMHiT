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

#include <stdexcept>
#include <random>
#include <chrono>
#include <cmath>

#include "zipf_distribution.hpp"

namespace kmercounter {

zipf_distribution_apache::zipf_distribution_apache(unsigned num_elements, double exponent):
num_elements(num_elements),
exponent(exponent),
h_integral_x1(h_integral(1.5) - 1),
h_integral_num_elements(h_integral(num_elements + F_1_2)),
s(2 - h_integral_inverse(h_integral(2.5) - h(2))),
generator(std::chrono::system_clock::now().time_since_epoch().count()),
distribution(0, 1)
{
  if (exponent <= 0) throw std::invalid_argument("exponent must be positive");
}

unsigned zipf_distribution_apache::sample() {
  while (true) {
    const double u = h_integral_num_elements + distribution(generator) * (h_integral_x1 - h_integral_num_elements);
    double x = h_integral_inverse(u);
    unsigned k = x + F_1_2;
    if (k < 1) {
      k = 1;
    } else if (k > num_elements) {
      k = num_elements;
    }
    if (k - x <= s || u >= h_integral(k + F_1_2) - h(k)) {
      return k;
    }
  }
}

double zipf_distribution_apache::h(double x) {
  return exp(-exponent * log(x));
}

double zipf_distribution_apache::h_integral(double x) {
  const double log_x = log(x);
  return helper2((1 - exponent) * log_x) * log_x;
}

double zipf_distribution_apache::h_integral_inverse(double x) {
  double t = x * (1 - exponent);
  if (t < -1) {
    t = -1;
  }
  return exp(helper1(t) * x);
}

double zipf_distribution_apache::helper1(double x) {
  if (abs(x) > TAYLOR_THRESHOLD) {
      return log1p(x) / x;
  } else {
      return 1 - x * (F_1_2 - x * (F_1_3 - F_1_4 * x));
  }
}

double zipf_distribution_apache::helper2(double x) {
  if (abs(x) > TAYLOR_THRESHOLD) {
    return expm1(x) / x;
  } else {
    return 1 + x * F_1_2 * (1 + x * F_1_3 * (1 + F_1_4 * x));
  }
}

}
