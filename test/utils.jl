@testset "padtruncto!" begin
    x = [1, 2, 3]
    MRC.padtruncto!(x, 4)
    @test x == [1, 2, 3, 0]
    MRC.padtruncto!(x, 6; value = 1)
    @test x == [1, 2, 3, 0, 1, 1]
    MRC.padtruncto!(x, 3)
    @test x == [1, 2, 3]
    MRC.padtruncto!(x, 5; value = 1.0)
    @test x == [1, 2, 3, 1, 1]
end

@testset "checkmagic" begin
    magic_type_pairs = merge(MRC.COMPRESSOR_MAGICS, Dict(b"\x04\x05\x06" => :none))
    @testset "$type" for (magic, type) in magic_type_pairs
        io = IOBuffer()
        write(io, magic)
        write(io, [0x01, 0x02, 0x03])
        seek(io, 0)
        type2 = MRC.checkmagic(io)
        @test type2 == type
        close(io)
    end
end

@testset "checkextension" begin
    ext_type_pairs = merge(MRC.COMPRESSOR_EXTENSIONS, Dict("" => :none))
    @testset "$type" for (ext, type) in ext_type_pairs
        fn = "map.mrc$(ext)"
        type2 = MRC.checkextension(fn)
        @test type2 == type
    end
end

