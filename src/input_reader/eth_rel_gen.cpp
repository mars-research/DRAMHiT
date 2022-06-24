#include "input_reader/eth_rel_gen.hpp"

namespace kmercounter {
namespace input_reader {
std::unordered_map<std::string, relation_t>
    SingletonEthRelationGenerator::relations_;
std::mutex SingletonEthRelationGenerator::mutex_;
}  // namespace input_reader
}  // namespace kmercounter
