case "$COMMAND" in
  create)

    (
      set_message "Editing sites/default/settings.php to use correct database"
      cd $TMP_DIR/$PROJECT

      sed -i "s/$TEMPLATE/$PROJECT/" sites/default/settings.php

      git add sites/default/settings.php
      git commit -m "Update settings.php to use correct DB"
      git push
    )
  ;;

  import)
    set_message "Please edit the sites/default/settings.php to use the $PROJECT database." warning
  ;;

  sandbox)
    set_message "Creating symbolic link to files"
    # Todo: If DB is available check db for location
    # D6: file_directory_path
    # D7: file_public_path
    FILES_DIR=""
    if [ -d $WWW_DIR/$PROJECT/sites/all/files ] ; then
      FILES_DIR=sites/all/files
    elif [ -d $WWW_DIR/$PROJECT/files ] ; then
      FILES_DIR=files
    elif [ -d $WWW_DIR/$PROJECT/sites/default/files ] ; then
      FILES_DIR=sites/default/files
    fi
    if [ $FILES_DIR ] ; then
      #@todo: rmdir, make sure directory is empty
      if [ -d $HOME/public_html/$PROJECT/$FILES_DIR ] ; then
        rmdir $HOME/public_html/$PROJECT/$FILES_DIR
      fi
      ln -s $WWW_DIR/$PROJECT/$FILES_DIR $HOME/public_html/$PROJECT/$FILES_DIR
      set_message "Drupal files found at $WWW_DIR/$PROJECT/$FILES_DIR"
    else
      # Complain if a files directory wasn't found.
      set_message "A files directory could not be found." warning
    fi

    # If sites/default/settings.php is not in the clone
    if [ ! -a $HOME/public_html/$PROJECT/sites/default/settings.php ] ; then
      # Is it in $WWW_DIR?
      if [ -a $WWW_DIR/$PROJECT/sites/default/settings.php ] ; then
        # Copy it to the clone
        cp -a $WWW_DIR/$PROJECT/sites/default/settings.php $HOME/public_html/$PROJECT/sites/default/settings.php
      else
        # Complain.
        # @todo: In the future, recreate it.
        set_message "sites/default/settings.php could not be located." warning
      fi
    fi

    (
      cd $HOME/public_html/$PROJECT

      # Add sites/default/settings.php to the .git/info/exclude (like .gitignore, but only this clone)
      echo "sites/default/settings.php" >> .git/info/exclude

      # @todo: Must completely rewrite the DB connection strings
      #sed -i "s/$TEMPLATE/$PROJECT/" sites/default/settings.php

      #Ignore changes to sites/default/settings.php
      #git update-index --assume-unchanged sites/default/settings.php

      #Ignore changes to .htaccess
      #git update-index --assume-unchanged .htaccess

    )


  ;;


esac
