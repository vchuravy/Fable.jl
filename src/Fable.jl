module Fable

using KernelAbstractions
using KernelAbstractions: @atomic

using MacroTools
using Unitful

using Images
using VideoIO

# Constants
global OUTPUT = true
set_output(tf) = (global OUTPUT = tf)

# Interfaces
include("structs/time.jl")
include("structs/point.jl")

# Utilities
include("utils/extras.jl")

# Geometries
include("utils/geometries.jl")

# KA kernels
include("utils/histogram.jl")

# Fractal flame structures
include("structs/fractal_input.jl")
include("structs/fractal_user_methods.jl")
include("fums/shaders.jl")
include("structs/fractal_operators.jl")
include("structs/fractal_executable/fractal_executable.jl")
include("structs/fractal_executable/hutchinson.jl")
include("structs/fractal_executable/shader.jl")

# Operations
include("utils/simple_rng.jl")
include("fums/flames.jl")
include("fums/smears.jl")

# Shapes
include("objects/rectangle.jl")
include("objects/circle.jl")
include("objects/triangle.jl")
include("objects/barnsley.jl")

# IO
include("structs/layers/layers.jl")
include("io/postprocess/postprocess.jl")
include("structs/layers/fractal_layer.jl")
include("structs/layers/color_layer.jl")
include("structs/layers/image_layer.jl")
include("structs/layers/shader_layer.jl")
include("structs/video_params.jl")
include("io/io_tools.jl")

# PostProcessing
include("io/postprocess/clip.jl")
include("io/postprocess/filter.jl")
include("io/postprocess/sobel.jl")
include("io/postprocess/outline.jl")

# Main file
include("run/run.jl")
include("run/fractal_flame.jl")
include("run/shader.jl")
include("run/color.jl")

end # module
