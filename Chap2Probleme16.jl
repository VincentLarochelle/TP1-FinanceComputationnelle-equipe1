# Problème 16 du chapitre 2

using Plots
using Statistics
using Random

# Fonction pour générer des points uniformes et calculer les distances inter-points
function distances_uniformes(n::Int, nb_simulations::Int)
    toutes_distances = Float64[]
    
    for _ in 1:nb_simulations
        # Générer n points uniformes dans [0,1]
        points = rand(n)
        # Trier les points
        points_tries = sort(points)
        # Calculer les distances entre points consécutifs
        for i in 1:(length(points_tries)-1)
            distance = points_tries[i+1] - points_tries[i]
            push!(toutes_distances, distance)
        end
    end
    
    return toutes_distances
end

# Fonction pour générer des temps exponentiels conditionnés à avoir exactement n événements dans [0,1]
function distances_exponentielles_conditionnees(λ::Float64, n::Int, nb_simulations::Int)
    toutes_distances = Float64[]
    taux_rejet = 0.0
    total_tentatives = 0
    
    for _ in 1:nb_simulations
        accepte = false
        tentatives = 0
        
        while !accepte
            tentatives += 1
            total_tentatives += 1
            
            # Générer des temps exponentiels jusqu'à dépasser 1
            temps = Float64[]
            temps_cumulatif = 0.0
            evenements = 0
            
            while temps_cumulatif <= 1.0 && evenements <= n
                temps_inter = randexp() / λ
                temps_cumulatif += temps_inter
                if temps_cumulatif <= 1.0
                    push!(temps, temps_inter)
                    evenements += 1
                end
            end
            
            # Vérifier si on a exactement n événements
            if length(temps) == n
                accepte = true
                # Ajouter les distances à la liste
                for dist in temps
                    push!(toutes_distances, dist)
                end
            end
        end
        
        taux_rejet += (tentatives - 1) / tentatives
    end
    
    taux_rejet_moyen = taux_rejet / nb_simulations
    return toutes_distances, taux_rejet_moyen, total_tentatives
end

# Méthode alternative plus efficace utilisant la propriété des processus de Poisson
function distances_exponentielles_efficace(λ::Float64, n::Int, nb_simulations::Int)
    toutes_distances = Float64[]
    
    for _ in 1:nb_simulations
        # Générer n+1 points uniformes dans [0,1] et les trier
        points_uniformes = rand(n + 1)
        # Trier manuellement (au lieu d'utiliser sort)
        for i in 1:n
            for j in i+1:n+1
                if points_uniformes[i] > points_uniformes[j]
                    # Échanger les valeurs
                    temp = points_uniformes[i]
                    points_uniformes[i] = points_uniformes[j]
                    points_uniformes[j] = temp
                end
            end
        end
        
        # Calculer les écarts entre points consécutifs
        ecarts = Float64[]
        somme_ecarts = 0.0
        for i in 1:n
            ecart = points_uniformes[i+1] - points_uniformes[i]
            push!(ecarts, ecart)
            somme_ecarts += ecart
        end
        
        # Normaliser pour que la somme soit 1
        for i in 1:length(ecarts)
            ecarts[i] = ecarts[i] / somme_ecarts
        end
        
        # Ajouter les distances
        for dist in ecarts
            push!(toutes_distances, dist)
        end
    end
    
    return toutes_distances
end

# Fonction pour calculer la moyenne manuellement
function calculer_moyenne(valeurs)
    if length(valeurs) == 0
        return 0.0
    end
    return sum(valeurs) / length(valeurs)
end

# Fonction pour calculer l'écart-type manuellement
function calculer_ecart_type(valeurs)
    if length(valeurs) <= 1
        return 0.0
    end
    moyenne = calculer_moyenne(valeurs)
    somme_carres = 0.0
    for val in valeurs
        somme_carres += (val - moyenne)^2
    end
    return sqrt(somme_carres / (length(valeurs) - 1))
end

# Fonction pour comparer les deux distributions
function comparer_distributions(n::Int, λ::Float64, nb_simulations::Int)
    println("=== Comparaison des distributions ===")
    println("Nombre d'événements: n = $n")
    println("Paramètre exponentiel: λ = $λ")
    println("Nombre de simulations: $nb_simulations")
    
    # Distribution uniforme
    println("\n1. Génération des points uniformes...")
    distances_unif = distances_uniformes(n, nb_simulations)
    
    # Distribution exponentielle conditionnée (méthode par rejet)
    println("2. Génération des temps exponentiels conditionnés (méthode rejet)...")
    distances_exp, taux_rejet, total_tentatives = distances_exponentielles_conditionnees(λ, n, nb_simulations)
    
    println("   Taux de rejet: $(round(taux_rejet * 100, digits=2))%")
    println("   Tentatives totales: $total_tentatives")
    println("   Efficacité: $(round(nb_simulations/total_tentatives * 100, digits=2))%")
    
    # Distribution exponentielle conditionnée (méthode efficace)
    println("3. Génération des temps exponentiels conditionnés (méthode efficace)...")
    distances_exp_eff = distances_exponentielles_efficace(λ, n, nb_simulations)
    
    # Statistiques descriptives
    println("\n=== Statistiques descriptives ===")
    println("Uniforme - Moyenne: $(round(calculer_moyenne(distances_unif), digits=6)), Écart-type: $(round(calculer_ecart_type(distances_unif), digits=6))")
    println("Exponentiel (rejet) - Moyenne: $(round(calculer_moyenne(distances_exp), digits=6)), Écart-type: $(round(calculer_ecart_type(distances_exp), digits=6))")
    println("Exponentiel (efficace) - Moyenne: $(round(calculer_moyenne(distances_exp_eff), digits=6)), Écart-type: $(round(calculer_ecart_type(distances_exp_eff), digits=6))")
    println("Théorique - Moyenne attendue: $(round(1/n, digits=6))")
    
    # Tracer les histogrammes comparatifs
    p1 = histogram(distances_unif, bins=50, alpha=0.6, label="Points uniformes", 
                  xlabel="Distance inter-événements", ylabel="Densité",
                  title="Distribution des distances (n=$n)", normalize=:pdf)
    
    histogram!(p1, distances_exp, bins=50, alpha=0.6, label="Exponentiel conditionné (rejet)")
    histogram!(p1, distances_exp_eff, bins=50, alpha=0.6, label="Exponentiel conditionné (efficace)")
    
    # Tracer la distribution théorique exponentielle
    max_val = maximum([maximum(distances_unif), maximum(distances_exp), maximum(distances_exp_eff)])
    x = range(0, max_val, length=100)
    densite_exp = λ * exp.(-λ * x)
    plot!(p1, x, densite_exp, linewidth=2, color=:black, label="Exponentielle théorique E($λ)")
    
    # Tracer les fonctions de répartition
    p2 = plot(xlabel="Distance", ylabel="Probabilité cumulée", 
             title="Fonctions de répartition comparées")
    
    # CDF empirique pour points uniformes
    sorted_unif = sort(distances_unif)
    ecdf_unif = [i/length(sorted_unif) for i in 1:length(sorted_unif)]
    plot!(p2, sorted_unif, ecdf_unif, label="Points uniformes", linewidth=2)
    
    # CDF empirique pour exponentiel conditionné
    sorted_exp = sort(distances_exp)
    ecdf_exp = [i/length(sorted_exp) for i in 1:length(sorted_exp)]
    plot!(p2, sorted_exp, ecdf_exp, label="Exponentiel conditionné", linewidth=2)
    
    # CDF théorique exponentielle
    cdf_theorique = 1 .- exp.(-λ * x)
    plot!(p2, x, cdf_theorique, label="Exponentielle théorique", linewidth=2, color=:black)
    
    # Afficher les graphiques
    plot(p1, p2, layout=(2,1), size=(800,600))
    
    return distances_unif, distances_exp, distances_exp_eff
end

# Fonction pour analyser la dépendance au paramètre λ
function analyser_dependance_λ(n::Int, nb_simulations::Int)
    λ_values = [10.0, 30.0, 50.0, 70.0, 100.0]
    taux_rejet = Float64[]
    
    for λ in λ_values
        println("\nAnalyse pour λ = $λ")
        _, taux, _ = distances_exponentielles_conditionnees(λ, n, min(100, nb_simulations))
        push!(taux_rejet, taux)
        println("Taux de rejet: $(round(taux * 100, digits=2))%")
    end
    
    plot(λ_values, taux_rejet, marker=:circle, linewidth=2,
         xlabel="Paramètre λ", ylabel="Taux de rejet",
         title="Efficacité de la méthode par rejet en fonction de λ (n=$n)",
         label="Taux de rejet")
end

# Fonction principale
function main()
    # Paramètres
    n = 50
    λ = 50.0  # Paramètre pour avoir en moyenne 50 événements dans [0,1]
    nb_simulations = 1000
    
    # Comparer les distributions
    distances_unif, distances_exp, distances_exp_eff = comparer_distributions(n, λ, nb_simulations)
    
    # Analyser la dépendance au paramètre λ
    analyser_dependance_λ(n, nb_simulations)
    
    println("\n=== Conclusion ===")
    println("Les points uniformément distribués donnent des distances inter-arrivées")
    println("plus régulières, tandis que les processus exponentiels conditionnés")
    println("conservent leur caractère aléatoire exponentiel même lorsqu'on")
    println("conditionne sur le nombre total d'événements.")
    println("\nLa méthode par rejet est très inefficace (taux de rejet élevé)")
    println("car la probabilité d'avoir exactement n événements est faible.")
    println("La méthode efficace utilise la propriété que les temps d'arrivée")
    println("d'un processus de Poisson conditionné à avoir n événements dans [0,1]")
    println("sont distribués comme les statistiques d'ordre de n variables uniformes.")
end

# Exécuter le programme
Random.seed!(123)  # Pour la reproductibilité
main()