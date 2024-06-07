#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(( $RANDOM%1000+1 ))

echo Enter your username:
read USERNAME

USER=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
if [[ -z $USER ]]
then
  echo Welcome, $USERNAME! It looks like this is your first time here.
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
  IFS="|" read USER_ID USERNAME GAMES_PLAYED BEST_GAME <<< $USER
else
  IFS="|" read USER_ID USERNAME GAMES_PLAYED BEST_GAME <<< $USER
  echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

echo Guess the secret number between 1 and 1000:
NUMBER_OF_GUESSES=0
INPUT_NUMBER=0
GUESS() {
  read INPUT_NUMBER
  (( NUMBER_OF_GUESSES++ ))

  if [[ ! $INPUT_NUMBER =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
    GUESS
  else
    if [[ $INPUT_NUMBER -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      GUESS
    elif [[ $INPUT_NUMBER -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      GUESS
    fi
  fi
}
GUESS

(( GAMES_PLAYED++ ))
UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE user_id=$USER_ID")
if [[ $BEST_GAME == 0 || $BEST_GAME > $NUMBER_OF_GUESSES ]]
then
  UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES  WHERE user_id=$USER_ID")
fi

echo You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!

