using MRCFile, TranscodingStreams
using Test

@testset "MRCFile.jl" begin
    include("utils.jl")
    include("header.jl")
    include("io.jl")
    include("data.jl")
    include("dimensionaldata.jl")
    include("consistency.jl")
end
