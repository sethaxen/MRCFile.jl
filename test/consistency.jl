using Test
using PyCall
using Conda

Conda.pip_interop(true)
Conda.pip("install", ["mrcfile", "numpy"])

# Load the Python module/package
mrcfile = pyimport("mrcfile")
numpy = pyimport("numpy")

@testset "Consistency Test" begin
    function map_test(map_jl::Array{Float32,3}, map_py::Array{Float32,3})
        permuted_py = permutedims(map_py, (3, 2, 1))
        @test map_jl == permuted_py
        # @test map_jl == map_py
    end

    function header_test(header_jl::MRCHeader, header_py::PyObject)
        @test header_jl.nx == convert(Int32, header_py.nx)
        @test header_jl.ny == convert(Int32, header_py.ny)
        @test header_jl.nz == convert(Int32, header_py.nz)
        @test header_jl.mode == convert(Int32, header_py.mode)
        @test header_jl.nxstart == convert(Int32, header_py.nxstart)
        @test header_jl.nystart == convert(Int32, header_py.nystart)
        @test header_jl.nzstart == convert(Int32, header_py.nzstart)
        @test header_jl.mx == convert(Int32, header_py.mx)
        @test header_jl.my == convert(Int32, header_py.my)
        @test header_jl.mz == convert(Int32, header_py.mz)
        @test header_jl.cella_x == convert(Float32, header_py.cella.x)
        @test header_jl.cella_y == convert(Float32, header_py.cella.y)
        @test header_jl.cella_z == convert(Float32, header_py.cella.z)
        @test header_jl.cellb_alpha == convert(Float32, header_py.cellb.alpha)
        @test header_jl.cellb_beta == convert(Float32, header_py.cellb.beta)
        @test header_jl.cellb_gamma == convert(Float32, header_py.cellb.gamma)
        @test header_jl.mapc == convert(Int32, header_py.mapc)
        @test header_jl.mapr == convert(Int32, header_py.mapr)
        @test header_jl.maps == convert(Int32, header_py.maps)
        @test header_jl.dmin == convert(Float32, header_py.dmin)
        @test header_jl.dmax == convert(Float32, header_py.dmax)
        @test header_jl.dmean == convert(Float32, header_py.dmean)
        @test header_jl.ispg == convert(Int32, header_py.ispg)
        @test header_jl.nsymbt == convert(Int32, header_py.nsymbt)
        @test String([UInt8(b) for b in header_jl.extra1]) == convert(String, header_py.extra1.tobytes())
        @test header_jl.exttyp == header_py.exttyp.tostring()
        @test header_jl.nversion == convert(Int32, header_py.nversion)
        @test String([UInt8(b) for b in header_jl.extra2]) == header_py.extra2.tobytes()
        @test header_jl.origin_x == convert(Float32, header_py.origin.x)
        @test header_jl.origin_y == convert(Float32, header_py.origin.y)
        @test header_jl.origin_z == convert(Float32, header_py.origin.z)
        @test header_jl.map == header_py.map.tostring()
        @test collect(header_jl.machst) == convert(Vector{UInt8}, header_py.machst)
        @test header_jl.rms == convert(Float32, header_py.rms)
        @test header_jl.nlabl == convert(Int32, header_py.nlabl)
        @test strip.(collect(header_py.label)) == collect(header_jl.label)
    end

    function exh_test(exh_jl::MRCExtendedHeader, exh_py::PyObject)
        @test String([UInt8(b) for b in exh_jl.data]) == exh_py.tobytes()
    end

    @testset "emd_3001.map" begin
        emd3001_path = "$(@__DIR__)/testdata/emd_3001.map"
        emd3001_jl = read("$(@__DIR__)/testdata/emd_3001.map", MRCData)
        map_jl = emd3001_jl.data
        header_jl = header(emd3001_jl)
        exh_jl = extendedheader(emd3001_jl)

        emd3001_py = mrcfile.open("$(@__DIR__)/testdata/emd_3001.map"; mode="r")
        data_copy = numpy.copy(emd3001_py.data)  # Create a copy of the data
        map_py = convert(Array{Float32,3}, data_copy)
        header_py = emd3001_py.header
        exh_py = emd3001_py.extended_header
        emd3001_py.close()  # Make sure the file is closed even if an error occurs

        @testset "map" begin
            map_test(map_jl, map_py)
        end

        @testset "header" begin
            header_test(header_jl, header_py)
        end

        @testset "extendedheader" begin
            exh_test(exh_jl, exh_py)
        end
    end
end
