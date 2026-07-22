// unique_lines.cpp
#include <iostream>
#include <fstream>
#include <string>
#include <unordered_set>
#include <boost/program_options.hpp>

/* Options macros */
#define HELP "help"
#define PROGRESS "progress"
#define FILE "file"

void print_lines(std::istream &in);

namespace po = boost::program_options;

void print_lines(std::istream &in) {
    std::unordered_set<std::string> seen;
    seen.reserve(1 << 20);

    std::string line;
    while (std::getline(in, line)) {
        if (seen.insert(line).second) { // var unik första gången
            std::cout << line << "\n";
        }
    }
}

int main(int argc, char* argv[]) {
    /* Options */
    bool show_progress;
    std::string file_name;

    po::options_description description("Allowed options");
    description.add_options()
            (HELP, "Show this message")
            (PROGRESS, po::bool_switch(&show_progress)->default_value(false), "Show progress bar")
            (FILE, po::value<std::string>(), "Input file")
            ;
    po::variables_map vm;
    po::store(po::parse_command_line(argc, argv, description), vm);
    po::notify(vm);
    /* Parse options */
    if (vm.count(HELP)) {
        std::cerr << description << std::endl;
        return 1;
    }
    if (vm.count(PROGRESS)) {
        show_progress = vm[PROGRESS].as<bool>();
    }
    /* File or stdin */
    if(vm.count(FILE))
    {
        std::ifstream in(file_name);
        print_lines(in);
    }
    else
    {
        print_lines(std::cin);
    }

    return 0;
}
