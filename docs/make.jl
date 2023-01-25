using MRCFile
using Documenter

makedocs(;
    modules=[MRCFile],
    authors="Seth Axen <seth.axen@gmail.com> and contributors",
    sitename="MRCFile.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://sethaxen.github.io/MRCFile.jl",
        assets=String[],
    ),
    pages=["Home" => "index.md", "API" => "api.md"],
)

deploydocs(; repo="github.com/sethaxen/MRCFile.jl", devbranch="main")
