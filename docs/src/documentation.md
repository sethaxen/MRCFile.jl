# MRCFile documentation

MRCFile.jl implements the [MRC2014 format](https://www.ccpem.ac.uk/mrc_format/mrc2014.php) for storing image and volume data such as those produced by electron microscopy.
It offers the ability to read, edit, and write MRC files, as well as utility functions for extracting useful information from the headers.

The key type is `MRCData`, which contains the contents of the MRC file, accessible with `header` and `extendedheader`.
`MRCData` is an `AbstractArray` whose elements are those of the data portion of the file and can be accessed or modified accordingly.
The `data`, `header` and `extendedheader` are consistent with [mrcfile](https://github.com/ccpem/mrcfile).
Help on individual functions can be found in the API section or by using `?function name` from within Julia.

## Opening MRC files

MRC files can be opened using the `read()` or `read_mmap()` functions. These return an instance of the `MRCData` struct.

```julia
using MRCFile

dmap = read("/path/to/mrc/file.mrc", MRCData)
h = header(dmap)
exh = extendedheader(dmap)

dmin, dmax = extrema(h) 
drange = dmax - dmin
```

It is efficient to load the data as [memory-mapped arrays](https://docs.julialang.org/en/v1/stdlib/Mmap/).

```
# Open the file in memory-mapped mode
dmap = read_mmap("/path/to/mrc/file.mrc", MRCData)
```

## Handling compressed files

All the functions above can also handle `.gz` or `.bz2` compressed files.

```julia
using MRCFile

dmap = read("/path/to/mrc/file.map.gz", MRCData)
# or
dmap = read("/path/to/mrc/file.map.bz2", MRCData)
```

## Write MRC file

MRC files can be saved using the `write()` function.

```julia
write("/path/to/mrc/file.mrc", dmap)
```

## Accessing the header

The variables in header can be accessed using the following variable names, suppose `h=MRCHeader`:

| Variable name   | Access        | Type              |
| :-------------- | :------------ | :---------------- |
| NX              | h.nx          | Int32             |
| NY              | h.ny          | Int32             |
| NZ              | h.nz          | Int32             |
| MODE            | h.mode        | Int32             |
| NXSTART         | h.nxstart     | Int32             |
| NYSTART         | h.nystart     | Int32             |
| NZSTART         | h.nzstart     | Int32             |
| MX              | h.mx          | Int32             |
| MY              | h.my          | Int32             |
| MZ              | h.mz          | Int32             |
| CELLA_X         | h.cella_x     | Float32           |
| CELLA_Y         | h.cella_y     | Float32           |
| CELLA_Z         | h.cella_z     | Float32           |
| CELLB_alpha     | h.cellb_alpha | Float32           |
| CELLB_beta      | h.cellb_beta  | Float32           |
| CELLB_gamma     | h.cellb_gamma | Float32           |
| MAPC            | h.mapc        | Int32             |
| MAPR            | h.mapc        | Int32             |
| MAPS            | h.mapc        | Int32             |
| DMIN            | h.dmin        | Float32           |
| DMAX            | h.dmax        | Float32           |
| DMEAN           | h.dmean       | Float32           |
| ISPG            | h.ispg        | Int32             |
| NSYMBP          | h.nsymbt      | Int32             |
| EXTRA1          | h.extra1      | NTuple{8,UInt8}   |
| EXYTYP          | h.exttyp      | String            |
| NVERSION        | h.nversion    | Int32             |
| EXTRA2          | h.extra1      | NTuple{8,UInt8}   |
| ORIGIN_X        | h.origin_x    | Float32           |
| ORIGIN_Y        | h.origin_y    | Float32           |
| ORIGIN_Z        | h.origin_z    | Float32           |
| MAP             | h.map         | String            |
| MACHST          | h.machst      | NTuple{4,UInt8}   |
| RMS             | h.rms         | Float32           |
| NLABL           | h.nlabl       | Int32             |
| LABEL           | h.label       | NTuple{10,String} |

## Keeping the header and data in sync

Update the header stored in `MRCData` from the data and its extended header.

```julia
updateheader!(dmap)
```
