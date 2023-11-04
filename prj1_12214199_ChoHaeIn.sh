#!/bin/bash
echo "12214199 Hae In Cho"

while true; do
    echo "Please choose one of the following options:"
    echo "1. Get data of a specific movie identified by 'movie id' from 'u.item'"
    echo "2. Get data of movies with the second genre as 'Action' from 'u.item'"
    echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
    echo "4. Delete 'IMDb URL' from 'u.item'(IF U USE IT, ANOTHER FUNCTION NOT WORKING)"
    echo "5. Get data about users from 'u.user'"
    echo "6. Modify the format of 'release date' in 'u.item'"
    echo "7. Get data of movies rated by a specific 'user id' from 'u.data'"
    echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
    echo "9. Exit"
    read input

    case $input in
        1)
            echo "Enter 'movie id' to get movie data:"
            read movie_id
            movie_data=$(grep -w "^$movie_id" u.item)
            if [ -n "$movie_data" ]; then
                echo "Movie data for 'movie id' $movie_id:"
                echo "$movie_data"
            else
                echo "Movie with 'movie id' $movie_id not found."
            fi
            ;;

        2)
            echo "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n)"
            read confirm
            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                echo "Movies with the second genre as 'Action' (sorted by 'movie id' and showing 'movie id' and 'movie title'):"
                action_movies=$(awk -F "|" '$7 == 1 {print $1, $2}' u.item | sort -k1,1n | head -n 10)
                if [ -n "$action_movies" ]; then
                    echo "$action_movies"
                else
                    echo "No movies with the second genre as 'Action' found in the database."
                fi
            else
                echo "Action movie data not requested."
            fi
            ;;

        3)
            echo "Please enter the 'movie id' (1~1682) to get average rating:"
            read movie_id

            if [ "$movie_id" -ge 1 ] && [ "$movie_id" -le 1682 ]; then
                average_rating=$(awk -v movie_id="$movie_id" '$2 == movie_id {sum += $3; count++} END {if (count > 0) printf "%.5f\n", sum / count}' u.data)
                if [ -n "$average_rating" ]; then
                    rounded_rating=$(printf "%.5f" "$average_rating")
                    echo "Average rating of 'movie id' $movie_id: $rounded_rating"
                else
                    echo "No ratings found for 'movie id' $movie_id."
                fi
            else
                echo "Invalid 'movie id'. Please enter a number between 1 and 1682."
            fi
            ;;

        4)
            echo "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n)"
            read confirm
            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                while IFS='|' read -r movie_id movie_title release_date video_release_date imdb_url genre; do
                    # Remove IMDb URL from the line
                    cleaned_line=$(echo "$movie_id|$movie_title|$release_date|$video_release_date|$genre")

                    # Output the cleaned line to a temporary file
                    echo "$cleaned_line" >> temp_u_item
                done < u.item

                # Replace u.item with the cleaned data
                mv temp_u_item u.item

                echo "IMDb URL deleted from 'u.item'."

                # Print first 10 records after URL deletion
                echo "First 10 records after IMDb URL deletion:"
                head -n 10 u.item
            else
                echo "No changes made to 'u.item'."
            fi
            ;;

        5)
            echo "Do you want to get the data about users from 'u.user'?(y/n)"
            read confirm
            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                echo "Printing data about users from 'u.user':"
                head -n 10 u.user | awk -F '|' '{printf "user %s is %s years old %s %s\n", $1, $2, $3, $4}'
            else
                echo "No data retrieved from 'u.user'."
            fi
            ;;

        6)
            echo "Do you want to Modify the format of 'release data' in 'u.item'?(y/n)"
            read confirm
            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                # Create a temporary file
                temp_file=$(mktemp)
                
                # Modify the format of the video release date in u.item and overwrite the file
                awk 'BEGIN {OFS=FS="|"} {split($3, date, "-"); new_date=sprintf("%04d%02d%02d", date[3], (index("JanFebMarAprMayJunJulAugSepOctNovDec", date[2])+2)/3, date[1]); $3=new_date; print $0}' u.item > "$temp_file"
                
                # Replace u.item with the modified data
                mv "$temp_file" u.item
                
                echo "Release date format modified in 'u.item'."
                
                # Print last 10 records after format modification
                echo "Last 10 records after format modification:"
                tail -n 10 u.item
            else
                echo "No changes made to 'u.item'."
            fi
            ;;

        7)
            echo "Enter 'user id' to get movies rated by the user:"
            read user_id

            echo "Do you want to proceed and get movies rated by user $user_id? (y/n)"
            read confirm
            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                # Get all movie IDs rated by the user and sort them
                rated_movie_ids=$(awk -v user_id="$user_id" '$1 == user_id {print $2}' u.data | sort -n)

                if [ -n "$rated_movie_ids" ]; then
                    # Print all movie IDs rated by the user without newline
                    echo -n "Movie IDs rated by user $user_id: "
                    echo "$rated_movie_ids" | tr '\n' ' '

                    # Print a newline
                    echo

                    # Get top 10 movie IDs rated by the user and store them in a temporary variable
                    top_rated_ids=$(echo "$rated_movie_ids" | head -n 10)

                    # Get movie titles for the top 10 movie IDs from u.item and print them
                    echo "Top 10 rated movies by user $user_id (Movie ID, Title):"
                    while IFS='|' read -r movie_id movie_title rest; do
                        if echo "$top_rated_ids" | grep -qw "$movie_id"; then
                            echo "$movie_id $movie_title"
                        fi
                    done < <(sort -n -t '|' -k1,1 u.item)
                else
                    echo "No movies rated by user $user_id."
                fi
            else
                echo "Operation canceled. No movies retrieved."
            fi
            ;;

        8)
            # Extract user IDs of programmers aged 20~29 and occupation is 'programmer'
            programmer_user_ids=$(awk -F '|' '$2 >= 20 && $2 <= 29 && $4 == "programmer" {print $1}' u.user)

            if [ -n "$programmer_user_ids" ]; then
                # Calculate average ratings for movies rated by programmers in their 20s
                awk -F ' ' -v user_ids="$programmer_user_ids" '
                    BEGIN { split(user_ids, users, " "); }

                    # Function to check if a user ID is in the list of programmer IDs
                    function is_programmer(user_id, arr, len) {
                        for (i = 1; i <= len; i++) {
                            if (arr[i] == user_id) {
                                return 1;
                            }
                        }
                        return 0;
                    }

                    # Main processing for calculating average ratings
                    {
                        if (is_programmer($1, users, length(users)) && $3 >= 1 && $3 <= 5) {
                            movie_ratings[$2] += $3;
                            movie_counts[$2]++;
                        }
                    }

                    # Output average ratings for movies rated by programmers
                    END {
                        for (movie_id in movie_ratings) {
                            if (movie_counts[movie_id] > 0) {
                                average_rating = movie_ratings[movie_id] / movie_counts[movie_id];
                                printf("%d %.5f\n", movie_id, average_rating);
                            }
                        }
                    }
                ' u.data | sort -n
            else
                echo "No programmers aged 20~29 found in the database."
            fi
            ;;

        9)
            echo "Bye!"
            exit 0
            ;;

        *)
            echo "Invalid input. Please enter a number between 1 and 9."
            ;;
    esac
done
