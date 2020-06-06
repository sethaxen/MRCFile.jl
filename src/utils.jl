byteorder() = ifelse(Base.ENDIAN_BOM == 0x04030201, <, >)

"""
    smartopen(f::Function, args...; kwargs...)

Open a file and call `f` on the io stream, decompressing if the file has gz or bz2 magic.
"""
function smartopen(f::Function, args...; kwargs...)
    io = open(args...; kwargs...)
    magic = Tuple(read(io, 3))
    seek(io, 0)
    if magic == GZ_MAGIC
        newio = GzipDecompressorStream(io)
        ret = f(newio)
        close(newio)
    elseif magic == BZ2_MAGIC
        newio = Bzip2DecompressorStream(io)
        ret = f(newio)
        close(newio)
    else
        ret = f(io)
    end
    close(io)
    return ret
end
