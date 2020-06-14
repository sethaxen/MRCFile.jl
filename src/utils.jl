"""
    hostbyteorder() -> ByteOrder

Get the byte order for this machine.
"""
hostbyteorder() = ifelse(Base.ENDIAN_BOM == 0x04030201, LittleEndian, BigEndian)

"""
    machstfrombyteorder(order = hostbyteorder()) -> Base.CodeUnits{UInt8,String}

Get the default machine stamp for the passed byte order.
"""
function machstfrombyteorder(order::ByteOrder = hostbyteorder())
    return ifelse(order == LittleEndian, MACHINE_STAMP_LITTLE, MACHINE_STAMP_BIG)
end

"""
    byteorderfrommachst(machst) -> ByteOrder

Get the byte order from machine stamp.
"""
function byteorderfrommachst(machst)
    return if machst[1] == MACHINE_STAMP_LITTLE[1] && (
        machst[2] == MACHINE_STAMP_LITTLE[2] || machst[2] == MACHINE_STAMP_LITTLE_ALT[2]
    )
        LittleEndian
    elseif machst[1] == MACHINE_STAMP_BIG[1] && machst[2] == MACHINE_STAMP_BIG[2]
        BigEndian
    else
        throw(DomainError("Unrecognized machine stamp $(machst)"))
    end
end

function bswaptoh(order::ByteOrder)
    return ifelse(order == LittleEndian, maybeswap(ltoh), maybeswap(ntoh))
end
bswaptoh(machst) = bswaptoh(byteorderfrommachst(machst))

function bswapfromh(order::ByteOrder)
    return ifelse(order == LittleEndian, maybeswap(htol), maybeswap(hton))
end
bswapfromh(machst) = bswapfromh(byteorderfrommachst(machst))

maybeswap(fswap, x) = x
maybeswap(fswap, x::Number) = fswap(x)
maybeswap(fswap, x::NTuple{N,Number}) where {N} = ntuple(i -> fswap(x[i]), Val{N}())
maybeswap(fswap) = x -> maybeswap(fswap, x)

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
