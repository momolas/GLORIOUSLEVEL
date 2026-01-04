# GLORIOUSLEVEL

GLORIOUSLEVEL est une application iOS dédiée aux exercices de respiration pour la détente et la concentration.

## Fonctionnalités

- **Exercices de respiration** :
    - **Méthode Wim Hof** : Cycles intenses d'inspiration/expiration suivis d'apnée.
    - **Méthode 365** : Cohérence cardiaque (5s inspiration, 5s expiration).
    - **Méthode 4x4 (Box Breathing)** : Carré respiratoire pour la concentration (5s partout).
    - **Méthode NOx** : Variante avec bourdonnement (Inspiration 4s, Rétention 4s, Expiration 6s, Pause 2s).
- **Suivi visuel et haptique** : Animations fluides et retours haptiques pour guider votre respiration.
- **Intégration Apple Health** : Enregistrez vos sessions de respiration en tant que "Mindful Minutes".
- **Visualisation Cardiaque** : Consultation des données brutes de rythme cardiaque depuis HealthKit.
- **Rappels** : Planifiez des notifications quotidiennes pour maintenir une routine.
- **Personnalisation** : Ajustez les temps de contraction, de relâchement et le nombre de répétitions.

## Prérequis

- iOS 17.0 ou plus récent.
- Xcode 15.0 ou plus récent pour le développement.

## Structure du projet

- **Models** : Contient la logique métier (`BreathingViewModel`, `HealthKitManager`, `NotificationManager`).
- **Views** : Contient les vues SwiftUI (`BreathingView`, `SettingsView`, `HeartbeatView`, `LaunchView`, etc.).
- **Assets** : Contient les ressources graphiques.

## Conformité Technique

Ce projet suit les directives définies dans `AGENTS.md`, notamment :
- Utilisation de Swift moderne (async/await, Task, ContinuousClock).
- SwiftUI avec le framework Observation (`@Observable`) et `@MainActor`.
- Navigation robuste via `NavigationStack`.
- Respect des conventions de nommage et de structure.

## Auteurs

- Mo (Créateur initial)
