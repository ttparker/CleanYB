const fileNames = ["L46", "L64", "L90", "L128"]
const zoomTs = [1.6, 1.7, 1.8, 1.9, 2.0]

import JLD
include("CustomTypes.jl")

data = Array{Float64, 3}(length(zoomTs), 2, length(fileNames)) # T, avgType, L

TIndices = Vector{Int64}()
for fileNo in 1:length(fileNames)
  system = JLD.load("Analyzed/" * fileNames[fileNo] * ".jld", fileNames[fileNo])::SystemSummary
  TIndices = findin(system.Ts, zoomTs)
  for TIndexNo in 1:length(TIndices)
    TIndex = TIndices[TIndexNo]
    data[TIndexNo, :, fileNo] = [system.absAvgPsis[TIndex], system.avgAbsPsis[TIndex]]
  end
end
for zoomTIndex in 1:length(zoomTs)
  println("T = ", zoomTs[zoomTIndex], ":\n", data[zoomTIndex, :, :], "\n")
end
