# single-aspx-file-filebrowser
Browse files easily on your website with a single aspx page.

When you use the filename "Default.aspx", you can show the contents of a folder directly like <code>www.yourwebsite.com/files</code>, but you can rename it to like "Browser.aspx". Then the url will be <code>www.yourwebsite.com/files/browser.aspx</code>
   
Comes with some configurable options like:

- Enable / disable the display and browsing of subfolders
- View the files in a DataTable.
- Enable / disable the Breadcrumb path or table footer.
- Easily changable texts to your own language.
- Specify which files are allowed and which folders are blocked.

### Options

<code>BrowseSubFolders</code>
Allows the browsing of subfolders.
*Default: True*

<code>ShowBreadCrumbs</code>
Show the Breadcrumb path above the file table.
*Default: True*

<code>ShowFooter</code>
Show the footer with a summary of size and number of files.
*Default: True*

<code>ShowSizeInMb</code>
Shows the size of files in MB instead of KB.
*Default: False*

<code>UseDataTables</code>
Use DataTable for column sorting, searching and more.
*Default: True*

<code>UseDataTablesSearch</code>
Enables easy searching of items in the file table.
*Default: True*

<code>AllowedFileTypes</code>
Edit this list to add or remove allowed file types to be shown in the file table.	

<code>BlockedFolders</code>
Edit this list to add or remove folders from the blocked list.
