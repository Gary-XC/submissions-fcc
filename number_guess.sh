#!/bin/bash

# Variable for querying the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random number between 1 and 1000
SECRET_NUMBER=$((RANDOM % 1000 + 1))
GUESSES=0

# Prompt for username
echo "Enter your username:"
read USERNAME

# Check if user exists in DB by querying heir username
USER_EXISTS=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

if [[ -z $USER_EXISTS ]]
then
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  GAMES_PLAYED=0
  BEST_GAME=0
else
  # Returning user - query the database for games played and their best game
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
  
  if [[ -z $GAMES_PLAYED ]]; then GAMES_PLAYED=0; fi
  if [[ -z $BEST_GAME ]]; then BEST_GAME=0; fi
  
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS

# Game loop
while true
do
  if [[ ! $GUESS =~ ^[+-]?[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    continue
  fi

  GUESSES=$((GUESSES + 1))

  if [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read GUESS
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    read GUESS
  else
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    
    # Update database values for the current game
    GAMES_PLAYED=$((GAMES_PLAYED + 1))
    
    # Checking if it's their first game or if they beat their record
    if [[ $BEST_GAME -eq 0 ]] || [[ $GUESSES -lt $BEST_GAME ]]
    then
      BEST_GAME=$GUESSES
    fi
    
    # Inserting a new user or updating an existing user's record in the database
    if [[ -z $USER_EXISTS ]]
    then
      $PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', $GAMES_PLAYED, $BEST_GAME)" > /dev/null
    else
      $PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE username = '$USERNAME'" > /dev/null
    fi
    break
  fi
done