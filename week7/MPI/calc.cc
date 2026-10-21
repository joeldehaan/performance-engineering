#include <string>
#include <sstream>
#include <iostream>

using namespace std;

int main()
{
	string str;
	getline(cin, str);

	while (getline(cin, str))
	{
		string value;
		istringstream txt{str};
		
		getline(txt, value, ','); 
		size_t N = stoul(value);
		getline(txt, value, ',');
		size_t Repeats = stoul(value);
		getline(txt, value, ',');
		double time = stod(value);


		cout << 2 * N * Repeats / time << '\n';
	}

}
