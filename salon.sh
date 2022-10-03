#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done  
  read SERVICE_ID_SELECTED 
  SALON_MENU
}

QUESTION(){
  
  echo -e "\n What time would you like your _______, '$CUSTOMER_NAME'"
}


SALON_MENU() {
  # if service does not exist
if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]$ ]]
then
  # send back to main menu
  echo -e "\nI could find that service. What would you like today?"
  MAIN_MENU
else
  # get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # insert new customer
    CUSTOMER_NAME_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  
  fi 
  
  # ask customer what time they would like their service
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

  echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # add customer_id, service_id and time into appointments
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  CUSTOMER_TIME_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
    
  # confirm service, time and customer name
  echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

  # thank you, goodbye
  echo -e "\nThank you for using our services, goodbye."
  
fi
}

echo -e "\n~~~~~ MY SALON ~~~~~\n"  

# list of available services
echo -e "\nWelcome to My Salon, please select a number for your service?"
echo -e "\n"
MAIN_MENU

