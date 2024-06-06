#!/bin/bash

PSQL="psql -XU freecodecamp salon --tuples-only --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo $1
  fi

  echo -e "\nWelcome to My Salon, how can I help you?\n"
  echo "1) cut"
  echo "2) color"
  echo "3) perm"

  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED > 3 ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
    return
  fi

  echo "What's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  echo "What time would you like your cut, $CUSTOMER_NAME?"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  echo I have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME.
}

MAIN_MENU