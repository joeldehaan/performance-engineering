#include <iostream>

int main()
{
	double value;
	double sum = 0;
		size_t counter = 0;
	while(std::cin >> value)
	{
		sum += value;
		++counter;
	}
	std::cout << sum / counter;
}

