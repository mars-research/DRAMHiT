#ifndef INPUT_READER_FASTX
#define INPUT_READER_FASTX


#include "input_reader.hpp"
#include "readfq/kseq.h"

KSEQ_INIT(int, read)
/// Sequentially incrementin counter.
template<class T>
class FastxReader : public InputReader<T> {
    public:
    FastxReader(const std::string& file, uint32_t k) {
        int fd = open(file.c_str(), O_RDONLY);
        this->seq = kseq_init(fd);
    }

    T next() override {
        auto data = kseq_read(this->seq);
        if (data < 0) {
            throw "End of file";
        }
        return data++;
    }

    ~FastxReader() {
        kseq_destroy(this->seq);
    }

private:
    kseq_t* seq;
};


#endif /* INPUT_READER_FASTX */
