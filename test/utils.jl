@testset "hostbyteorder" begin
    if Base.ENDIAN_BOM == 0x04030201
        @test MRC.hostbyteorder() == MRC.LittleEndian
    else
        @test MRC.hostbyteorder() == MRC.BigEndian
    end
end

@testset "machstfrombyteorder" begin
    @test MRC.machstfrombyteorder() == [0x44, 0x44, 0x00, 0x00]
    @test MRC.machstfrombyteorder(MRC.LittleEndian) == [0x44, 0x44, 0x00, 0x00]
    @test MRC.machstfrombyteorder(MRC.BigEndian) == [0x11, 0x11, 0x00, 0x00]
end

@testset "byteorderfrommachst" begin
    @test MRC.byteorderfrommachst([0x44, 0x44, 0x00, 0x00]) == MRC.LittleEndian
    @test MRC.byteorderfrommachst([0x44, 0x41, 0x00, 0x00]) == MRC.LittleEndian
    @test MRC.byteorderfrommachst([0x11, 0x11, 0x00, 0x00]) == MRC.BigEndian
    @test_throws DomainError MRC.byteorderfrommachst([0x00, 0x00, 0x00, 0x00])
end

@testset "bswaptoh" begin
    @test MRC.bswaptoh(MRC.LittleEndian) == maybeswap(ltoh)
    @test MRC.bswaptoh(MRC.MACHINE_STAMP_LITTLE) == maybeswap(ltoh)
    @test MRC.bswaptoh(MRC.MACHINE_STAMP_LITTLE_ALT) == maybeswap(ltoh)
    @test MRC.bswaptoh(MRC.BigEndian) == maybeswap(ntoh)
    @test MRC.bswaptoh(MRC.MACHINE_STAMP_BIG) == maybeswap(ntoh)
end

@testset "bswapfromh" begin
    @test MRC.bswapfromh(MRC.LittleEndian) == maybeswap(htol)
    @test MRC.bswapfromh(MRC.MACHINE_STAMP_LITTLE) == maybeswap(htol)
    @test MRC.bswapfromh(MRC.MACHINE_STAMP_LITTLE_ALT) == maybeswap(htol)
    @test MRC.bswapfromh(MRC.BigEndian) == maybeswap(hton)
    @test MRC.bswapfromh(MRC.MACHINE_STAMP_BIG) == maybeswap(hton)
end

@testset "maybeswap" begin
    @test MRC.maybeswap(bswap, Int32(5)) === bswap(Int32(5))
    @test MRC.maybeswap(bswap, "foo") === "foo"
    @test MRC.maybeswap(bswap, (Int32(5), Int32(6))) === (bswap(Int32(5)), bswap(Int32(6)))
    @test MRC.maybeswap(bswap, (0x01, 0x02)) === (0x01, 0x02)
    @test MRC.maybeswap(bswap)(Int32(5)) === bswap(Int32(5))
end

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

@testset "compression: $type" for type in keys(MRC.COMPRESSIONS)
    spec = getproperty(MRC.COMPRESSIONS, type)
    @testset "checkmagic" begin
        io = IOBuffer()
        write(io, spec.magic)
        write(io, [0x01, 0x02, 0x03])
        seek(io, 0)
        type2 = MRC.checkmagic(io)
        @test type2 == type
        close(io)
    end

    @testset "checkextension" begin
        fn = "map.mrc$(spec.extension)"
        type2 = MRC.checkextension(fn)
        @test type2 == type
    end

    @testset "(de)compressstream" begin
        buf = IOBuffer()
        stream = MRC.compressstream(buf, type)
        write(stream, b"foo", TranscodingStreams.TOKEN_END)
        newbuf = IOBuffer(take!(buf))
        @test MRC.checkmagic(newbuf) == type
        newstream = MRC.decompressstream(newbuf, type)
        @test read(newstream) == b"foo"
    end
end
