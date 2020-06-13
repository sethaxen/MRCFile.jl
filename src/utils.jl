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
    return get(COMPRESSOR_MAGICS, magic[1:3], get(COMPRESSOR_MAGICS, magic, :none))
end

checkextension(path) = get(COMPRESSOR_EXTENSIONS, splitext(path)[end], :none)

function compressstream(io, type)
    return get(COMPRESSIONS, type, (compressor = NoopStream,)).compressor(io)
end

function decompressstream(io, type)
    return get(COMPRESSIONS, type, (decompressor = NoopStream,)).decompressor(io)
end
