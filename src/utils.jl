byteorder() = ifelse(Base.ENDIAN_BOM == 0x04030201, <, >)

"""
    padtruncto!(x::AbstractVector, n; value)

Pad `x` with `value` or truncate it until its length is exactly `n`.
"""
function padtruncto!(x, n; value = zero(eltype(x)))
    l = length(x)
    if l < n
        append!(x, fill(value, n - l))
    elseif l > n
        resize!(x, n)
    end
    return x
end

function checkmagic(io)
    magic = Base.read(io, 3)
    seek(io, 0)
    return if magic == GZ_MAGIC
        :gz
    elseif magic == BZ2_MAGIC
        :bz2
    else
        :none
    end
end

function checkextension(path)
    return if endswith(path, ".gz")
        :gz
    elseif endswith(path, ".bz2")
        :bz2
    else
        :none
    end
end

function compresstream(io, type)
    return if type == :gz
        GzipCompressorStream(io)
    elseif type == :bz2
        Bzip2CompressorStream(io)
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
    elseif type == :none
        io
    else
        throw(IOError("Unrecognized decompression type"))
    end
end

"""
    smartopen(f::Function, args...; kwargs...)

Open a file and call `f` on the io stream, decompressing if the file appears to be gz or bz2.
"""
function smartopen(f::Function, args...; read = false, write = false, kwargs...)
    if read
        io = open(args...; read = read, write = write)
        type = checkmagic(io)
        newio = decompresstream(io, type)
        ret = f(newio)
        close(io)
    elseif args[1] isa AbstractString && write
        path = args[1]
        type = checkextension(path)
        io = open(args...; read = read, write = write)
        newio = compresstream(io, type)
        ret = f(newio)
        close(io)
    else
        ret = open(f, args...; read = read, write = write)
    end
    return ret
end
