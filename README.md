# Forkable

Version control for culinary creators. A mobile app designed for analytical cooks and bakers who constantly tweak recipes, blending the clean aesthetic of developer tools (like GitHub) with the warmth of a modern culinary app.

## Screens

- **Dashboard** — Home feed of recipe "repositories" with an activity stream showing forks and pull requests from collaborators
- **Recipe Detail** — Master branch view with ingredients (as variables), step-by-step instructions, a commit history timeline, and active branches
- **Fork & Tweak** — Adjust ingredient amounts with real-time baker's percentage recalculation, then write a commit message and create a branch
- **Merge Review** — Side-by-side visual diff comparing a collaborator's ingredient changes against the master recipe, with tasting notes and merge/keep actions
- **Forks** — Browse all forks across recipes with search and filtering

## Project Structure

```
Forkable/
├── ForkableApp.swift          # App entry point
├── Models/
│   └── Models.swift           # Recipe, Ingredient, Branch, Commit, Activity
├── Data/
│   └── MockData.swift         # Sample recipes, activities, and branches
├── Views/
│   ├── ContentView.swift      # Tab bar container with custom floating + button
│   ├── DashboardView.swift    # Home screen
│   ├── RecipeDetailView.swift # Recipe detail with commit history
│   ├── ForkTweakSheet.swift   # Ingredient adjustment modal
│   ├── MergeReviewView.swift  # Side-by-side diff review
│   └── ForksPageView.swift    # All forks browser
├── Theme/
│   └── Theme.swift            # Color extensions
└── Assets.xcassets/
```

## Requirements

- iOS 17+
- Xcode 16+
- Swift 5.9+

## Getting Started

1. Open `Forkable.xcodeproj` in Xcode
2. Select a simulator target
3. Build and run (Cmd+R)
