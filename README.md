
# Battleships Flutter Application

## Overview

This Flutter application interfaces with a RESTful API to enable users to register, log in, and play games of Battleships against both human and computer opponents. The primary objective of this project is to integrate a RESTful API with a Flutter application using asynchronous operations with the `http` package.

## Features

- **User Authentication**
  - Register and log in users
  - Store session tokens locally and handle expiration

- **Game Management**
  - List ongoing and completed games
  - Start new games with human or AI opponents
  - View and manage game states

- **Gameplay**
  - Play Battleships games with human or AI opponents
  - Update and display game board and game state

- **Responsiveness**
  - Scalable UI for various screen sizes

## Behavioral Specifications

### Login and Registration

- Users can log in or register from the login screen.
- Session tokens are stored locally and used for authentication.
- Expired tokens prompt users to log in again.

### Game List

- Displays a list of ongoing and completed games.
- Users can refresh the list and access game details.
- Options to start new games and log out.

### New Game

- Users place ships on a 5x5 board.
- Ships are placed by tapping on the board and removed by tapping again.
- A game is started once 5 ships are placed, submitting the configuration to the server.

### Playing a Game

- Game board shows the state of the game (ships, hits, misses).
- Users can play shots by tapping on the board.
- The board updates based on game progress, including turns and outcomes.

### Responsiveness

- The game board scales appropriately across different screen sizes.
- On larger screens, the game list and gameplay views can be displayed side-by-side.

## API Documentation

### Authentication

- `POST /register`: Register a new user.
- `POST /login`: Log in an existing user.

### Managing Games

- `GET /games`: Retrieve all games (active and completed).
- `POST /games`: Start a new game with specified ships and optional AI opponent.
- `GET /games/<game_id>`: Retrieve detailed information about a specific game.
- `PUT /games/<game_id>`: Play a shot in a specific game.
- `DELETE /games/<game_id>`: Cancel or forfeit a game.

## Implementation Requirements

- **External Packages**
  - `http`: For HTTP requests.
  - `shared_preferences`: For persistent storage of session tokens.
  - `provider`: For state management.

- **Code Structure**
  - Modularize UI code for readability.
  - Avoid global variables; encapsulate data in model classes.
  - Separate widget classes, model classes, and helper classes into their respective directories.

- **Asynchronous Operations**
  - Use `FutureProvider`, `FutureBuilder`, or `StreamBuilder` to manage async operations.
  - Display loading indicators during lengthy operations.

## Testing

The application will be tested by building and running it on macOS, Android, or iOS. Ensure the application runs without errors or warnings and meets the specified requirements.
