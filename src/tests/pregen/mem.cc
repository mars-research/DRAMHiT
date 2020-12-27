// #pragma once
#ifndef MEM_CC_
#define MEM_CC_

#include <cassert>
#include <cstdio>
#include <cmath>
#include <sys/mman.h>
#include <unistd.h>

/*#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>*/

#define NONE 0
#define MICA 1
#define STCKOVRFLW 2
#define TOOBIASED 3

//#define MEM
#define MMAP
#define HUGEPAGES
//#define FILE_MMAP
#define HEADER STCKOVRFLW//MICA//TOOBIASED//

#ifndef HEADER
	#include "../distributions/zipf.h"
#elif HEADER == MICA
	#include "../distributions/mica/zipf.h"
#elif HEADER == STCKOVRFLW
	#include "../distributions/stackoverflow/zipf.h"
#elif HEADER == TOOBIASED
	#include "../distributions/toobiased/zipf.h"
#endif

#ifdef HUGEPAGES
	#define PG_SIZE (getpagesize()*512)
#else
	#define PG_SIZE (getpagesize())
#endif


uint64_t* generate(uint64_t num, uint64_t range, double theta, uint64_t seed)
{
  	#if defined(MEM)
		uint64_t* data = new uint64_t[num];
	#elif defined(MMAP) || defined(FILE_MMAP)
		#ifdef FILE_MMAP
			int fd = open("test", O_RDWR|O_CREAT, S_IRWXU);
			if (fd == -1)
			{
				perror("Opening file Failed.");
				return NULL;
			}
			++num;
		#endif
		size_t pagesize = PG_SIZE;

		uint64_t num_pages = (((++num)*sizeof(uint64_t))/pagesize)+1;
		uint64_t* data = (uint64_t*) mmap(
			(void*) (pagesize * (1 << 20)),   // Map from the start of the 2^20th page
			num_pages*pagesize,                         // for one page length
			PROT_READ|PROT_WRITE,//|PROT_EXEC,
			MAP_ANON|MAP_PRIVATE
			#ifdef HUGEPAGES
				|MAP_HUGETLB
			#endif
			,             // to a private block of hardware memory
			0
			#ifdef FILE_MMAP
				|fd
			#endif
			,
			0);
		if(data == MAP_FAILED)
		{
			perror("Map Failed.");
			#ifdef FILE_MMAP
				int result = close(fd);
				if(result!=0)
				{
					perror("Could not close file");
					return NULL;
				}
			#endif
			return NULL;
		}
		data[0] = num_pages*pagesize;
		++data;
		#ifdef FILE_MMAP
			data[0] = fd;
			++data;
		#endif
	#endif

	//data[0] =  1+(1<<12);//num;
  	//ZipfGen* zg = new 
	ZipfGen(range, theta, seed);
	//Base_ZipfGen* zg = ZipfGen(range, theta, seed);
	for(uint64_t i=0; i<num;++i)
	{
		//seed = zg->next();
    	data[i] = next();//ZipfGen2(range, theta, seed); //seed;
	}
	
	//delete zg;
  	return data;
}

int clear(uint64_t* data)
{
	#if defined(MEM)
		delete[] data;
	#elif defined(MMAP) || defined(FILE_MMAP)
		#ifdef FILE_MMAP
			uint64_t fd = data[-1];
			int result = munmap(data-2, data[-2]);
		#else
			int result = munmap(data-1, data[-1]);
		#endif
		if(result != 0) 
		{
			perror("Could not munmap");
			#ifdef FILE_MMAP
				result = close(fd);
				if(result!=0)
				{
					perror("Could not close file");
					return 1;
				}
			#endif
			return 1;
		}
		#ifdef FILE_MMAP
			result = close(fd);
			if(result!=0)
			{
				perror("Could not close file");
				return 1;
			}
		#endif
	#endif
  return 0;
}


#endif
