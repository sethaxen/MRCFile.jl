using MRC
using Documenter

makedocs(;
    modules=[MRC],
    authors="Seth Axen <seth.axen@gmail.com> and contributors",
    sitename="MRC.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://sethaxen.github.io/MRC.jl",
        assets=String[],
    ),
    pages=["Home" => "index.md", "API" => "api.md"],
)

deploydocs(; repo="github.com/sethaxen/MRC.jl")
