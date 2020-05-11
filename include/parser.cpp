
#include <pthread.h>


int spawn_threads(uint32_t num_threads, std::string f)
{
  // get size of FASTA file to be read
  long f_sz = get_file_size(f);
  // divide file size by number of threads
  long seg_sz = get_seg_size(f_sz, num_threads);

  // Since the kseq library reads in chunks of 4096 bytes (one page), each
  // thread must be responsible to parse atleast 4096 bytes
  if (seg_sz < 4096)
  {
    seg_sz = 4096;
  }

  cpu_set_t cpuset;
  pthread_t threads[num_threads];
  struct thread_data td[num_threads];

  int rc;
  int threads_spawned = num_threads;
  for (unsigned int i = 0; i < num_threads; i++)
  {
    /*
    The starting and ending locations for the memory segment that the thread is
    responsible for must be multiples of 4096 round_up will round number up to
    nearest multiple of 4096 Ex: Filesize = 10000, two threads to parse. Before
    rounding: t1.start = 0, t1.end = 5000, t2.start = 5000, t2.end = 10000 After
    rounding: t1.start = 0, t1.end = 8192, t2.start = 8192, t2.end = 12228
    */

    td[i].start = round_up(seg_sz * i, pgsize);
    td[i].end = round_up(seg_sz * (i + 1), pgsize);

    // Breaks thread spawn loop if starting location of thread is past file
    // size, saves how many threads are spawned into threads_spawned
    if (td[i].start >= f_sz)
    {
      threads_spawned = i;
      break;
    }

    td[i].thread_id = i;
    td[i].fname = f;
    rc = pthread_create(&threads[i], NULL, parse_thread, (void *)&td[i]);

    if (rc)
    {
      std::cout << "ERROR" << rc << std::endl;
      exit(-1);
    }

    CPU_ZERO(&cpuset);

#ifndef NDEBUG
    printf("[INFO] thread: %lu, affinity: %u,\n", i, nodes[0].cpu_list[i]);
#endif
    CPU_SET(nodes[0].cpu_list[i], &cpuset);
    pthread_setaffinity_np(threads[i], sizeof(cpu_set_t), &cpuset);
  }

  // joins the threads that were spawned
  for (unsigned int i = 0; i < threads_spawned; i++)
  {
    pthread_join(threads[i], NULL);
  }

  return 0;
}