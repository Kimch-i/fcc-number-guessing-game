#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

load_user_data() {
    if [ -f "user_data.txt" ]; then
        # Read user data from the file
        while IFS=" " read -r stored_username stored_games_played stored_best_game; do
            if [ "$stored_username" == "$username" ]; then
                games_played=$stored_games_played
                best_game=$stored_best_game
                return 0
            fi
        done < user_data.txt
    else
        touch user_data.txt
    fi
}

echo "Enter your username:"
read username

load_user_data

if [ -n "$games_played" ]; then
    echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
else
    echo "Welcome, $username! It looks like this is your first time here."
    games_played=0
    best_game=0
fi

secret_number=$((RANDOM % 1000 + 1))
guesses=0
echo "Guess the secret number between 1 and 1000:"

while true; do
    read guess
    if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
    elif (( guess < secret_number )); then
        echo "It's higher than that, guess again:"
    elif (( guess > secret_number )); then
        echo "It's lower than that, guess again:"
    else
      guesses=$((guesses + 1))
        echo "You guessed it in $guesses tries. The secret number was $secret_number. Nice job!"
        games_played=$((games_played + 1))
        if (( best_game == 0 || guesses < best_game )); then
            best_game=$guesses
        fi
        break
      fi
    guesses=$((guesses + 1))
done

temp_file=$(mktemp)

while IFS=" " read -r stored_username stored_games_played stored_best_game; do
    if [ "$stored_username" == "$username" ]; then
        echo "$username $games_played $best_game" >> "$temp_file"
    else
        echo "$stored_username $stored_games_played $stored_best_game" >> "$temp_file"
    fi
done < user_data.txt

if ! grep -q "$username" user_data.txt; then
    echo "$username $games_played $best_game" >> "$temp_file"
fi

mv "$temp_file" user_data.txt
