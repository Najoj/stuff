#include <iostream>

consteval double cube(double x)
{
    return x*x;
}

int main()
{
    constexpr double pi = 3.1416;
    constexpr double a = cube(pi);
    constexpr double b {cube(a)};
    constexpr double c = {cube(b)};

    std::cout << a << std::endl;
    std::cout << b << std::endl;
    std::cout << c << std::endl;

    return 0;
}
