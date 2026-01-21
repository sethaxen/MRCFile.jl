using DimensionalData

@testset "DimensionalDataExt" begin
    emd3001 = read("$(@__DIR__)/testdata/emd_3001.map", MRCData)
    dimarr = DimArray(emd3001)

    @test parent(dimarr) == emd3001.data

    ax_z, ax_x, ax_y = voxelaxes(header(emd3001))
    @test all(CartesianIndices(emd3001.data)) do ci
        iz, ix, iy = Tuple(ci)
        left = dimarr[X = At(ax_x[ix]), Y = At(ax_y[iy]), Z = At(ax_z[iz])]
        right = emd3001.data[iz, ix, iy]
        left == right
    end
end
