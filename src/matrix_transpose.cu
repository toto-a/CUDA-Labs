#include <iostream>
#include <math.h>


const int TILE_DIM =32;
const int BLOCK_ROWS=8;
const int NUM_REPS= 100;


__global__
void copy(float *odata, float *idata){
    int x=blockIdx.x*TILE_DIM+threadIdx.x;
    int y = blockIdx.y * TILE_DIM + threadIdx.y;
    int w=gridDim.x*TILE_DIM;

    for(int j=0;j<TILE_DIM;j+=BLOCK_ROWS)
        odata[(y+j)*w+x]=idata[(y+j)*w+x];

}


__global__
void transpose_naive(float *odata, const float* idata){
    int x=blockIdx.x*TILE_DIM+threadIdx.x;
    int y = blockIdx.y * TILE_DIM + threadIdx.y;
    int w=gridDim.x*TILE_DIM;

    for(int j=0;j<TILE_DIM;j+=BLOCK_ROWS)
        odata[x*w +(y+j)]=idata[(y+j)*w+x];

}

int main(){
    const int nx=1024;
    const int ny=1024;
    const int mem_size=nx*ny*sizeof(float);

    dim3 dimGrid(nx/TILE_DIM,ny/TILE_DIM,1);
    dim3 dimBlock(TILE_DIM,BLOCK_ROWS,1); 

    float *h_idata= new float[mem_size];
    float *h_odata= new float[mem_size];
    float *result= new float[mem_size];
    float *d_idata,*d_odata;

    //Alloc memory on device
    cudaMallocManaged(&d_idata,mem_size);
    cudaMallocManaged(&d_odata,mem_size);


    //Computation on host
    for(int j=0;j<ny;j++)
        for(int i=0;i<nx;i++)
            h_idata[j*nx+i]=(float)(i+j*nx);
    
    //For comparison purpose
    for(int j=0;j<ny;j++)
        for(int i=0;i<nx;i++)
            result[i*ny+j]=h_idata[j*nx+i];


    cudaMemcpy(d_idata,h_idata,mem_size,cudaMemcpyHostToDevice);

    //Transpose Naive 
    cudaMemset(d_odata,0 ,mem_size); 
    transpose_naive<<<dimGrid,dimBlock>>>(d_odata,d_idata);

    // Wait for GPU to finish before accessing on host
    cudaDeviceSynchronize();

    // Check for errors 
    float maxError = 0.0f;
    for (int i = 0; i < nx*ny; i++)
        maxError = fmax(maxError, fabs(d_odata[i]-result[i]));
    std::cout << "Max error: " << maxError << std::endl;


    //cleanup
    delete[] h_idata;
    delete[] h_odata;
    delete[] result;

    cudaFree(d_idata);
    cudaFree(d_odata);


    return 0;



}