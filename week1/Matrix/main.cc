#include <iostream>
#include "matrix.hh"

int main()
{
    Matrix<4, 3, int> mat1;
    //    std::cout << mat1 << '\n';

    Matrix<3, 2, int> mat2;
    //    std::cout << mat2 << '\n';


    auto finmat = mat1 * mat2;
    
    
    std::cout << finmat;

}
