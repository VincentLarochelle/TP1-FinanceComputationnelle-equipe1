using Distributions
using Plots
using Statistics
using HypothesisTests


# Algorithme Zombie Gap pour simuler des temps d'arrivée approximativement exponentiels

function zombie_gap(w, n)
    arrivee = Int[]
    
    for i in 1:n
        compteur = 0
        while true
            compteur += 1
            U = rand()  # U ∼ U(0, 1)
            if U < w
                push!(arrivee, compteur)
                break
            end
        end
    end
    return arrivee
end

w = 0.1
n = 100000
temps = zombie_gap(w, n)
temps_moyen = mean(temps)
print("temps_moyen : ", temps_moyen, " (devrait être ≈ ", 1/w, ")")