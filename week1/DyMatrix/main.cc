#include <iostream>
#include "matrix.hh"

int main()
{
    Matrix<int> mat1(4, 3);
    //    std::cout << mat1 << '\n';

    Matrix<int> mat2(3, 2);
    //    std::cout << mat2 << '\n';


    auto finmat = mat1 * mat2;
    
    
    std::cout << finmat;

}
