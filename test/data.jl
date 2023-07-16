@testset "MRCData" begin
    @testset "MRCData(header, extendedheader, data)" begin
        h = MRCHeader()  
        eh = MRCExtendedHeader()
        data = Array{Float32, 3}(undef, (2, 2, 2))
        d = MRCData(h, eh, data)
        @test d.header === h
        @test d.extendedheader === eh
        @test d.data === data
        @test eltype(d) === Float32
        @test ndims(d) === 3
    end

    @testset "MRCData(header, extendedheader)" begin
        h = MRCHeader()  
        eh = MRCExtendedHeader()
        d = MRCData(h, eh)
        @test d.header === h
        @test d.extendedheader === eh
        @test ndims(d) == ndims(h)
        @test size(d) == size(h)
    end

    @testset "MRCData(size::NTuple{3,<:Integer})" begin
        d = MRCData((10, 20, 30))
        @test size(d) == (10, 20, 30)
        @test size(d.data) == (10, 20, 30)
        @test ndims(d) == 3
        @test ndims(d.data) == 3

        @testset "header(d::MRCData)" begin
            h = header(d)
            @test h.nx == 10
            @test h.ny == 20
            @test h.nz == 30
        end
    end
    
    @testset "MRCData(size::Integer...)" begin
        d1 = MRCData(10, 20, 30)
        d2 = MRCData((10, 20, 30))
        @test size(d1) == size(d2)
    end

    data = fill(1f0, (2, 2, 2))
    h = MRCHeader() 
    eh = MRCExtendedHeader()
    d = MRCData(h, eh, data)

    @testset "getindex" begin
        @test d[1, 1, 1] == 1.0f0
        @test d[2, 1, 1] == 1.0f0
        @test d[1, 2, 1] == 1.0f0
        @test d[2, 2, 1] == 1.0f0
        @test d[1, 1, 2] == 1.0f0
        @test d[2, 1, 2] == 1.0f0
        @test d[1, 2, 2] == 1.0f0
        @test d[2, 2, 2] == 1.0f0
    end
    
    @testset "setindex!" begin
        d[1, 1, 1] = 10
        d[2, 1, 1] = 20
        d[1, 2, 1] = 30
        d[2, 2, 1] = 40
        d[1, 1, 2] = 50
        d[2, 1, 2] = 60
        d[1, 2, 2] = 70
        d[2, 2, 2] = 80
        @test d[1, 1, 1] == 10
        @test d[2, 1, 1] == 20
        @test d[1, 2, 1] == 30
        @test d[2, 2, 1] == 40
        @test d[1, 1, 2] == 50
        @test d[2, 1, 2] == 60
        @test d[1, 2, 2] == 70
        @test d[2, 2, 2] == 80
    end
    
    @testset "size" begin
        @test size(d) == (2, 2, 2)
        @test size(d, 1) == 2
        @test size(d, 2) == 2
        @test size(d, 3) == 2
    end
    
    @testset "ndims" begin
        @test ndims(d) == 3
    end
    
    @testset "length" begin
        @test length(d) == 8
    end
    
    @testset "iterate" begin
        iter = iterate(d)
        @test iter !== nothing && first(iter) == 10
    end
    
    @testset "lastindex" begin
        @test lastindex(d) == 8
    end

    @testset "similar" begin
        d_similar = similar(d)
        @test typeof(d_similar) === typeof(d)
        @test size(d_similar) == size(d)
        @test eltype(d_similar) == eltype(d)
    end

    @testset "IndexStyle" begin
        @test Base.IndexStyle(typeof(d)) == Base.IndexStyle(typeof(d.data))
    end
end

@testset "updateheader!(d::MRCData; statistics=true)" begin
    data = fill(1f0, (2, 2, 2))
    h = MRCHeader()  
    @test h.nx == 0
    @test h.ny == 0
    @test h.nz == 0
    eh = MRCExtendedHeader()
    d = MRCData(h, eh, data)
    updateheader!(d)
    @test d.header.dmin == 1.0f0
    @test d.header.dmax == 1.0f0
    @test d.header.dmean == 1.0f0
    @test d.header.rms == 0.0f0
    @test d.header.nx == 2
    @test d.header.ny == 2
    @test d.header.nz == 2
end