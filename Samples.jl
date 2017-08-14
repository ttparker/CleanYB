const titleN = "N = 2116"
const L = "L46"
const files = [("Block1", "1.0"), ("Block2", "1.2"), ("Block3", "1.4"), ("Block3", "1.5"), ("Block3", "1.56"), ("Block4", "1.6"), ("Block4", "1.7"), ("Block5", "1.8"), ("Block5", "2.0")]
const nSteps = 500

using Plots
pyplot()
Plots.scalefontsizes(1.3)

for file in files
  # read in psis:
  psis = Vector{Complex{Float64}}()  # scope must be the main for loop
  f = open("Data/" * L * "/" * file[1], "r")
  while !eof(f)
    line = readline(f)
    if line == "T: " * file[2] * "\n"
      readline(f)  # "Energies:"
      readline(f)  # energies
      readline(f)  # "Psis:"
      psis = eval.(parse.(split(readline(f), ", ")))
      break
    end
  end
  close(f)

  # select psis:
  stepSize = div(length(psis), nSteps)
  selectedPsis = psis[stepSize:stepSize:length(psis)]

  # plot selected psis:
  plot(Plots.partialcircle(0, 2 * pi, 100, 1.), xlims = (-1, 1), ylims = (-1, 1), label = "", seriescolor = :grey, aspect_ratio = :equal, xlabel = "Re \$\\psi\$", ylabel = "Im \$\\psi\$", title = "Order parameter samples\nfor clean system in in-plane phase\n" * titleN * ", T = " * file[2])
  plot!(real(selectedPsis), imag(selectedPsis), seriestype = :scatter, label = "")
  mkpath("Samples")
  savefig("Samples/" * L * "T" * file[2] * ".png")
  println("T = " * file[2] * " analyzed")
end
