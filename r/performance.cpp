#include <iostream>

int sum(int n) {
	int result = (1 + n) * n / 2;
	return result;
}

int main() {
	int n = 0;
	while (sum(n) < 1000000000) {
		n = n + 1;
	}
	std::cout << n << std::endl;
}
