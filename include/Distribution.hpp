#pragma once

class Distribution {
	virtual uint64_t sample() = 0;
};

class alignas(128) ZipfDistribution : Distribution {
	public:
	ZipfDistribution(uint64_t n, double theta, uint64_t rand_seed);

	uint64_t sample();

	private:
  	static double pow_approx(double a, double b);

	static double zeta(uint64_t last_n, double last_sum, uint64_t n,
                     double theta);

	uint64_t n_;  // number of items (input)
	double theta_;  // skewness (input) in (0, 1); or, 0 = uniform, 1 = always zero
	double alpha_;     // only depends on theta
	double thres_;     // only depends on theta
	uint64_t last_n_;  // last n used to calculate the following
	double dbl_n_;
	double zetan_;
	double eta_;
	uint64_t seq_;  // for sequential number generation
	Rand rand_;
}

double ZipfDistribution::zeta(uint64_t last_n, double last_sum, uint64_t n,
                     double theta) {
  if (last_n > n) {
    last_n = 0;
    last_sum = 0.;
  }
  while (last_n < n) {
    last_sum += 1. / pow_approx((double)last_n + 1., theta);
    last_n++;
  }
  return last_sum;
}

double ZipfGen::pow_approx(double a, double b) {
  // from
  // http://martin.ankerl.com/2012/01/25/optimized-approximative-pow-in-c-and-cpp/

  // calculate approximation with fraction of the exponent
  int e = (int)b;
  union {
    double d;
    int x[2];
  } u = {a};
  u.x[1] = (int)((b - (double)e) * (double)(u.x[1] - 1072632447) + 1072632447.);
  u.x[0] = 0;

  // exponentiation by squaring with the exponent's integer part
  // double r = u.d makes everything much slower, not sure why
  // TODO: use popcount?
  double r = 1.;
  while (e) {
    if (e & 1) r *= a;
    a *= a;
    e >>= 1;
  }

  return r * u.d;
}

ZipfDistribution::ZipfDistribution(uint64_t n, double theta, uint64_t rand_seed) {
  assert(n > 0);
  if (theta > 0.992 && theta < 1)
    fprintf(stderr,
            "warning: theta > 0.992 will be inaccurate due to approximation\n");
  if (theta >= 1. && theta < 40.) {
    fprintf(stderr, "error: theta in [1., 40.) is not supported\n");
    assert(false);
    theta_ = 0;  // unused
    alpha_ = 0;  // unused
    thres_ = 0;  // unused
    return;
  }
  assert(theta == -1. || (theta >= 0. && theta < 1.) || theta >= 40.);
  n_ = n;
  theta_ = theta;
  if (theta == -1.) {
    seq_ = rand_seed % n;
    alpha_ = 0;  // unused
    thres_ = 0;  // unused
  } else if (theta > 0. && theta < 1.) {
    seq_ = 0;  // unused
    alpha_ = 1. / (1. - theta);
    thres_ = 1. + pow_approx(0.5, theta);
  } else {
    seq_ = 0;     // unused
    alpha_ = 0.;  // unused
    thres_ = 0.;  // unused
  }
  last_n_ = 0;
  zetan_ = 0.;
  eta_ = 0;
  // rand_state_[0] = (unsigned short)(rand_seed >> 0);
  // rand_state_[1] = (unsigned short)(rand_seed >> 16);
  // rand_state_[2] = (unsigned short)(rand_seed >> 32);
  rand_ = Rand(rand_seed);
}

uint64_t ZipfGen::next() {
  if (last_n_ != n_) {
    if (theta_ > 0. && theta_ < 1.) {
      zetan_ = zeta(last_n_, zetan_, n_, theta_);
      eta_ = (1. - pow_approx(2. / (double)n_, 1. - theta_)) /
             (1. - zeta(0, 0., 2, theta_) / zetan_);
    }
    last_n_ = n_;
    dbl_n_ = (double)n_;
  }

  if (theta_ == -1.) {
    uint64_t v = seq_;
    if (++seq_ >= n_) seq_ = 0;
    return v;
  } else if (theta_ == 0.) {
    double u = rand_.next_f64();
    return (uint64_t)(dbl_n_ * u);
  } else if (theta_ >= 40.) {
    return 0UL;
  } else {
    // from J. Gray et al. Quickly generating billion-record synthetic
    // databases. In SIGMOD, 1994.

    // double u = erand48(rand_state_);
    double u = rand_.next_f64();
    double uz = u * zetan_;
    if (uz < 1.)
      return 0UL;
    else if (uz < thres_)
      return 1UL;
    else {
      uint64_t v =
          (uint64_t)(dbl_n_ * pow_approx(eta_ * (u - 1.) + 1., alpha_));
      if (v >= n_) v = n_ - 1;
      return v;
    }
  }
}
// This is just a monotonically incrementing sequence
class UniformDistribution : Distribution {
	public:
	UniformDistribution(uint64_t min, uint64_t max) :
		range_min(min), range_max(max)
	{
		this->sequence = min;
	}

	uint64_t sample() {
		return this->sequence++;
	}
	private:
	uint64_t sequence;
	uint64_t range_min;
	uint64_t range_max;
};
