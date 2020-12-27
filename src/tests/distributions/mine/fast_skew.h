#pragma once
#ifndef FAST_SKEW_H_
#define FAST_SKEW_H_

#include "../common.h"
#include "../rand.h"

#include <cmath>

namespace mine
{
	#include <stdint.h>
	float Q_rsqrt( float number )
	{	
		const float x2 = number * 0.5F;
		const float threehalfs = 1.5F;

		union {
			float f;
			uint32_t i;
		} conv  = { .f = number };
		conv.i  = 0x5f3759df - ( conv.i >> 1 );
		conv.f  *= threehalfs - ( x2 * conv.f * conv.f );
		return conv.f;
	}
	
	uint64_t next(double a, double b, double c, double M, Rand* r)
	{
	  /*assert(a >= 0);
	  assert(b < 0);
	  assert(c < 0);
	  
	  double d = -a/sqrt(-b);
	  assert(c > d);*/
	  
	  //Rand* rand_ = new Rand();
	  double u = r->next_f64();
	  //printf("counter_here: %lu\n", counter_here);
	  //u = (counter_here++)/100.0;
	  //printf("u: %f\n", u);
	  u *= b;
	  //printf("b*u: %f\n", u);
	  
	  double d = a/c;
	  //printf("a/c: %f\n", div);
	  d *= d;
	  /*printf("(a/c)^2: %f\n", div);
	  
	  printf("b*u+(a/c)^2: %f\n", u+div);
	  printf("1/sqrt(b*u+(a/c)^2): %f\n", Q_rsqrt(u+div));
	  printf("a/sqrt(b*u+(a/c)^2): %f\n", a*Q_rsqrt(u+div));
	  printf("c + a/sqrt(b*u+(a/c)^2): %f\n", c+a*Q_rsqrt(u+div));
	  
	  
	  printf("M: %f\n", M);
	  printf("(M*b*c*c*c)/(2*a*a): %f\n", (M*b*c*c*c)/(2*a*a));
	  //(2*a*a)/(b*c*c*c)
	  
	  //printf("double: %f\n", 100*(c+a*Q_rsqrt(u+div)));
	  
	  printf("%f\n", (((M*b*c*c*c)/(2*a*a))*(c+a*Q_rsqrt(u+div))));
	  printf("%ld\n",(uint64_t)(((M*b*c*c*c)/(2*a*a))*(c+a*Q_rsqrt(u+div))));
	  
	  printf("\n");*/
	  return (uint64_t)(((M*b*c*c*c)/(2*a*a))*(c+a*Q_rsqrt(u+d)));
	  //return (uint64_t)(c+a*Q_rsqrt(u+div)); 
	}
	
	//next 1
	const float a1 = 0.33;
	const float b1 = -1.47;
	const float c1 = -0.272179;
	const float d1 = 1.47000445699;
	const float M1 = (1 << 26);
	const float sum1 = 621438.007967;
	const float factor1 = 753454.684708;
	uint64_t next1(Rand* r)
	{
	  float u = r->next_f64();
	  u *= b1;
	  
	  //return (uint64_t)((c1+a1*Q_rsqrt(u+div1)));
	  //return (uint64_t)(factor1*(c1+a1*Q_rsqrt(u+div1)));
	  return (uint64_t)(sum1+factor1*Q_rsqrt(u+d1));
	}
	
	//next 2
	const float a2 = 60.6;
	const float b2 = -1;
	const float c2 = -22.8;
	const float d2 = 7.06440443213;
	const float M2 = (1 << 26);
	const float sum2 = -617282606.71;
	const float factor2 = 1.6406721915E9;
	uint64_t next2(Rand* r)
	{
	  float u = r->next_f64();
	  u *= b2;
	  
	  //return (uint64_t)((c1+a1*Q_rsqrt(u+div1)));
	  //return (uint64_t)(factor1*(c1+a1*Q_rsqrt(u+div1)));
	  
	  //printf("%f\n", sum2+factor2*Q_rsqrt(u+d2));
	  //printf("%lu\n",(uint64_t)(sum2+factor2*Q_rsqrt(u+d2)));
	  return (uint64_t)(sum2+factor2*Q_rsqrt(u+d2));
	}
}


#endif
