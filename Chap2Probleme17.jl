using Distributions
using Plots
using Statistics
using HypothesisTests


# Algorithme Zombie Gap pour simuler des temps d'arrivée approximativement exponentiels

function zombie_gap_algorithm(w::Float64, n_evenements::Int)
    temps_arrivee = zeros(n_evenements)
    temps_interarrivee = zeros(n_evenements)
    
    temps_actuel = 0
    
    for i in 1:n_evenements
        compteur = 0
        while true
            compteur += 1
            U = rand()  # U ∼ U(0, 1)
            if U < w
                break
            end
        end
        temps_actuel += compteur
        temps_arrivee[i] = temps_actuel
        temps_interarrivee[i] = compteur
    end
    
    return temps_arrivee, temps_interarrivee
end

print('a')
