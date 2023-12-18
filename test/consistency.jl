using Test
using CondaPkg
using PythonCall

# Load the Python module/package
numpy = pyimport("numpy")
mrcfile = pyimport("mrcfile")

function compare_map(map_jl::AbstractArray{Float32,3}, map_py::AbstractArray{Float32,3})
    @test map_jl == map_py
end

function compare_header(header_jl::MRCHeader, header_py::Py)
    @test Bool(header_jl.nx == header_py.nx)
    @test Bool(header_jl.ny == header_py.ny)
    @test Bool(header_jl.nz == header_py.nz)
    @test Bool(header_jl.mode == header_py.mode)
    @test Bool(header_jl.nxstart == header_py.nxstart)
    @test Bool(header_jl.nystart == header_py.nystart)
    @test Bool(header_jl.nzstart == header_py.nzstart)
    @test Bool(header_jl.mx == header_py.mx)
    @test Bool(header_jl.my == header_py.my)
    @test Bool(header_jl.mz == header_py.mz)
    @test Bool(header_jl.cella_x == header_py.cella.x)
    @test Bool(header_jl.cella_y == header_py.cella.y)
    @test Bool(header_jl.cella_z == header_py.cella.z)
    @test Bool(header_jl.cellb_alpha == header_py.cellb.alpha)
    @test Bool(header_jl.cellb_beta == header_py.cellb.beta)
    @test Bool(header_jl.cellb_gamma == header_py.cellb.gamma)
    @test Bool(header_jl.mapc == header_py.mapc)
    @test Bool(header_jl.mapr == header_py.mapr)
    @test Bool(header_jl.maps == header_py.maps)
    @test Bool(header_jl.dmin == header_py.dmin)
    @test Bool(header_jl.dmax == header_py.dmax)
    @test Bool(header_jl.dmean == header_py.dmean)
    @test Bool(header_jl.ispg == header_py.ispg)
    @test Bool(header_jl.nsymbt == header_py.nsymbt)
    @test [UInt8(b) for b in header_jl.extra1] == pyconvert(Vector{UInt8}, header_py.extra1.tobytes())
    @test [UInt8(b) for b in header_jl.exttyp] == pyconvert(Vector{UInt8}, header_py.exttyp.tobytes())
    @test Bool(header_jl.nversion == header_py.nversion)
    @test ([UInt8(b) for b in header_jl.extra2]) == pyconvert(Vector{UInt8}, header_py.extra2.tobytes())
    @test Bool(header_jl.origin_x == header_py.origin.x)
    @test Bool(header_jl.origin_y == header_py.origin.y)
    @test Bool(header_jl.origin_z == header_py.origin.z)
    @test [UInt8(b) for b in header_jl.map] == pyconvert(Vector{UInt8}, header_py.map.tobytes())
    @test [UInt8(b) for b in header_jl.machst] == pyconvert(Vector{UInt8}, header_py.machst.tobytes())
    @test Bool(header_jl.rms == header_py.rms)
    @test Bool(header_jl.nlabl == header_py.nlabl)
    @test join(header_jl.label) ==
        pyconvert(String, header_py.label.tostring().decode().strip())
end

function compare_extendedheader(exh_jl::MRCExtendedHeader, exh_py::Py)
    @test [UInt8(b) for b in exh_jl.data] == pyconvert(Vector{UInt8}, exh_py.tobytes())
end

function compare_mrcfile(map_path::String)
    emd_jl = read(map_path, MRCData)
    map_jl = data(emd_jl)
    header_jl = header(emd_jl)
    exh_jl = extendedheader(emd_jl)

    emd_py = mrcfile.open(map_path; mode="r")
    data_copy = numpy.copy(emd_py.data)  # Create a copy of the data
    map_py = pyconvert(Array{Float32,3}, data_copy)
    header_py = emd_py.header
    exh_py = emd_py.extended_header
    emd_py.close()  # Make sure the file is closed even if an error occurs

    @testset "map" begin
        compare_map(map_jl, map_py)
    end

    @testset "header" begin
        compare_header(header_jl, header_py)
    end

    @testset "extendedheader" begin
        compare_extendedheader(exh_jl, exh_py)
    end
end

@testset "Consistency Test" begin
    @testset "emd_3001.map" begin
        emd3001_path = "$(@__DIR__)/testdata/emd_3001.map"
        compare_mrcfile(emd3001_path)
    end

    @testset "emd_3197" begin
        emd3197_path = "$(@__DIR__)/testdata/emd_3197.map"
        compare_mrcfile(emd3197_path)
    end
end
