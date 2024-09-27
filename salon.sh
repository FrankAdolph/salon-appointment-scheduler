#! /bin/bash

PSQL="psql -U freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"


SHOW_SERVICES() {

    if [[ $1 ]]
    then
        echo -e "\n$1"
    fi
    
    SERVICES=$($PSQL "SELECT * FROM services")
    echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done

    SELECT_SERVICE
}


SELECT_SERVICE() {

    read SERVICE_ID_SELECTED

    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
        SHOW_SERVICES "I could not find that service. What would you like today?"
    else
        # check if service exists
        CHECK_SERVICE_RESULT=$($PSQL "SELECT * FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        
        # if not
        if [[ -z $CHECK_SERVICE_RESULT ]]
        then
            # show service list
            SHOW_SERVICES "I could not find that service. What would you like today?"
        else
            # ask for phone number
            echo -e "\nWhat's your phone number?"
            read CUSTOMER_PHONE

            # check phone number
            FIND_CUSTOMER_RESULT=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")
            
            # if not exists
            if [[ -z $FIND_CUSTOMER_RESULT ]]
            then
                # ask for name
                echo -e "\nI don't have a record for that phone number, what's your name?"
                read CUSTOMER_NAME

                # insert customer
                INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

                FIND_CUSTOMER_RESULT=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")
            fi
                
            IFS="|" read CUSTOMER_ID CUSTOMER_PHONE CUSTOMER_NAME <<< $FIND_CUSTOMER_RESULT
            
            echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
            read SERVICE_TIME

            INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

            IFS="|" read SERVICE_ID SERVICE_NAME <<< $CHECK_SERVICE_RESULT

            echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME." 
                        
        fi 
    fi

}


echo "Welcome to My Salon, how can I help you?" 

SHOW_SERVICES
