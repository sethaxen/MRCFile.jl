# MRCFile

MRCFile.jl implements the [MRC2014 format](https://www.ccpem.ac.uk/mrc_format/mrc2014.php) for storing image and volume data such as those produced by electron microscopy.
It offers the ability to read, edit, and write MRC files, as well as utility functions for extracting useful information from the headers.

The key type is `MRCData`, which contains the contents of the MRC file, accessible with `header` and `extendedheader`.
`MRCData` is an `AbstractArray` whose elements are those of the data portion of the file and can be accessed or modified accordingly.
