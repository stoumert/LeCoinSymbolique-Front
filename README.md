# LeCoinSymbolique - Frontend Flutter

## Description
LeCoinSymbolique est l'application mobile Flutter permettant de consulter et de gérer des annonces.  
Elle interagit avec le backend Java Spring Boot via des API REST.

---

## Prérequis
Assurez-vous que le backend soit lancé sur le port 8080.
### Système
- Windows, macOS ou Linux
- Flutter SDK (version 3.7.2 ou supérieure)
- Un simulateur Android/iOS ou un smartphone physique

### Outils nécessaires
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Android Studio](https://developer.android.com/studio) ou [Visual Studio Code](https://code.visualstudio.com/)
- Un émulateur Android ou iOS configuré
- Un terminal ou IDE avec Flutter intégré

---

## Installation

### 1. Installer les dépendances
```bash
  flutter pub get
```
### 2. Lancer le projet

- Lancer un simulateur Android/iOS
    Depuis Android Studio : AVD Manager > Démarrer un émulateur
    Depuis VSCode : Flutter: Launch Emulator
    Depuis Intellij : en haut a coté du main.dart open ios ou android simulator
- Exécuter l'application
  ```bash
    flutter run
  ```

### 3. Fonctionnalités disponibles
Authentification sécurisée (connexion/inscription)

Affichage des annonces

Recherche avec filtres

Téléchargement d'images

Géolocalisation

Gestion des autorisations

Lancement de liens externes

Communication sécurisée avec stockage local (tokens)

### 4. Dépendances principales
http : Requêtes HTTP

image_picker : Sélection d’images depuis la galerie ou la caméra

flutter_secure_storage : Stockage sécurisé des tokens

geolocator : Géolocalisation

permission_handler : Gestion des permissions

cached_network_image : Cache des images

url_launcher : Ouvrir des liens dans un navigateur externe

flutter_launcher_icons : Configuration des icônes d'application

