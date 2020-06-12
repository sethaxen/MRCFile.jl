byteorder() = ifelse(Base.ENDIAN_BOM == 0x04030201, <, >)

"""
    padtruncto!(x::AbstractVector, n; value = zero(eltype(x)))

Pad `x` with `value` or truncate it until its length is exactly `n`.
"""
function padtruncto!(x, n; value = zero(eltype(x)))
    l = length(x)
    if l < n
        append!(x, fill(eltype(x)(value), n - l))
    elseif l > n
        resize!(x, n)
    end
    return x
end

function checkmagic(io)
    magic = read(io, 6)
    seek(io, 0)
    return get(TYPE_FROM_MAGIC, magic[1:3], get(TYPE_FROM_MAGIC, magic, :none))
end

checkextension(path) = get(TYPE_FROM_EXTENSION, splitext(path)[end], :none)

function compresstream(io, type)
    return if type == :gz
        GzipCompressorStream(io)
    elseif type == :bz2
        Bzip2CompressorStream(io)
    elseif type == :xz
        XzCompressorStream(io)
    elseif type == :none
        io
    else
        throw(IOError("Unrecognized compression type"))
    end
end

function decompresstream(io, type)
    return if type == :gz
        GzipDecompressorStream(io)
    elseif type == :bz2
        Bzip2DecompressorStream(io)
    elseif type == :xz
        XzDecompressorStream(io)
    elseif type == :none
        io
    else
        throw(IOError("Unrecognized decompression type"))
    end
end
