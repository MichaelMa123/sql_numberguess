#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USERNAME

RANDOM_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))
USER_ID=$($PSQL "SELECT users_id FROM users WHERE name = '$USERNAME';")
if [[ -z $USER_ID ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME');")
else
BEST_GAME=$($PSQL "SELECT MAX(guesses) FROM game_played WHERE users_id=$USER_ID")
GAME_PLAYED=$($PSQL "SELECT COUNT(*) FROM game_played WHERE users_id=$USER_ID")
echo "Welcome back, $USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
fi
is_valid=1
echo "Guess the secret number between 1 and 1000:"
total_guess=0
while [[ $is_valid -eq 1 ]]
do
  read GUESSED_NUMBER
  ((total_guess++))
  if ! [[ $GUESSED_NUMBER =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi
  if [[ $GUESSED_NUMBER -eq $RANDOM_NUMBER ]]; then
    is_valid=0
  elif [[ $GUESSED_NUMBER -lt $RANDOM_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $GUESSED_NUMBER -gt $RANDOM_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  fi
done
USER_ID_up=$($PSQL "SELECT users_id FROM users WHERE name = '$USERNAME';")
INSERT_GAME_RESULT=$($PSQL "INSERT INTO game_played(users_id, guesses) VALUES($USER_ID_up, $total_guess);")
echo "You guessed it in $total_guess tries. The secret number was $RANDOM_NUMBER. Nice job!"
