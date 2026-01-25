using DimensionalData

@testset "DimensionalDataExt" begin
    for (id, dimorder) in (("3001", (:z, :x, :y)), ("3197", (:x, :y, :z)))
        @testset "emd_$id" begin
            mrc = read("$(@__DIR__)/testdata/emd_$id.map", MRCData)
            dimarr = DimArray(mrc)

            @test parent(dimarr) == mrc.data

            axs = NamedTuple{dimorder}(voxelaxes(header(mrc)))
            @test all(CartesianIndices(mrc.data)) do ci
                idcs = NamedTuple{dimorder}(Tuple(ci))
                left = dimarr[
                    X = At(axs.x[idcs.x]), Y = At(axs.y[idcs.y]), Z = At(axs.z[idcs.z])
                ]
                right = mrc.data[ci]
                left == right
            end
        end
    end
end
