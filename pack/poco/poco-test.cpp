//You can test if you have pcre poco bug by compiling tis test program:
//
//$ g++ poco-test.cpp -o poco-test -l PocoFoundation
//
//and runnig it:
//
//$ echo 'Network.RTSP.Port="554"' | ./poco-test

#include <iostream>
#include <string>
#include <vector>

#include <Poco/RegularExpression.h>

int
main()
{
    std::string line;
    std::vector<std::string> subs;

    const Poco::RegularExpression re("([^=]+)=\"?([^\"]*)\"?");

    while (std::cin.good()) {
        std::getline(std::cin, line);
        if (!line.empty()) {
            std::cout << re.split(line, subs) << '\n';
        }
    }

    return 0;
}
