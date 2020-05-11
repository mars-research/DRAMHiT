#include <chrono>
#include <ctime>

class timestamp
{
  // TODO change period
  typedef std::ratio<1, 2500000000> period;

 public:
  timestamp(unsigned long transactions, std::string type)
      : start(std::chrono::high_resolution_clock::now()),
        _transactions(transactions),
        _ht_type(type)
  {
    std::cout << "Starting " << _ht_type << std::endl;
  }

  ~timestamp()
  {
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed_seconds = end - start;
    std::chrono::duration<double, period> cycles = end - start;

    std::cout << "============= " << _ht_type << " ==============" << std::endl;
    printf(
        "%lu insertions:\n%f cycles | %f seconds\n%f cycles per insertion | %f "
        "ns\n",
        _transactions, cycles.count(), elapsed_seconds.count(),
        cycles.count() / _transactions,
        std::chrono::duration<double, std::nano>(end - start).count() /
            _transactions);
    std::cout << "===============================================" << std::endl;
  }

 private:
  std::chrono::time_point<std::chrono::high_resolution_clock> start;
  unsigned long _transactions;
  std::string _ht_type;
};