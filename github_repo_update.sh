#!/usr/bin/zsh

# store the current dir
CUR_DIR=$(pwd) # Save the current directory so that we can return to it after processing each repository.

# Let the person running the script know what's going on.
echo "\n\033[1mPulling in latest changes for all repositories...\033[0m\n" 
# Print a message in bold to inform the user that the script is starting to pull updates.

# Find all git repositories and update them to the latest master revision
for i in $(find . -name ".git" | cut -c 3-); do 
    # Find all directories that contain a .git folder and remove the first two characters from the path (./) using 'cut'.
    # This helps in constructing the relative path properly for navigation.
    
    echo ""; # Print an empty line for better readability.
    echo "\033[33m"+$i+"\033[0m"; # Print the current repository path in yellow color.

    # We have to go to the .git parent directory to call the pull command
    cd "$i"; # Navigate to the .git folder.
    cd ..; # Move up one level to the repository's root directory.

    # finally pull
    git pull origin master; # Perform a git pull from the master branch of the current repository.

    # lets get back to the CUR_DIR
    cd $CUR_DIR # Return to the original directory before moving to the next repository.
done

# Notify the user that the script has completed
echo "\n\033[32mComplete!\033[0m\n" # Print a final message in green to indicate that all repositories have been updated.
