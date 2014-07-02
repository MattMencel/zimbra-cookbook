# Zimbra Cookbook

Provides some simple LWRPs for installing Zimbra Zimlets.  More features may be
added in the future.

It verifies that the zimlet is not already installed before proceeding.

# Usage

zimbra_zimlet ZIMLET_NAME do
  path PATH_TO_ZIMLET_ZIP_FILE
  action :install
end
