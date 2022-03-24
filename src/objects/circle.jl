# TODO:
#     1. Use Box--Muller so we don't need polar input
#     2. Add constant density disk
# Code examples modified from: https://www.math.uwaterloo.ca/~wgilbert/FractalGallery/IFS/IFS.html

disk = Fae.@fo function disk(x, y; radius = 1, pos = (0,0),
                             function_index = 0)
    theta = atan(y,x)
    if y < 0
        theta += 2*pi
    end
    r = sqrt(x*x + y*y)

    if r > 1
        r = 1
    end

    theta2 = (r+function_index)*pi
    r2 = theta/(2*pi)

    x = r2*cos(theta2)
    y = r2*sin(theta2)
end

constant_disk = Fae.@fo function constant_disk(x, y; radius = 1
                                               function_index = 0)
    theta = atan(y,x)
    if y < 0
        theta += 2*pi
    end
    r = sqrt(x*x + y*y)

    if r > 1
        r = 1
    end

    theta2 = (r+function_index)*pi
    r2 = theta/(2*pi)

    x = r2*cos(theta2)
    y = r2*sin(theta2)

end

# Returns back H, colors, and probs for a circle
function define_circle(pos::Vector{FT}, radius::FT, color::Array{FT};
                       AT = Array, name = "circle", chosen_fx = :disk,
                       diagnostic = false) where FT <: AbstractFloat

    fos, fis = define_circle_operators(pos, radius; chosen_fx = chosen_fx)
    fo_num = length(fos)
    prob_set = Tuple([1/fo_num for i = 1:fo_num])

    color_set = [color for i = 1:fo_num]
    return Hutchinson(fos, fis, color_set, prob_set; AT = AT, FT = FT,
                      name = name, diagnostic = diagnostic)
end

# This specifically returns the fos for a circle
function define_circle_operators(pos::Vector{FT}, radius;
                                 chosen_fx = :disk) where FT <: AbstractFloat

    f_0 = fi("f_0", 0)
    f_1 = fi("f_1", 1)
    if chosen_fx == :disk
        d_0 = disk(function_index = f_0)
        d_1 = disk(function_index = f_1)
    elseif chosen_fx == constant_disk
        d_0 = chosen_disk(function_index = f_0)
        d_1 = chosen_disk(function_index = f_1)
    else
        error("function not found for circle IFS!")
    end
    return [d_0, d_1], [f_0, f_1]

end

function update_circle!(H, pos, radius)
    update_circle!(H, pos, radius, nothing)
end

function update_circle!(H::Hutchinson, pos::Vector{F},
                       radius, color::Union{Array{F}, Nothing};
                       FT = Float64, AT = Array) where F <: AbstractFloat

    H.symbols = configure_fis!([p1, p2, p3, p4])
    if color != nothing
        H.color_set = new_color_array([color for i = 1:4], 4; FT = FT, AT = AT)
    end

end
