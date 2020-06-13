@testset "MRCHeader" begin
    @testset "MRCHeader()" begin
        h = MRCHeader()
        @test h.nx === Int32(0)
        @test h.ny === Int32(0)
        @test h.nz === Int32(0)
        @test h.mode === Int32(0)
        @test h.nxstart === Int32(0)
        @test h.nystart === Int32(0)
        @test h.nzstart === Int32(0)
        @test h.mx === Int32(0)
        @test h.my === Int32(0)
        @test h.mz === Int32(0)
        @test h.cella_x === Float32(0)
        @test h.cella_y === Float32(0)
        @test h.cella_z === Float32(0)
        @test h.cellb_alpha === Float32(90)
        @test h.cellb_beta === Float32(90)
        @test h.cellb_gamma === Float32(90)
        @test h.mapc === Int32(1)
        @test h.mapr === Int32(2)
        @test h.maps === Int32(3)
        @test h.dmin > h.dmax # test undefined
        @test h.dmean > h.dmax || h.dmean < h.dmin # test undefined
        @test h.ispg === Int32(1)
        @test h.nsymbt === Int32(0)
        @test h.extra1 === Tuple(zeros(UInt8, 8))
        @test h.exttyp === ""
        @test h.nversion === Int32(20140)
        @test h.extra2 === Tuple(zeros(UInt8, 84))
        @test h.origin_x === Float32(0)
        @test h.origin_y === Float32(0)
        @test h.origin_z === Float32(0)
        @test h.map === "MAP "
        @test h.machst === Tuple(MRC.machstfrombyteorder())
        @test h.rms === Float32(-1)
        @test h.nlabl === Int32(1)
        @test length(h.label) == 10
        @test length(h.label[1]) < 80
        @test startswith(h.label[1], "Created by MRC.jl at ")
    end

    @testset "MRCHeader(kwargs...)" begin
        h = MRCHeader(nx = 10)
        @test h.nx === Int32(10)
        h2 = MRCHeader(nsymbt = 3)
        @test h2.nsymbt === Int32(3)
        h3 = MRCHeader(ispg = 2)
        @test h3.ispg === Int32(2)
    end
end

@testset "show(::MRCHeader)" begin
    h = MRCHeader()
    @test startswith(
        sprint(show, "text/plain", h),
        """
MRCHeader(
    nx = 0,
    ny = 0,
    nz = 0,
    mode = 0,
    nxstart = 0,
    nystart = 0,
    nzstart = 0,
    mx = 0,
    my = 0,
    mz = 0,
    cella_x = 0.0f0,
    cella_y = 0.0f0,
    cella_z = 0.0f0,
    cellb_alpha = 90.0f0,
    cellb_beta = 90.0f0,
    cellb_gamma = 90.0f0,
    mapc = 1,
    mapr = 2,
    maps = 3,
    dmin = 0.0f0,
    dmax = -1.0f0,
    dmean = -2.0f0,
    ispg = 1,
    nsymbt = 0,
    extra1 = (0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00),
    exttyp = "",
    nversion = 20140,
    extra2 = (0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00),
    origin_x = 0.0f0,
    origin_y = 0.0f0,
    origin_z = 0.0f0,
    map = "MAP ",
    machst = (0x44, 0x44, 0x00, 0x00),
    rms = -1.0f0,
    nlabl = 1,
""",
    )
end

@testset "setproperty!(::MRCHeader)" begin
    h = MRCHeader()
    @test h.nx == 0
    h.nx = 10
    @test h.nx == 10
end

@testset "copyto!(::MRCHeader, ::MRCHeader)" begin
    h = MRCHeader()
    h2 = MRCHeader(nx = 10, ny = 10, nz = 10)
    copyto!(h, h2)
    @test h.nx == 10
    @test h.ny == 10
    @test h.nz == 10
end

@testset "sizeoffield($name, $type)" for (name, type, s) in (
    (:exttyp, String, 4),
    (:map, String, 4),
    (:label, Vector{String}, 800),
    (:testfloat, Float32, sizeof(Float32)),
    (:testint, Int32, sizeof(Int32)),
    (:testuintbool, NTuple{8,UInt8}, sizeof(NTuple{8,UInt8})),
)
    @test MRC.sizeoffield(name, type) == s
end

@testset "entrytobytes" begin
    @test MRC.entrytobytes(:exttyp, "abc") == [0x61, 0x62, 0x63, 0x00]
    @test MRC.entrytobytes(:exttyp, "abcde") == [0x61, 0x62, 0x63, 0x64]
    @test MRC.entrytobytes(:map, "abc") == [0x61, 0x62, 0x63, 0x00]
    @test MRC.entrytobytes(:map, "abcde") == [0x61, 0x62, 0x63, 0x64]
    @test MRC.entrytobytes(:label, ("abcd", ntuple(_ -> "", 9)...))[1:80] ==
          [0x61; 0x62; 0x63; 0x64; zeros(UInt8, 76)]
    @test MRC.entrytobytes(:testfloat, Float32(3)) == reinterpret(UInt8, [Float32(3)])
    @test MRC.entrytobytes(:testint, Int32(3)) == reinterpret(UInt8, [Int32(3)])
    @test MRC.entrytobytes(:testuintbool, (0x01, 0x02, 0x03, 0x04)) ==
          [0x01, 0x02, 0x03, 0x04]
end

@testset "fieldoffsets" begin
    @test MRC.fieldoffsets(MRCHeader) == [
        0,
        4,
        8,
        12,
        16,
        20,
        24,
        28,
        32,
        36,
        40,
        44,
        48,
        52,
        56,
        60,
        64,
        68,
        72,
        76,
        80,
        84,
        88,
        92,
        96,
        104,
        108,
        112,
        196,
        200,
        204,
        208,
        212,
        216,
        220,
        224,
    ]
end

@testset "size(::MRCHeader)" begin
    h = MRCHeader(nx = 10, ny = 20, nz = 30)
    @test size(h) == (10, 20, 30)
end

@testset "length(::MRCHeader)" begin
    h = MRCHeader(nx = 10, ny = 20, nz = 30)
    @test length(h) == 6000
end

# @test "ndims(::MRCHeader)" begin
#     h = MRCHeader()
# end

@testset "cellangles(::MRCHeader)" begin
    h = MRCHeader(cellb_alpha = 10, cellb_beta = 20, cellb_gamma = 30)
    @test cellangles(h) == (10f0, 20f0, 30f0)
end

@testset "cellangles!(::MRCHeader)" begin
    h = MRCHeader()
    @test cellangles(h) == (90f0, 90f0, 90f0)
    cellangles!(h, (10, 20, 30))
    @test cellangles(h) == (10f0, 20f0, 30f0)
end

@testset "cellsize(::MRCHeader)" begin
    h = MRCHeader(cella_x = 10, cella_y = 20, cella_z = 30)
    @test cellsize(h) == (10f0, 20f0, 30f0)
end

@testset "cellsize!(::MRCHeader)" begin
    h = MRCHeader()
    @test cellsize(h) == (0f0, 0f0, 0f0)
    cellsize!(h, (10, 20, 30))
    @test cellsize(h) == (10f0, 20f0, 30f0)
end

@testset "gridsize(::MRCHeader)" begin
    h = MRCHeader(mx = 10, my = 20, mz = 30)
    @test gridsize(h) == Int32.((10, 20, 30))
end

@testset "gridsize!(::MRCHeader)" begin
    h = MRCHeader()
    @test gridsize(h) == Int32.((0, 0, 0))
    gridsize!(h, (10, 20, 30))
    @test gridsize(h) == Int32.((10, 20, 30))
end

@testset "origin(::MRCHeader)" begin
    h = MRCHeader(origin_x = 10, origin_y = 20, origin_z = 30)
    @test origin(h) == (10f0, 20f0, 30f0)
end

@testset "origin!(::MRCHeader)" begin
    h = MRCHeader()
    @test origin(h) == (0f0, 0f0, 0f0)
    origin!(h, (10, 20, 30))
    @test origin(h) == (10f0, 20f0, 30f0)
end

@testset "start(::MRCHeader)" begin
    h = MRCHeader(nxstart = 10, nystart = 20, nzstart = 30)
    @test start(h) == Int32.((10, 20, 30))
end

@testset "start!(::MRCHeader)" begin
    h = MRCHeader()
    @test start(h) == Int32.((0, 0, 0))
    start!(h, (10, 20, 30))
    @test start(h) == Int32.((10, 20, 30))
end

@testset "voxelsize" begin
    @testset "voxelsize(::MRCHeader)" begin
        h = MRCHeader(cella_x = 10, cella_y = 20, cella_z = 30, mx = 2, my = 5, mz = 6)
        @test voxelsize(h) == (5.0f0, 4.0f0, 5.0f0)
    end

    @testset "voxelsize(::MRCHeader, i)" for i in 1:3
        scella = (:cella_x, :cella_y, :cella_z)[i]
        smx = (:mx, :my, :mz)[i]
        h = MRCHeader(; scella => 10, smx => 2)
        @test voxelsize(h, i) == 5.0f0
    end
end

@testset "voxelsize!" begin
    @testset "voxelsize!(::MRCHeader, s)" begin
        h = MRCHeader(mx = 10, my = 20, mz = 30)
        voxelsize!(h, (5, 10, 15))
        @test voxelsize(h) == Float32.((5, 10, 15))
        @test cellsize(h) == Float32.((50, 200, 450))
    end

    @testset "voxelsize!(::MRCHeader, s, i)" begin
        h = MRCHeader(mx = 10)
        voxelsize!(h, 5, 1)
        @test voxelsize(h, 1) == 5
        @test h.cella_x == 50
    end
end
