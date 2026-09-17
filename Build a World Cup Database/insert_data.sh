#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # adding values to the teams table
    # by reading the values from the games.csv dataset
    $PSQL "insert into teams(name) values('$WINNER') on conflict(name) do nothing"
    $PSQL "insert into teams(name) values('$OPPONENT') on conflict(name) do nothing"
    # when there are any values that repeat
    # on conflict means that it does not add a duplicate value or throws an error

    # adding values to the games table
    # getting the team_id's from the newly inserted teams table
    # since teams.team_id is a foriegn key for games and needs the values
    WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'")
    OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT'")
    # inserting the game record into games table, which incldues both winner and opponent id
    # and everything that was read from the games.csv file
    $PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($YEAR, '$ROUND', '$WINNER_ID', '$OPPONENT_ID', $WINNER_GOALS, $OPPONENT_GOALS)"
  fi
done
