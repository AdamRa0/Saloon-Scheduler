#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t -A -c"

echo -e "\n~~~~~ Random Salon ~~~~~\n"
echo -e "Welcome to Random salon. How may I be of assistance?\n"


MAIN_MENU() {
  if [[ $1 ]]
  then
    echo $1
  fi

  SERVICES_OFFERED=$($PSQL "SELECT service_id, name from services")

  echo "$SERVICES_OFFERED" | while IFS="|" read SERVICE_ID SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED

  DESIRED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $DESIRED_SERVICE ]]
  then
    MAIN_MENU "Service doesn't exist; please try again."
  else
    echo -e "\nEnter phone number"
    read CUSTOMER_PHONE
    
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_ID ]]
    then
      echo "You must be new. Please enter your name?"
      read CUSTOMER_NAME
      ($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    echo "Enter desired service time."
    read SERVICE_TIME

    if [[ -z $SERVICE_TIME  ]]
    then
      MAIN_MENU "Time is empty; please try again."
    fi

    ($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $DESIRED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}
MAIN_MENU