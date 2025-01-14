export define_circle

# Code examples modified from: https://www.math.uwaterloo.ca/~wgilbert/FractalGallery/IFS/IFS.html

naive_disk = @fum function naive_disk(x, y; radius = 1, position = (0,0),
                                      function_index = 0)
    x_temp = (x-position[2])/radius
    y_temp = (y-position[1])/radius
    r = sqrt(x_temp*x_temp + y_temp*y_temp)

    theta = pi
    if !isapprox(r, 0)
        theta = atan(y_temp,x_temp)
        if y_temp < 0
            theta += 2*pi
        end
    end

    theta2 = (r+function_index)*pi
    r2 = theta/(2*pi)

    x = radius*r2*cos(theta2)+position[2]
    y = radius*r2*sin(theta2)+position[1]
    return point(y,x)
end

constant_disk = @fum function constant_disk(x, y; radius = 1,
                                            position = (0,0),
                                            function_index = 0)

    x_temp = (x-position[2])/radius
    y_temp = (y-position[1])/radius
    r = x_temp*x_temp + y_temp*y_temp

    theta = pi
    if !isapprox(r, 0)
        theta = atan(y_temp,x_temp)
        if y_temp < 0
            theta += 2*pi
        end
    end

    theta2 = (r+function_index)*pi
    r2 = sqrt(theta/(2*pi))

    x = radius*r2*cos(theta2)+position[2]
    y = radius*r2*sin(theta2)+position[1]
    return point(y,x)
end

# Returns back H, colors, and probs for a circle
function define_circle(; position::Union{Tuple, Vector, FractalInput} = (0, 0),
                         radius::Union{Number, FractalInput} = 1.0,
                         color = Shaders.gray,
                         chosen_fx = :constant_disk)

    fums = define_circle_operators(position, radius; chosen_fx = chosen_fx)
    color_set = define_color_operators(color; fnum = 2)
    return fo(fums, color_set, (0.5, 0.5))
end

# This specifically returns the fums for a circle
function define_circle_operators(position::Union{Vector, Tuple, FractalInput},
                                 radius::Union{Number, FractalInput};
                                 chosen_fx = :constant_disk)

    f_0 = fi("f_0", 0)
    f_1 = fi("f_1", 1)
    if chosen_fx == :naive_disk
        d_0 = naive_disk(function_index = f_0, position = position, radius = radius)
        d_1 = naive_disk(function_index = f_1, position = position, radius = radius)
    elseif chosen_fx == :constant_disk
        d_0 = constant_disk(function_index = f_0, position = position, radius = radius)
        d_1 = constant_disk(function_index = f_1, position = position, radius = radius)
    else
        error("function not found for circle IFS!")
    end
    return [d_0, d_1]

end
