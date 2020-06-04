byteorder() = ifelse(Base.ENDIAN_BOM == 0x04030201, <, >)

function wrapstream(io::IO)
    magic = read(io, 3)
    seek(io, 0)
    newio = if magic == GZ_MAGIC
        GzipDecompressorStream(io)
    elseif magic == BZ2_MAGIC
        Bzip2DecompressorStream(io)
    else
        io
    end
    return newio
end
