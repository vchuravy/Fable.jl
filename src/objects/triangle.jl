export define_triangle

triangle_fill = @fum function triangle_fill(x,y;
                                            A = (0,0),
                                            B = (0,0),
                                            C = (0,0))
    midpoint_y = (A[1] + B[1] + C[1]) ./ 3
    midpoint_x = (A[2] + B[2] + C[2]) ./ 3

    y = midpoint_y - (y - midpoint_y) * 0.5
    x = midpoint_x - (x - midpoint_x) * 0.5
    return point(y,x)
end

function define_triangle(; A::Union{Vector,Tuple,FractalInput}=(sqrt(3)/4,-0.5),
                           B::Union{Vector,Tuple,FractalInput}=(-sqrt(3)/4,0),
                           C::Union{Vector,Tuple,FractalInput}=(sqrt(3)/4,0.5),
                           color = Shaders.gray,
                           chosen_fx = :fill)
    fums = define_triangle_operators(A, B, C; chosen_fx = chosen_fx)

    fnum = 3
    if chosen_fx == :fill
        fnum = 4
    end

    color_set = define_color_operators(color; fnum = fnum)

    return fo(fums, color_set, Tuple([1/fnum for i = 1:fnum]))
end

# This specifically returns the fums for a triangle triangle
function define_triangle_operators(A::Union{Vector, Tuple, FractalInput},
                                   B::Union{Vector, Tuple, FractalInput},
                                   C::Union{Vector, Tuple, FractalInput};
                                   chosen_fx = :fill)

    if chosen_fx != :sierpinski && chosen_fx != :fill
        error("Cannot create triangle with ", string(chosen_fx), " function!")
    end

    s_1 = Flames.halfway(loc = A)
    s_2 = Flames.halfway(loc = B)
    s_3 = Flames.halfway(loc = C)
    if chosen_fx == :fill
        s_4 = triangle_fill(A = A, B = B, C = C)

        return [s_1, s_2, s_3, s_4]
    elseif chosen_fx == :sierpinski
        return [s_1, s_2, s_3]
    end
end
