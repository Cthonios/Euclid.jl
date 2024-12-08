using Documenter
using Euclid

DocMeta.setdocmeta!(Euclid, :DocTestSetup, :(using Euclid); recursive=true)

makedocs(;
  # modules=[Cthonios],
  authors="Craig M. Hamel <cmhamel32@gmail.com> and contributors",
  repo="https://github.com/Cthonios/Euclid.jl/blob/{commit}{path}#{line}",
  source="src",
  sitename="Euclid.jl",
  format=Documenter.HTML(;
    repolink="https://github.com/Cthonios/Euclid.jl",
    prettyurls=get(ENV, "CI", "false") == "true",
    canonical="https://cthonios.github.io/Euclid.jl",
    edit_link="main",
    assets=String[],
    size_threshold_warn=5 * 102400,
    size_threshold=10 * 102400
    # size_threshold_ignore=[
    #   "./generated/hole_array.md"
    # ],
  ),
  pages=[
    "Home"                  => "index.md"
    "Affine Transformation" => "affine.md"
    "Boolean Operations"    => "boolean.md"
    "Geometric Primitives"  => [
      "0-Dimensional Primitives" => "primitives_0D.md"
      "1-Dimensional Primitives" => "primitives_1D.md"
      "2-Dimensional Primitives" => "primitives_2D.md"
      "3-Dimensional Primitives" => "primitives_3D.md"
    ]
    "Internals"             => [
      "Abstract types" => "abstract.md"
    ]
  ],
)

deploydocs(;
  repo="github.com/Cthonios/Euclid.jl",
  devbranch="main",
)
