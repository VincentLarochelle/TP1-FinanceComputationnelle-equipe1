# Problème 9 du chapitre 2

using Plots, Statistics

# Fonction principale de simulation
function simuler_minimum(N::Int, nb_sim::Int)
    [minimum(rand(N)) for _ in 1:nb_sim]
end

# Fonction pour créer un histogramme
function creer_histo(donnees, N::Int, titre::String, couleur)
    histo = histogram(donnees, bins=25, alpha=0.7, color=couleur, linewidth=2, linecolor=:black,
                     xlabel="Valeur du minimum", ylabel="Densité", title=titre, normalize=:pdf)
    
    moy_sim, moy_theo = mean(donnees), 1/(N+1)
    vline!([moy_sim], linewidth=2, color=:red, label="Moyenne simulée $(round(moy_sim, digits=4))")
    vline!([moy_theo], linewidth=2, color=:green, label="Moyenne théorique $(round(moy_theo, digits=4))")
    return histo
end

# Fonction pour histogrammes multiples
function histogrammes_multiples()
    valeurs_N = [2, 5, 10, 20, 50]
    plots = []
    
    for (i, N) in enumerate(valeurs_N)
        donnees = simuler_minimum(N, 3000)
        p = histogram(donnees, bins=15, title="N=$N", normalize=:pdf, color=i, alpha=0.6, label=false)
        plot!(p, xlabel="Minimum", ylabel="Densité")
        push!(plots, p)
    end
    return plot(plots..., layout=(length(valeurs_N), 1), size=(800, 1000))
end

# Fonction pour afficher les données
function afficher_stats()
    valeurs_N = [2, 5, 10, 20, 50]
    println("N  | Moyenne simulée | Moyenne théorique | Écart-type | Rapport")
    println("-"^65)
    
    for N in valeurs_N
        donnees = simuler_minimum(N, 5000)
        moy_sim, moy_theo = mean(donnees), 1/(N+1)
        println(lpad(N, 2), " | ", lpad(round(moy_sim, digits=4), 15), " | ", 
                lpad(round(moy_theo, digits=4), 17), " | ", 
                lpad(round(std(donnees), digits=4), 10), " | ", 
                round(moy_sim/moy_theo, digits=4))
    end
end

# Fonction principale
function chap2probleme9()
    N, nb_sim = 10, 10000
    donnees = simuler_minimum(N, nb_sim)
    
    # Graphiques
    display(creer_histo(donnees, N, "Histogramme du minimum - N=$N", :lightblue))
    display(histogrammes_multiples())
    
    # Statistiques
    println("\nSTATISTIQUES POUR N = $N:")
    println("Moyenne simulée: $(round(mean(donnees), digits=6))")
    println("Moyenne théorique: $(round(1/(N+1), digits=6))")
    println("Écart-type: $(round(std(donnees), digits=6))")
    
    # Données pour différents N
    afficher_stats()
end

# Exécuter
chap2probleme9()