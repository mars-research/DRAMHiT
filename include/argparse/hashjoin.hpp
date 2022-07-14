#ifndef ARGPARSE_HASHJOIN_HPP
#define ARGPARSE_HASHJOIN_HPP

#include <boost/program_options.hpp>

#include <iostream>

namespace kmercounter {

struct HashjoinOptions {
  // Path to relation R.
  std::string relation_r;
  // Path to relation S.
  std::string relation_s;
  // Number of elements in relation R. Only used when the relations are generated.
  uint64_t relation_r_size;
  // Number of elements in relation S. Only used when the relations are generated.
  uint64_t relation_s_size;
  // CSV delimitor for relation files.
  std::string delimitor;

  std::unique_ptr<boost::program_options::options_description> build_opt_desc() {
    namespace po = boost::program_options;

    auto desc = std::make_unique<po::options_description>("Perform hashjoin on relation R and S");
    desc->add_options()
        ("relation_r",
        po::value(&this->relation_r)->default_value("r.tbl"), "Path to relation R.")
        ("relation_s",
        po::value(&this->relation_s)->default_value("s.tbl"), "Path to relation S.")
        ("relation_r_size",
        po::value(&this->relation_r_size)->default_value(128000000), "Number of elements in relation R. Only used when the relations are generated.")
        ("relation_s_size",
        po::value(&this->relation_s_size)->default_value(128000000), "Number of elements in relation S. Only used when the relations are generated.")
        ("delimitor",
        po::value(&this->delimitor)->default_value("|"), "CSV delimitor for relation files.");

    return desc;
  }

  friend std::ostream& operator<<(std::ostream& stream, const HashjoinOptions& o) {
    stream << "Hashjoin options: " << "\n";
    stream << "  relation_r: " << o.relation_r << "\n";
    stream << "  relation_s: " << o.relation_s << "\n";
    stream << "  relation_r_size: " << o.relation_r_size << "\n";
    stream << "  relation_s_size: " << o.relation_s_size << "\n";
    stream << "  delimitor: " << o.delimitor << "\n";
    return stream;
  } 
};

} // namespace kmercounter
#endif // ARGPARSE_HASHJOIN_HPP
