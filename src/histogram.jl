using Test
using CUDA
using CUDAKernels
using KernelAbstractions

# Function to use as a baseline for CPU metrics
function create_histogram(input)
    histogram_output = zeros(Int, maximum(input))
    for i = 1:length(input)
        histogram_output[input[i]] += 1
    end
    return histogram_output
end

# This a 1D histogram kernel where the histogramming happens on shmem
@kernel function histogram_kernel!(histogram_output, input)
    tid = @index(Global, Linear)
    lid = @index(Local, Linear)

    @uniform warpsize = Int(32)

    @uniform gs = @groupsize()[1]
    @uniform N = length(histogram_output)

    shared_histogram = @localmem Int (gs)

    # This will go through all input elements and assign them to a location in
    # shmem. Note that if there is not enough shem, we create different shmem
    # blocks to write to. For example, if shmem is of size 256, but it's
    # possible to get a value of 312, then we will have 2 separate shmem blocks,
    # one from 1->256, and another from 256->512
    @uniform max_element = 1
    for min_element = 1:gs:N

        # Setting shared_histogram to 0
        @inbounds shared_histogram[lid] = 0
        @synchronize()

        max_element = min_element + gs
        if max_element > N
            max_element = N+1
        end

        # Defining bin on shared memory and writing to it if possible
        bin = input[tid]
        if bin >= min_element && bin < max_element
            bin -= min_element-1
            atomic_add!(pointer(shared_histogram, bin), Int(1))
        end

        @synchronize()

        if ((lid+min_element-1) <= N)
            atomic_add!(pointer(histogram_output, lid+min_element-1),
                        shared_histogram[lid])
        end

    end

end

function histogram!(histogram_output, input;
                    numcores = 4, numthreads = 256)

    if isa(input, Array)
        kernel! = histogram_kernel!(CPU(), numcores)
    else
        kernel! = histogram_kernel!(CUDADevice(), numthreads)
    end

    kernel!(histogram_output, input, ndrange=size(input))
end

@testset "histogram tests" begin

    rand_input = [rand(1:128) for i = 1:1000]
    linear_input = [i for i = 1:1024]
    all_2 = [2 for i = 1:512]

    histogram_rand_baseline = create_histogram(rand_input)
    histogram_linear_baseline = create_histogram(linear_input)
    histogram_2_baseline = create_histogram(all_2)

    CPU_rand_histogram = zeros(Int, 128)
    CPU_linear_histogram = zeros(Int, 1024)
    CPU_2_histogram = zeros(Int, 2)

    wait(histogram!(CPU_rand_histogram, rand_input))
    wait(histogram!(CPU_linear_histogram, linear_input))
    wait(histogram!(CPU_2_histogram, all_2))

    @test isapprox(CPU_rand_histogram, histogram_rand_baseline)
    @test isapprox(CPU_linear_histogram, histogram_linear_baseline)
    @test isapprox(CPU_2_histogram, histogram_2_baseline)

    if has_cuda_gpu()
        CUDA.allowscalar(false)

        GPU_rand_input = CuArray(rand_input)
        GPU_linear_input = CuArray(linear_input)
        GPU_2_input = CuArray(all_2)

        GPU_rand_histogram = CuArray(zeros(Int, 128))
        GPU_linear_histogram = CuArray(zeros(Int, 1024))
        GPU_2_histogram = CuArray(zeros(Int, 2))

        wait(histogram!(GPU_rand_histogram, GPU_rand_input))
        wait(histogram!(GPU_linear_histogram, GPU_linear_input))
        wait(histogram!(GPU_2_histogram, GPU_2_input))

        @test isapprox(Array(GPU_rand_histogram), histogram_rand_baseline)
        @test isapprox(Array(GPU_linear_histogram), histogram_linear_baseline)
        @test isapprox(Array(GPU_2_histogram), histogram_2_baseline)
    end

end
