# Problème 13 du chapitre 1

function simulation_hiv_test()
    precision_test = 0.98
    taux_population_hiv = 0.03
    nbr_simulations = 100000
    vrai_positifs = 0
    faux_positifs = 0
    total_positifs = 0

    for i in 1:nbr_simulations
        hiv_positif = rand() < taux_population_hiv

        if hiv_positif
            test_positif = rand() < precision_test
        else
            test_positif = rand() < (1-precision_test)
        end

        if test_positif
            total_positifs += 1

            if hiv_positif
                vrai_positifs += 1
            else
                faux_positifs += 1
            end
        end
    end

    if total_positifs > 0
        probabilite = vrai_positifs / total_positifs
    else
        probabilite = 0.0
    end

    return probabilite, vrai_positifs, faux_positifs, total_positifs
end


nb_simulations = 100000
prob, vrai_po, faux_po, total_po = simulation_hiv_test()

println("Résultats de la simulation pour le HIV test")
println("Nombre de simulations effectuées :", nb_simulations)
println("Tests vrai positifs :", vrai_po)
println("Tests faux positifs :", faux_po)
println("Total des tests positifs :", total_po)
println("Probabilité qu'une personne avec un test positif ait le HIV :", 
        round(prob *100, digits=2), "%")





