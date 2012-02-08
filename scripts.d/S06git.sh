
case "$COMMAND" in
  #nothing for create_solr, delete_solr, external, local_files, local_db, local_private_db, copy_private_db, create_private_db, update_private_db or delete_private_db
  create)
    set_message "Creating GIT repository..."
    cd $GITOLITE_ADMIN_REPO_DIR

    set_message "Copy gitolite $TEMPLATE conf to $PROJECT project conf"
    cp conf/repos/$TEMPLATE.conf conf/repos/$PROJECT.conf

    # Change the repo name in the file from $TEMPLATE to $PROJECT
    sed -i "s/$TEMPLATE/$PROJECT/" conf/repos/$PROJECT.conf

    # Add the new file to the repo
    git add conf/repos/$PROJECT.conf
    git commit -m "$SCRIPTNAME - Add $PROJECT.conf"

    # Store the new file in the gitolite-admin repo
    git push

    # Change to WWW_DIR
    cd $WWW_DIR
    set_message "Cloning $TEMPLATE template into $WWW_DIR/$PROJECT"
    git clone $GITOLITE_REPO_ACCESS:$TEMPLATE $PROJECT
    set_message "Changing origin to $PROJECT repo"
    # Change the origin to be the new PROJECT repo
    cd $WWW_DIR/$PROJECT
    git remote rename origin $TEMPLATE
    git remote add origin $GITOLITE_REPO_ACCESS:$PROJECT
    git push origin master
    git config --local branch.master.remote origin

    # Change file ownership to the correct user/group
    chown -R $WWW_USER:$WWW_GROUP $WWW_DIR/$PROJECT

    # Exit with same directory (Must do this since everything is called by source. Change?)
    cd $STARTDIR

    #echo "Creating $WWW_DIR/$PROJECT/sites/$PROJECT.$DOMAIN..."
    #mv $TMP_DIR/$PROJECT/sites/$TEMPLATE.$DOMAIN $TMP_DIR/$PROJECT/sites/$PROJECT.$DOMAIN

    #sed -i "s/$TEMPLATE/$PROJECT/" $TMP_DIR/$PROJECT/sites/$PROJECT.$DOMAIN/settings.php
    #cd $TMP_DIR/$PROJECT/sites/; ln -sf $PROJECT.$DOMAIN default
  ;;

  backup)
    set_message "Rolling up GIT..."
    mkdir -p $BACKUP_DIR/$PROJECT
    svnadmin dump -q $SVN_DIR/$PROJECT | gzip - > $BACKUP_DIR/$PROJECT/$PROJECT.svn.gz
  ;;

  restore)
    set_message "Rolling down GIT..."
    mkdir -p $SVN_DIR/$PROJECT
    svnadmin create $SVN_DIR/$PROJECT --fs-type fsfs
    gunzip -c $BACKUP_DIR/$PROJECT/$PROJECT.svn.gz | svnadmin load -q $SVN_DIR/$PROJECT
    set_svn_permissions $PROJECT
  ;;

  delete)
    set_message "Removing GIT repository..."
    cd $GITOLITE_ADMIN_REPO_DIR

    git rm conf/repos/$PROJECT.conf
    git commit -m "$SCRIPTNAME - Delete $PROJECT.conf"

    rm -rfv $GITOLITE_REPO_DIR/$PROJECT.git

    # Store the change in the gitolite-admin repo
    git push
    cd $STARTDIR
  ;;

#  local_all)
#    echo "Getting an export of the trunk for local dev..."
#    mkdir -p $HOME/${PROJECT}-${COMMAND}
#    svn co https://$PROJECT.$DOMAIN/svn/trunk/ $HOME/${PROJECT}-${COMMAND}/$PROJECT
#  ;;


  sandbox)
    set_message "Creating a $PROJECT sandbox for $USER..."

    if [ -d $HOME/public_html/$PROJECT ] ; then
      set_message "Sandbox already exists at $HOME/public_html/$PROJECT" error
      exit 1
    fi

    git clone $GITOLITE_REPO_ACCESS:$PROJECT $HOME/public_html/$PROJECT
  ;;
esac
