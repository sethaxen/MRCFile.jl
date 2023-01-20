@testset "hostbyteorder" begin
    if Base.ENDIAN_BOM == 0x04030201
        @test MRCFile.hostbyteorder() == MRCFile.LittleEndian
    else
        @test MRCFile.hostbyteorder() == MRCFile.BigEndian
    end
end

@testset "machstfrombyteorder" begin
    @test MRCFile.machstfrombyteorder() == [0x44, 0x44, 0x00, 0x00]
    @test MRCFile.machstfrombyteorder(MRCFile.LittleEndian) == [0x44, 0x44, 0x00, 0x00]
    @test MRCFile.machstfrombyteorder(MRCFile.BigEndian) == [0x11, 0x11, 0x00, 0x00]
end

@testset "byteorderfrommachst" begin
    @test MRCFile.byteorderfrommachst([0x44, 0x44, 0x00, 0x00]) == MRCFile.LittleEndian
    @test MRCFile.byteorderfrommachst([0x44, 0x41, 0x00, 0x00]) == MRCFile.LittleEndian
    @test MRCFile.byteorderfrommachst([0x11, 0x11, 0x00, 0x00]) == MRCFile.BigEndian
    @test (@test_logs (
        :warn,
        "Unrecognized machine stamp $([0x00, 0x00, 0x00, 0x00]). Assuming little endian.",
    ) MRCFile.byteorderfrommachst([0x00, 0x00, 0x00, 0x00])) == MRCFile.LittleEndian
end

@testset "bswaptoh" begin
    @test MRCFile.bswaptoh(MRCFile.LittleEndian) == MRCFile.maybeswap(ltoh)
    @test MRCFile.bswaptoh(MRCFile.MACHINE_STAMP_LITTLE) == MRCFile.maybeswap(ltoh)
    @test MRCFile.bswaptoh(MRCFile.MACHINE_STAMP_LITTLE_ALT) == MRCFile.maybeswap(ltoh)
    @test MRCFile.bswaptoh(MRCFile.BigEndian) == MRCFile.maybeswap(ntoh)
    @test MRCFile.bswaptoh(MRCFile.MACHINE_STAMP_BIG) == MRCFile.maybeswap(ntoh)
end

@testset "bswapfromh" begin
    @test MRCFile.bswapfromh(MRCFile.LittleEndian) == MRCFile.maybeswap(htol)
    @test MRCFile.bswapfromh(MRCFile.MACHINE_STAMP_LITTLE) == MRCFile.maybeswap(htol)
    @test MRCFile.bswapfromh(MRCFile.MACHINE_STAMP_LITTLE_ALT) == MRCFile.maybeswap(htol)
    @test MRCFile.bswapfromh(MRCFile.BigEndian) == MRCFile.maybeswap(hton)
    @test MRCFile.bswapfromh(MRCFile.MACHINE_STAMP_BIG) == MRCFile.maybeswap(hton)
end

@testset "maybeswap" begin
    @test MRCFile.maybeswap(bswap, Int32(5)) === bswap(Int32(5))
    @test MRCFile.maybeswap(bswap, "foo") === "foo"
    @test MRCFile.maybeswap(bswap, (Int32(5), Int32(6))) === (bswap(Int32(5)), bswap(Int32(6)))
    @test MRCFile.maybeswap(bswap, (0x01, 0x02)) === (0x01, 0x02)
    @test MRCFile.maybeswap(bswap)(Int32(5)) === bswap(Int32(5))
end

@testset "padtruncto!" begin
    x = [1, 2, 3]
    MRCFile.padtruncto!(x, 4)
    @test x == [1, 2, 3, 0]
    MRCFile.padtruncto!(x, 6; value=1)
    @test x == [1, 2, 3, 0, 1, 1]
    MRCFile.padtruncto!(x, 3)
    @test x == [1, 2, 3]
    MRCFile.padtruncto!(x, 5; value=1.0)
    @test x == [1, 2, 3, 1, 1]
end

@testset "compression: $type" for type in keys(MRCFile.COMPRESSIONS)
    spec = getproperty(MRCFile.COMPRESSIONS, type)
    @testset "checkmagic" begin
        io = IOBuffer()
        write(io, spec.magic)
        write(io, [0x01, 0x02, 0x03])
        seek(io, 0)
        type2 = MRCFile.checkmagic(io)
        @test type2 == type
        close(io)
    end

    @testset "checkextension" begin
        fn = "map.mrc$(spec.extension)"
        type2 = MRCFile.checkextension(fn)
        @test type2 == type
    end

    @testset "(de)compressstream" begin
        buf = IOBuffer()
        stream = MRCFile.compressstream(buf, type)
        write(stream, b"foo", TranscodingStreams.TOKEN_END)
        newbuf = IOBuffer(take!(buf))
        @test MRCFile.checkmagic(newbuf) == type
        newstream = MRCFile.decompressstream(newbuf, type)
        @test read(newstream) == b"foo"
    end
end
