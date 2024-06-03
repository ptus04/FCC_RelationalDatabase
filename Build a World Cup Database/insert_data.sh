#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

($PSQL "TRUNCATE teams, games")
($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART")
($PSQL "ALTER SEQUENCE games_game_id_seq RESTART")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  [[ $WINNER == winner ]] && continue

  RESULT=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  if [[ ! $RESULT ]]
  then
    RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
  fi

  RESULT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  if [[ ! $RESULT ]]
  then
    RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
  fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  [[ $WINNER == winner ]] && continue

  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  ($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
done