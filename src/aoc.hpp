#ifndef AOC_HPP_SEZZQVO0
#define AOC_HPP_SEZZQVO0

#include <format>
#include <iostream>
#include <cstdint>
#include <concepts>
#include <string_view>
#include <chrono>

namespace aoc {

template<typename Fn>
requires std::invocable<Fn, std::string_view>
  && std::same_as<std::invoke_result_t<Fn, std::string_view>, std::optional<uint64_t>>
constexpr void
run(std::string_view input, Fn fn)
{
  auto start = std::chrono::high_resolution_clock::now();
  std::optional<uint64_t> result = fn(input);
  auto end = std::chrono::high_resolution_clock::now();

  if (result.has_value()) {
    std::cout << std::format("Result: {} ", result.value());
  } else {
    std::cout << "No result ";
  }

  auto diff = end - start;
  std::cout << std::format("(Time elapsed: {}m {}s {}ms)\n",
    std::chrono::duration_cast<std::chrono::minutes>(diff).count(),
    std::chrono::duration_cast<std::chrono::seconds>(diff).count() % 60,
    std::chrono::duration_cast<std::chrono::milliseconds>(diff).count() % 1000
  );
}

} // namespace aoc

#endif /* end of include guard: AOC_HPP_SEZZQVO0 */
