using Fae, Images, CUDA

if has_cuda_gpu()
    using CUDAKernels
    CUDA.allowscalar(false)
end


function main()

    check = Fae.@fo function check()
    end

    AT = CuArray
    FT = Float32

    frames = 1

    theta = Fae.fi("theta", 3.14)

    f_set_2 = [Fae.swirl, Fae.heart]
    color_set = [[0,1,0,1], [0,0,1,1]]
    prob_set = (0.5, 0.5)

    H = Fae.define_square([0.0,0.0], pi/8, 1.0, [1.0,0,1,1]; AT = AT)
    H_2 = Fae.Hutchinson(f_set_2, color_set, prob_set; AT = AT, FT = FT, diagnostic=true)

    num_particles = 10000
    num_iterations = 10000
    bounds = [-1.125 1.125; -2 2]
    res = (1080, 1920)

    for i = 1:frames
        filename = "blah.png"

        pix = Fae.fractal_flame(H, H_2, num_particles, num_iterations, bounds,
                                res; AT = AT, FT = FT)

        Fae.write_image([pix], filename)
    end

end

main()