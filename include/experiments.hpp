#pragma once

namespace kmercounter {
enum class experiment_type {
  none,
  prefetch_only,
  nop_insert,
  insert_dry_run,
  aggr_kv_write_key_only
};

static constexpr experiment_type active_experiment{DRAMHIT_ACTIVE_EXPERIMENT};

template <typename... pack_types>
constexpr bool experiment_inactive(experiment_type type,
                                   pack_types... other_types) {
  return active_experiment != type && experiment_inactive(other_types...);
}

constexpr bool experiment_inactive(experiment_type type) {
  return active_experiment != type;
}

template <typename... pack_types>
constexpr bool experiment_active(pack_types... other_types) {
  return !experiment_inactive(other_types...);
}

}  // namespace kmercounter
