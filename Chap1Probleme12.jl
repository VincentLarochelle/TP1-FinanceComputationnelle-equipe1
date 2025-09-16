# Problème 12 du chapitre 1

using Plots

function jeu_craps()  # fonction pour faire le jeu craps
    de1 = rand(1:6)
    de2 = rand(1:6)
    total = de1 + de2

    if total == 7 || total == 11
        return "WIN"
    elseif total == 2 || total == 3 || total == 12
        return "LOSE"
    else
        point == total

        while true
            de1 = rand(1:6)
            de2 = rand(1:6)
            total = de1 + de2
            
            if total == 7
                return "LOSE"
            elseif total == point
                return "WIN"
            end
        end
    end
end


function simulation_craps()
    nombre_simulations = 1000
    resultats = string[]
    victoires = 0
    défaites = 0

    for i in 1:nombre_simulations
        resultat = jeu_craps
        push!(resultats, resultat)

