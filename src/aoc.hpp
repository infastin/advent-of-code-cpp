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
concept part_fn = std::invocable<Fn, std::string_view>
  && std::same_as<std::invoke_result_t<Fn, std::string_view>, std::optional<uint64_t>>;

template<part_fn Fn>
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

template<part_fn PartOne, part_fn PartTwo>
constexpr void
run_all(std::string_view input, PartOne part_one, PartTwo part_two)
{
  std::cout << "🎄 Part One 🎄\n";
  run(input, part_one);
  std::cout << "🎄 Part two 🎄\n";
  run(input, part_two);
}

template<part_fn Fn>
constexpr void
run_test(std::string_view input, Fn fn, std::optional<uint64_t> expected)
{
  std::optional<uint64_t> result = fn(input);
  if (result.has_value()) {
    if (result.value() == expected.value()) {
      std::cout << std::format("Test passed: {} == {}\n", result.value(), expected.value());
    } else {
      std::cout << std::format("Test failed: {} != {}\n", result.value(), expected.value());
    }
  } else {
    if (expected.has_value()) {
      std::cout << std::format("Test failed: no result != {}\n", expected.value());
    } else {
      std::cout << std::format("Test passed: no result\n");
    }
  }
}

template<part_fn PartOne, part_fn PartTwo>
constexpr void
run_test_all(std::string_view input, PartOne part_one, PartTwo part_two,
  std::optional<uint64_t> expected_one, std::optional<uint64_t> expected_two)
{
  std::cout << "🎄 Part One 🎄\n";
  run_test(input, part_one, expected_one);
  std::cout << "🎄 Part two 🎄\n";
  run_test(input, part_two, expected_two);
}

} // namespace aoc

#endif /* end of include guard: AOC_HPP_SEZZQVO0 */
