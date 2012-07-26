# Checks for valid settings in the creo.conf file.
# @todo: Complete configuration tests
# @todo: Check location of Linux/Apache/MySQL/PHP/Solr/Trac/Drupal/Drush

# TMP_DIR: Directory to store temporary files/repos

# PROJECT_TEMPLATE_FILES: Stores template files for creating new projects
if [ ! -d $PROJECT_TEMPLATE_FILES ] ; then
  set_message "Project template files directory does not exist: $PROJECT_TEMPLATE_FILES" error
  exit 1
fi

# DEFAULT_TEMPLATE: Default project template, used when -t is not specified.

# APACHE_DIR: The Apache configuration directory (Note: This script is Debian/Ubuntu specific)

# WWW_DIR: The directory to store the web accessible clones of projects

# WWW_USER & WWW_GROUP: The user and group owning all files/directories in $WWW_DIR.
if ! grep -q $WWW_USER /etc/passwd; then
  set_message "WWW_USER: '$WWW_USER' does not exist" error
  exit 1
fi

if ! grep -q $WWW_GROUP /etc/group; then
  set_message "WWW_GROUP: '$WWW_GROUP' does not exist" error
  exit 1
fi

# BACKUP_DIR: Directory to store/restore backups to/from

# DOMAIN: The root domain name to use for each project. Will be used in the form: project.DOMAIN.

# MYSQL_USERNAME & MYSQL_PASSWORD: MySQL username and password

# DRUSH_PATH: Full path to run drush

# GITOLITE_REPO_ACCESS: The user@host access string for use with Gitolite

# GITOLITE_ADMIN_REPO_DIR: Directory for the gitolite-admin repo