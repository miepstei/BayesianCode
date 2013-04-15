//
//  LogMult.cpp
//  MatrixUtils
//
//  Created by Michael Epstein on 09/05/2012.
//  Copyright (c) 2012 All rights reserved.
//

#include <iostream>
#include <vector>

using namespace std;


vector< vector<double> > mult(vector< vector<double> > A, vector< vector<double> > B, int rowA, int colB){
    
    vector< vector<double> > C(rowA, vector<double> (colB));

    for (int i=0;i<rowA;i++){
        for (int j=0;j<colB;j++){
            double sum=0;
            for (int k=0; k<rowA; k++){
                sum = sum + A[i][k]*B[k][j];
            }
            C[i][j]=sum;
        }
    }
    
    return C;
    
    
}

int main() {
    cout << "Hello World\n";
    cout << "A: Test matrix multiplication\n\n";
    

    vector< vector<double> > A(3, vector<double>(3));
    vector< vector<double> > B(3, vector<double>(3));
    
    
    for (int i=0;i<3;i++){
        for (int j=0;j<3;j++){
            A[i][j]=(i+1)*(j+1);
            B[i][j]=i-j;
        }
    }
    
    for (int i=0;i<3;i++){
        for (int j=0;j<3;j++){
            cout << A[i][j] << " ";
        }
        cout << "\n";
    }
    
    cout << "\n\nB: Test matrix multiplication\n\n";
    
    for (int i=0;i<3;i++){
        for (int j=0;j<3;j++){
            cout << B[i][j] << " ";
        }
        cout << "\n";
    }
    
    
    cout << "\n\nC: Test matrix multiplication\n\n";
    vector< vector<double> > C(3, vector<double>(3));
    C = mult(A,B,3,3);
    
    
    for (int i=0;i<3;i++){
        for (int j=0;j<3;j++){
            cout << C[i][j] << " ";
        }
        cout << "\n";
    }
    

}



