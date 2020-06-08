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

"""
    smartopen(f::Function, args...; kwargs...)

Open a file and call `f` on the io stream, decompressing if the file appears to be gz or bz2.
"""
function smartopen(f::Function, args...; read = false, write = false, kwargs...)
    return if read
        io = open(args...; read = read, write = write)
        magic = Tuple(Base.read(io, 3))
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
        ret
    elseif args[1] isa AbstractString && write
        io = open(args...; read = read, write = write)
        path = args[1]
        if endswith(path, ".gz")
            newio = GzipCompressorStream(io)
            ret = f(newio)
            close(newio)
        elseif endswith(path, ".bz2")
            newio = Bzip2CompressorStream(io)
            ret = f(newio)
            close(newio)
        else
            ret = f(io)
        end
        close(io)
        ret
    else
        open(f, args...; read = read, write = write)
    end
end
