if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else
  PSQL="psql -XU freecodecamp -d periodic_table --no-align --tuples-only -c"

  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT=$($PSQL "SELECT * FROM elements WHERE atomic_number=$1")
  else
    ELEMENT=$($PSQL "SELECT * FROM elements WHERE symbol='$1' OR name='$1'")
  fi
  
  if [[ -z $ELEMENT ]]
  then
    echo I could not find that element in the database.
  else
    ATOMIC_NUMBER=$(echo $ELEMENT | sed -E "s/([0-9]+).*/\1/")
    ATOMIC_SYMBOL=$(echo $ELEMENT | sed -E "s/.*\|([A-Za-z]+)\|.*/\1/")
    ATOMIC_NAME=$(echo $ELEMENT | sed -E "s/.*\|([A-Za-z]+)$/\1/")

    ELEMENT_PROPERTIES=$($PSQL "SELECT * FROM properties JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")
    IFS="|" read _ _ MASS MELTING_POINT BOILING_POINT TYPE <<< $ELEMENT_PROPERTIES

    echo "The element with atomic number $ATOMIC_NUMBER is $ATOMIC_NAME ($ATOMIC_SYMBOL). It's a $TYPE, with a mass of $MASS amu. $ATOMIC_NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
fi
