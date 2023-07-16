using MRCFile, TranscodingStreams
using Test

@testset "MRCFile.jl" begin
    include("utils.jl")
    include("header.jl")
    include("io.jl")
    include("data.jl")
end
