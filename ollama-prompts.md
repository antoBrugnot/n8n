# 🤖 Exemples de Prompts Ollama pour l'Assistance Utilisateurs

## 📧 Analyse d'emails d'assistance

### Prompt d'analyse général
```
Analyse cet email d'assistance et extrait les informations suivantes au format JSON:
- problème: (description du problème)
- urgence: (faible/moyenne/haute)
- catégorie: (technique/compte/facturation/autre)
- sentiment: (positif/neutre/négatif)
- mots_cles: [liste des mots-clés importants]

Email: "{contenu_email}"
```

### Prompt de classification automatique
```
Classe cet email d'assistance dans une de ces catégories:
1. TECHNIQUE - problèmes techniques, bugs, configurations
2. COMPTE - création, modification, suppression de compte
3. FACTURATION - questions de paiement, factures, abonnements
4. FONCTIONNALITE - demandes de nouvelles fonctionnalités
5. AUTRE - tout autre sujet

Réponds uniquement par le nom de la catégorie.

Email: "{contenu_email}"
```

## 📝 Génération de réponses

### Prompt de réponse professionnelle
```
Rédige une réponse professionnelle et bienveillante à cet email d'assistance.
La réponse doit être:
- Polie et empathique
- En français
- Structurée avec une salutation, corps du message, et formule de politesse
- Proposer des solutions concrètes si possible

Email original: "{contenu_email}"

Informations contextuelles:
- Nom du client: {nom_client}
- Type de problème: {type_probleme}
- Urgence: {niveau_urgence}
```

### Prompt pour réponse rapide
```
Génère une réponse courte et directe pour cet email d'assistance.
Maximum 3 phrases. Ton professionnel mais chaleureux.

Email: "{contenu_email}"
```

## 🎯 Prompts spécialisés

### Escalade automatique
```
Détermine si cet email nécessite une escalade vers un technicien senior.
Critères d'escalade:
- Problème technique complexe
- Client frustré ou en colère
- Demande de remboursement
- Bug critique signalé

Réponds par OUI ou NON suivi d'une brève justification.

Email: "{contenu_email}"
```

### Extraction d'informations techniques
```
Extrait toutes les informations techniques de cet email:
- Système d'exploitation
- Navigateur
- Version de l'application
- Messages d'erreur
- Étapes pour reproduire le problème

Format de réponse: JSON

Email: "{contenu_email}"
```

### Génération de FAQ
```
Basé sur cet email d'assistance, génère une entrée FAQ avec:
- Question: (formulation claire de la question)
- Réponse: (réponse détaillée étape par étape)
- Mots-clés: (pour la recherche)

Email: "{contenu_email}"
```

## 🔄 Utilisation dans n8n

### Configuration du nœud HTTP Request pour Ollama
- **URL**: `http://ollama:11434/api/generate`
- **Méthode**: POST
- **Headers**: `Content-Type: application/json`
- **Body**:
```json
{
  "model": "{{$env.OLLAMA_MODEL}}",
  "prompt": "{{$prompt_template}}",
  "stream": false,
  "options": {
    "temperature": 0.3,
    "top_p": 0.9
  }
}
```

### Extraction de la réponse
La réponse Ollama contient la génération dans: `{{$json.response}}`

## 💡 Conseils d'optimisation

### Paramètres recommandés
- **Temperature**: 0.3 (réponses plus cohérentes)
- **Top_p**: 0.9 (bon équilibre créativité/précision)
- **Max_tokens**: 500 (pour des réponses concises)

### Bonnes pratiques
1. **Structurer les prompts** avec des instructions claires
2. **Utiliser des exemples** dans les prompts pour de meilleurs résultats
3. **Limiter la longueur** des réponses pour la rapidité
4. **Valider les réponses** avant envoi automatique
5. **Garder un humain dans la boucle** pour les cas complexes
