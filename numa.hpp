#include <numa.h>
#include <cstdio>
#include <cstdint>
#include <vector>
#include <algorithm>
#include <iostream>
#include <map>

#define RESET_MASK(x)		~(1LL << (x))

using namespace std;

typedef struct numa_node {
	unsigned int id;
	unsigned long cpu_bitmask;
	unsigned int num_cpus;
	std::vector<uint32_t> cpu_list;
} numa_node_t;

class Numa {
	public:
		Numa() : numa_present(!numa_available())
		{
			if (numa_present) {
				max_node = numa_max_node();
				max_possible_node = numa_max_possible_node();
				num_possible_nodes = numa_num_possible_nodes();
				num_configured_nodes =numa_num_configured_nodes();

				num_configured_cpus =numa_num_configured_cpus();
				num_possible_cpus =numa_num_possible_cpus();
				extract_numa_config();
				print_numa_nodes();
			}
		}

		inline bool is_numa_present(void) const {
			return numa_present;
		}

		friend std::ostream& operator<<(std::ostream &os, const Numa &n) {
			printf("NUMA available: %s\n", n.numa_present ? "true" : "false");
			printf("Node config:\n");
			printf("\tnuma_num_possible_nodes: %d\n", n.num_possible_nodes);
			printf("\tnuma_num_configured_nodes: %d\n", n.num_configured_nodes);
			printf("CPU config:\n");
			printf("\tnuma_num_possible_cpus: %d\n", n.num_possible_cpus);
			printf("\tnuma_num_configured_cpus: %d\n", n.num_configured_cpus);
			return os;
		}

		const int get_num_nodes() const {
			return num_configured_nodes;
		}

		void append_node(numa_node_t &node) {
			nodes.push_back(node);
		}

		void print_numa_nodes(void) {
			std::for_each(nodes.begin(), nodes.end(), [](auto &node) {
				printf("Node: %d cpu_bitmask: 0x%08lx | num_cpus: %d\n\t",
						node.id, node.cpu_bitmask, node.num_cpus);
				std::for_each(node.cpu_list.begin(), node.cpu_list.end(), [](uint32_t &cpu) {
							printf("%d ", cpu);
						});
				printf("\n");
			});
		}

		int extract_numa_config(void) {
			struct bitmask *cm = numa_allocate_cpumask();
			auto ret = 0;

			for (auto n = 0; n < num_configured_nodes; n++) {
				numa_node_t _node;
				if ((ret = numa_node_to_cpus(n, cm))) {
					fprintf(stderr, "bitmask is not long enough\n");
					return ret;
				}

				_node.cpu_bitmask = *(cm->maskp);
				_node.num_cpus = __builtin_popcountl(_node.cpu_bitmask);
				_node.id = n;

				// extract all the cpus from the bitmask
				while (_node.cpu_bitmask) {
					// cpu number starts from 0, ffs starts from 1.
					unsigned long c = __builtin_ffsll(_node.cpu_bitmask) - 1;
					_node.cpu_bitmask &= RESET_MASK(c);
					_node.cpu_list.push_back(c);
				}
				append_node(_node);
			}

			numa_free_cpumask(cm);
			return ret;
		}

		const std::vector<numa_node_t>& get_node_config(void) const {
			return nodes;
		}

	private:
		int numa_present;
		int max_node;
		int max_possible_node;
		int num_possible_nodes;
		int num_configured_nodes;
		int num_configured_cpus;
		int num_possible_cpus;
		int num_nodes;
		std::vector<numa_node_t> nodes;
};

class NumaPolicy : public Numa
{
public:
	// These are some preliminary ideas for numa policies. This may not be sufficient to cover all
	// possible cases.
	// Policies:
	// PROD_CONS_SEPARATE_NODES - This mode is to stress the framework as running producers and consumers on
	// different numa nodes
	// PROD_CONS_SAME_NODES - Run producers and consumers on the same numa node. Of course, this is bounded by
	// the number of cpus available on a numa node. prod + cons <= node_x_cpus
	// PROD_CONS_MIXED_MODE - the affinity does not matter. Just run it as long as you can tie this thread to
	// a cpu.
	enum numa_policy {
		PROD_CONS_SEPARATE_NODES = 1,
		PROD_CONS_SAME_NODES = 2,
		PROD_CONS_MIXED_MODE = 3,
		NUM_POLICIES,
	};

	NumaPolicy() {
		//uint32_t *producers = new uint32_t[num_configured_cpus];
		auto nodes = get_node_config();
	}
	// returns a tuple of producer, consumer cpus according to the policy
	std::tuple<uint32_t*, uint32_t*> get_prod_cons_list(enum numa_policy policy) {
		return policy_map[policy];
	}

private:
	std::map<numa_policy, std::tuple<uint32_t*, uint32_t*>> policy_map;
	int num_policies = NUM_POLICIES;
};
