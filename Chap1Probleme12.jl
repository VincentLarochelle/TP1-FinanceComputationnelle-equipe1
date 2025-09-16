# Problème 12 du chapitre 1

function jeu_craps()  # fonction pour faire le jeu craps
    de1 = rand(1:6)
    de2 = rand(1:6)
    total = de1 + de2

    if total == 7 || total == 11
        return "WIN"
    elseif total == 2 || total == 3 || total == 12
        return "LOSE"
    else
        point = total

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
    resultats = String[]
    victoires = 0
    defaites = 0

    for i in 1:nombre_simulations
        resultat = jeu_craps()
        push!(resultats, resultat)

        if resultat == "WIN"
            victoires += 1

        else 
            defaites += 1
        end
    end
    return resultats, victoires, defaites
end

resultats, victoires, defaites = simulation_craps()

println("Résultats de la simulation pour le jeu de Craps")
println("Victoires obtenues : ", victoires)
println("Défaites obtenues : ", defaites)


affichage = ["WIN", "LOSE"]
donnees = [victoires, defaites]

bar(affichage, donnees, title = "Résultats de la simulation pour le jeu de Craps",
    xlabel = "Résultat", ylabel = "Nombre de parties")