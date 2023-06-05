@testset "read" begin
    @testset "read(::AbstractString, ::Type{MRCData})" begin
        @testset "emd3001.map" begin
            emd3001 = read("$(@__DIR__)/testdata/emd_3001.map", MRCData)
            emd3001gz = read("$(@__DIR__)/testdata/emd_3001.map.gz", MRCData)
            emd3001bz2 = read("$(@__DIR__)/testdata/emd_3001.map.bz2", MRCData)
            emd3001_f16 = read("$(@__DIR__)/testdata/emd_3001_f16.mrc", MRCData)
            @test emd3001 == emd3001gz == emd3001bz2
            @test (emd3001.data .|> Float16) ≈ emd3001_f16.data
            h = header(emd3001)
            eh = extendedheader(emd3001)
            p = parent(emd3001)
            @test h.nx === Int32(size(p)[1]) === Int32(73)
            @test h.ny === Int32(size(p)[2]) === Int32(43)
            @test h.nz === Int32(size(p)[3]) === Int32(25)
            @test MRCFile.datatype(h.mode) === eltype(p) === Float32
            @test h.nxstart === Int32(0)
            @test h.nystart === Int32(-21)
            @test h.nzstart === Int32(-12)
            @test h.mx === Int32(40)
            @test h.my === Int32(12)
            @test h.mz === Int32(72)
            @test h.cella_x === Float32(17.93)
            @test h.cella_y === Float32(4.71)
            @test h.cella_z === Float32(33.03)
            @test h.cellb_alpha === Float32(90.0)
            @test h.cellb_beta === Float32(94.326)
            @test h.cellb_gamma === Float32(90.0)
            @test h.mapc === Int32(3)
            @test h.mapr === Int32(1)
            @test h.maps === Int32(2)
            @test h.dmin === Float32(minimum(p)) === Float32(-0.36814296)
            @test h.dmax === Float32(maximum(p)) === Float32(0.72161025)
            @test h.dmean === Float32(0.0005329667)
            @test h.ispg === Int32(4)
            @test h.nsymbt == sizeof(eh) == Int32(160)
            @test h.extra1 === Tuple(zeros(UInt8, 8))
            @test h.exttyp === ""
            @test h.nversion === Int32(0)
            @test h.extra2 === Tuple(zeros(UInt8, 84))
            @test h.origin_x === Float32(0)
            @test h.origin_y === Float32(0)
            @test h.origin_z === Float32(0)
            @test h.map === MRCFile.MAP_NAME
            @test h.machst === (0x44, 0x41, 0x0, 0x0)
            @test h.rms === Float32(0.15705723)
            @test h.nlabl === Int32(1)
            @test h.label ==
                ("::::EMDATABANK.org::::EMD-3001::::", "", "", "", "", "", "", "", "", "")
        end

        @testset "emd_3001_projections" begin
            emd3001_projections = read("$(@__DIR__)/testdata/emd_3001_proj.mrcs", MRCData)
            @test size(emd3001_projections) == (73, 43, 10)
        end

        @testset "emd3197.map" begin
            emd3197 = read("$(@__DIR__)/testdata/emd_3197.map", MRCData)
            emd3197gz = read("$(@__DIR__)/testdata/emd_3197.map.gz", MRCData)
            emd3197bz2 = read("$(@__DIR__)/testdata/emd_3197.map.bz2", MRCData)
            emd3197_f16 = read("$(@__DIR__)/testdata/emd_3197_f16.mrc", MRCData)
            @test emd3197 == emd3197gz == emd3197bz2
            @test (emd3197.data .|> Float16) ≈ emd3197_f16.data
            h = header(emd3197)
            eh = extendedheader(emd3197)
            p = parent(emd3197)
            @test h.nx === Int32(size(p)[1]) === Int32(20)
            @test h.ny === Int32(size(p)[2]) === Int32(20)
            @test h.nz === Int32(size(p)[3]) === Int32(20)
            @test MRCFile.datatype(h.mode) === eltype(p) === Float32
            @test h.nxstart === Int32(-2)
            @test h.nystart === Int32(0)
            @test h.nzstart === Int32(0)
            @test h.mx === Int32(20)
            @test h.my === Int32(20)
            @test h.mz === Int32(20)
            @test h.cella_x === Float32(228)
            @test h.cella_y === Float32(228)
            @test h.cella_z === Float32(228)
            @test h.cellb_alpha === Float32(90)
            @test h.cellb_beta === Float32(90)
            @test h.cellb_gamma === Float32(90)
            @test h.mapc === Int32(1)
            @test h.mapr === Int32(2)
            @test h.maps === Int32(3)
            @test h.dmin === Float32(minimum(p)) === Float32(-4.1337457)
            @test h.dmax === Float32(maximum(p)) === Float32(5.576737)
            @test h.dmean === Float32(0.783612)
            @test h.ispg === Int32(1)
            @test h.nsymbt == sizeof(eh) == Int32(0)
            @test h.extra1 === Tuple(zeros(UInt8, 8))
            @test h.exttyp === ""
            @test h.nversion === Int32(0)
            @test h.extra2 === Tuple(zeros(UInt8, 84))
            @test h.origin_x === Float32(0)
            @test h.origin_y === Float32(0)
            @test h.origin_z === Float32(0)
            @test h.map === MRCFile.MAP_NAME
            @test h.machst === (0x44, 0x41, 0x0, 0x0)
            @test h.rms === Float32(2.399953)
            @test h.nlabl === Int32(1)
            @test h.label ==
                ("::::EMDATABANK.org::::EMD-3197::::", "", "", "", "", "", "", "", "", "")
        end

        @testset "emd_3197_projections" begin
            emd3197_projections = read("$(@__DIR__)/testdata/emd_3197_proj.mrcs", MRCData)
            @test size(emd3197_projections) == (20, 20, 10)
        end
    end
end

@testset "write" begin
    @testset "buffer size has no effect on data" begin
        emd3001 = read("$(@__DIR__)/testdata/emd_3001.map", MRCData)
        buffer_sizes = [1024, 2048, 4096, 100, 42]

        for buffer_size in buffer_sizes
            @testset "buffer size: $buffer_size" begin
                # no preallocation
                io = IOBuffer(; read=true, write=true)
                write(io, emd3001; buffer_size=buffer_size)
                flush(io)
                seekstart(io)
                @test read(io, MRCData) == emd3001
                close(io)

                # with preallocation
                io = IOBuffer(; read=true, write=true)
                buffer = Vector{Float32}(undef, buffer_size)
                write(io, emd3001; buffer=buffer)
                flush(io)
                seekstart(io)
                @test read(io, MRCData) == emd3001
                close(io)
            end
        end
    end

    @testset "buffer eltype must match data type" begin
        emd3001 = read("$(@__DIR__)/testdata/emd_3001.map", MRCData)
        buffer = Vector{Float64}(undef, 1)
        @test_throws ArgumentError write(IOBuffer(), emd3001; buffer=buffer)
    end
end
