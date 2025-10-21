# Intégration Ollama avec calendar-cli

Cette extension permet d'ajouter des événements et des tâches à calendar-cli en utilisant le **langage naturel**, grâce à [Ollama](https://ollama.ai/).

## 🚀 Fonctionnalités

- ✅ **Langage naturel** : Ajoutez des événements en parlant naturellement
- ✅ **Support vocal** : Parlez directement pour créer vos rendez-vous (optionnel)
- ✅ **IA locale** : Utilise Ollama pour garder vos données privées
- ✅ **Support multilingue** : Français, Anglais, etc.
- ✅ **Événements et tâches** : Gère les deux types automatiquement

## 📋 Prérequis

### 1. Installer Ollama

Téléchargez et installez Ollama depuis [ollama.ai](https://ollama.ai/)

```bash
# Linux
curl -fsSL https://ollama.ai/install.sh | sh

# macOS
brew install ollama

# Windows
# Téléchargez depuis https://ollama.ai/download
```

### 2. Démarrer Ollama

```bash
ollama serve
```

### 3. Télécharger un modèle

```bash
# Modèle recommandé (léger et performant)
ollama pull llama2

# Alternative : modèles plus puissants
ollama pull llama2:13b
ollama pull mistral
ollama pull mixtral
```

### 4. Installer les dépendances Python

```bash
# Dépendance requise
pip install requests

# Optionnel : pour le mode vocal
pip install SpeechRecognition pyaudio
```

## 🎯 Utilisation

### Mode texte (recommandé)

```bash
# Événements
calendar-ai "Rendez-vous dentiste demain à 14h"
calendar-ai "Réunion équipe lundi 10h pour 2 heures"
calendar-ai "Dîner avec Marie vendredi soir à 19h30"

# Tâches
calendar-ai "Acheter du pain"
calendar-ai "Finir le rapport pour vendredi"
calendar-ai "Appeler le plombier demain matin"
```

### Mode vocal (optionnel)

```bash
# Activer le microphone et parler
calendar-ai --voice
```

### Options avancées

```bash
# Utiliser un modèle spécifique
calendar-ai --model mistral "Réunion importante demain"

# Tester sans exécuter (dry-run)
calendar-ai --dry-run "Rendez-vous médecin lundi"

# Afficher les détails de parsing
calendar-ai --debug "Appel client mardi 15h"

# Tester la connexion à Ollama
calendar-ai --test-connection

# Utiliser une autre instance Ollama
calendar-ai --ollama-host http://192.168.1.100:11434 "Événement"
```

## 📖 Exemples détaillés

### Événements de calendrier

```bash
# Avec date et heure
calendar-ai "Réunion de travail demain à 9h"

# Avec durée
calendar-ai "Conférence lundi 14h pour 3 heures"

# Avec jour de la semaine
calendar-ai "Dentiste mardi prochain à 15h30"

# Avec rappel (si mentionné)
calendar-ai "Appel important demain 10h, me rappeler 1 heure avant"
```

### Tâches (todos)

```bash
# Tâche simple
calendar-ai "Faire les courses"

# Avec date d'échéance
calendar-ai "Rendre le dossier pour vendredi"

# Avec priorité implicite
calendar-ai "URGENT : envoyer le rapport"

# Tâche récurrente (à implémenter)
calendar-ai "Arroser les plantes tous les lundis"
```

## ⚙️ Configuration

### Variables d'environnement

```bash
# URL de l'API Ollama (défaut: http://localhost:11434)
export OLLAMA_HOST="http://localhost:11434"

# Modèle par défaut (défaut: llama2)
export OLLAMA_MODEL="mistral"
```

### Configuration calendar-cli

Le script utilise automatiquement votre configuration calendar-cli existante :

```bash
# Si vous n'avez pas encore configuré calendar-cli
calendar-cli --interactive-config
```

Le fichier de configuration est dans `~/.config/calendar.conf`

### Utiliser une section de configuration spécifique

```bash
calendar-ai --config-section travail "Réunion demain"
calendar-ai --config-section perso "Anniversaire Marie samedi"
```

## 🔧 Dépannage

### Ollama n'est pas accessible

```bash
# Vérifier qu'Ollama tourne
ollama list

# Si ce n'est pas le cas
ollama serve

# Tester la connexion
calendar-ai --test-connection
```

### Le modèle n'est pas installé

```bash
# Lister les modèles installés
ollama list

# Installer un modèle
ollama pull llama2
```

### Problème de reconnaissance vocale

```bash
# Vérifier que les dépendances sont installées
pip install SpeechRecognition pyaudio

# Sur Linux, installer portaudio
sudo apt-get install portaudio19-dev python3-pyaudio

# Sur macOS
brew install portaudio
```

### Erreur de parsing

Si le modèle ne comprend pas bien votre texte :

1. Utilisez un modèle plus puissant : `--model mistral`
2. Soyez plus explicite : "Rendez-vous dentiste le 25 octobre à 14h00"
3. Utilisez `--debug` pour voir ce qui est parsé

## 🧪 Tests

### Test de connexion Ollama

```bash
python3 -c "from calendar_cli.ollama_integration import test_ollama_connection; test_ollama_connection()"
```

### Test complet

```bash
# Mode dry-run pour voir sans exécuter
calendar-ai --dry-run --debug "Rendez-vous test demain à 10h"
```

## 🎨 Exemples d'utilisation avancés

### Script shell pour rappels quotidiens

```bash
#!/bin/bash
# morning_routine.sh

calendar-ai "Révision du code à 9h"
calendar-ai "Pause café à 10h30 pour 15 minutes"
calendar-ai "Déjeuner à 12h30 pour 1 heure"
calendar-ai "Réunion d'équipe à 15h pour 30 minutes"
```

### Intégration avec d'autres outils

```bash
# Depuis un fichier
cat taches.txt | while read line; do
  calendar-ai "$line"
done

# Avec fzf (sélecteur interactif)
echo "Rendez-vous dentiste\nRéunion équipe\nAppeler client" | \
  fzf --multi | while read line; do
    calendar-ai "$line demain"
  done
```

## 🔮 Fonctionnalités futures

- [ ] Support des événements récurrents
- [ ] Intégration avec Whisper local pour la reconnaissance vocale
- [ ] Support des invitations (participants)
- [ ] Détection automatique de la langue
- [ ] Interface web simple
- [ ] Export vers d'autres formats (Google Calendar, Outlook, etc.)

## 📝 Architecture technique

### Composants

1. **OllamaClient** (`calendar_cli/ollama_integration.py`)
   - Communique avec l'API Ollama
   - Gère les requêtes et réponses

2. **NaturalLanguageParser** (`calendar_cli/ollama_integration.py`)
   - Parse le texte en langage naturel
   - Extrait les informations structurées (date, heure, description, etc.)
   - Fallback sur des heuristiques simples si Ollama échoue

3. **calendar-ai** (`bin/calendar-ai`)
   - Point d'entrée CLI
   - Gère les arguments de ligne de commande
   - Interface avec calendar-cli

### Flux de données

```
Texte/Voix → calendar-ai → OllamaClient → Ollama (modèle IA)
                                             ↓
                          Données structurées (JSON)
                                             ↓
                        format_for_calendar_cli()
                                             ↓
                          Arguments calendar-cli
                                             ↓
                             calendar-cli → CalDAV
```

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :

- Signaler des bugs
- Proposer de nouvelles fonctionnalités
- Améliorer la documentation
- Ajouter des tests

## 📄 Licence

Même licence que calendar-cli (GPLv3)

## 🙏 Remerciements

- [Ollama](https://ollama.ai/) pour l'IA locale
- [calendar-cli](https://github.com/tobixen/calendar-cli) pour l'outil de base
- La communauté open-source

---

**Astuce** : Pour une expérience optimale, utilisez un modèle adapté à votre langue :

- Français : `llama2`, `mistral`, `mixtral`
- Multilingue : `llama2:13b`, `mixtral:8x7b`

Amusez-vous bien avec votre nouveau calendrier en langage naturel ! 🎉
