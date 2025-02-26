#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Please note this is BAD PRACTICE - good to know, but not to use
# use awk -F, instead (with NR>1 as an option to remove the first line with the headers)

echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Winner
  if [[ $WINNER != "winner" ]]
  then
    # get team_id
    TEAM_ID_WIN=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'") 
    # if not found
    if [[ -z $TEAM_ID_WIN ]]
    then
      # insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, $WINNER"
      fi

      # get new team_id
      TEAM_ID_WIN=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi
  fi

  # check opponent column for any missing teams
  if [[ $OPPONENT != "opponent" ]]
  then
    # get team_id
    TEAM_ID_LOSE=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'") 
    # if not found
    if [[ -z $TEAM_ID_LOSE ]]
    then
      # insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, $OPPONENT"
      fi

      # get new team_id
      TEAM_ID_LOSE=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
  fi

    # All not null values in games table
  if [[ $YEAR != "year" ]]
  then
  # get winner ID
    TEAM_ID_WIN=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'") 
    # get loser ID
    TEAM_ID_LOSE=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'") 
    # find game id using two IDs listed above
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id='$TEAM_ID_WIN' AND opponent_id='$TEAM_ID_LOSE'") 
    # if not found
    if [[ -z $GAME_ID ]]
    then
      # insert data
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $TEAM_ID_WIN, $TEAM_ID_LOSE, $WINNER_GOALS, $OPPONENT_GOALS)")
      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted into games, $YEAR, $ROUND, $TEAM_ID_WIN, $TEAM_ID_LOSE, $WINNER_GOALS, $OPPONENT_GOALS"
      fi

      # get new game_id
      GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year=$YEAR")
    fi
  fi

done