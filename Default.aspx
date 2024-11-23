<%@ Page Language="C#" %>
<%@ Import Namespace="System.IO" %>

<script runat="server" type="text/C#">

    //variables for various options
    bool BrowseSubFolders = true;
    bool ShowBreadCrumbs = true;
    bool ShowFooter = true;
    bool ShowSizeInMb = true;
    bool UseDataTables = true;
    bool UseDataTablesSearch = true;

    //localizable texts
    string TxtColumnFileName = "File name";
    string TxtColumnDate = "Date";
    string TxtColumnType = "Type";
    string TxtColumnSize = "Size";
    string TxtFolderUp = "...";
    string TxtRoot = "root";
    string TxtCurrentFolder = "Current folder";
    string TxtFooter = "{0:N0} files found with a total size of {1:N1} {2}.";
    string TxtDatatableEmpty = "No files found in the current folder.";
    string TxtDatatableSearch = "Search";
    string TxtDatatableNohits = "No matching files found.";
    string TxtSizeKb = "kb";
    string TxtSizeMb = "mb";

    //allowed file types
    List<string> AllowedFileTypes = new List<string>()
    {
        ".ai",
        ".bmp",
        ".eps",
        ".gif",
        ".jpg",
        ".jpeg",
        ".png",
        ".psd",
        ".svg",

        ".7z",
        ".csv",
        ".doc",
        ".docx",
        ".flac",
        ".mp3",
        ".mp4",
        ".pdf",
        ".ppt",
        ".pptx",
        ".rar",
        ".txt",
        ".xls",
        ".xlsx",
        ".xml",
        ".zip"
    };

    //blocked folder names
    List<string> BlockedFolders = new List<string>()
    {
        "bin"
    };

    //some variables
    string RootFolder;
    string RootFolderNav;
    string CurrentFolder;
    string ParentFolder;
    string DownloadLinkPrefix;
    decimal SizeDivider;
    bool IsSubFolder;
    List<FileInfo> AllFiles;
    List<DirectoryInfo> AllFolders;

    //executed on page load
    protected void Page_Load(object sender, EventArgs e)
    {
        string RequestPath = Request.CurrentExecutionFilePath;
        string QueryString = "";

        //find the root folder of the browser
        RootFolder = RequestPath.Replace(RequestPath.Split('/').Last(), "").TrimEnd('/');

        //if this filename is not default.aspx include it in the url for folder navigation
        if (!RequestPath.ToLower().EndsWith("/default.aspx"))
        {
            RootFolderNav = RequestPath;
        }
        else
        {
            RootFolderNav = RootFolder;
        }

        //what is the current folder
        CurrentFolder = "/";

        //is there a querystirng
        if (Request.QueryString["folder"] != null && Request.QueryString["folder"].ToString().Length > 0)
        {
            QueryString = Request.QueryString["folder"].TrimStart('/').TrimEnd('/').Trim();

            CurrentFolder = CurrentFolder + QueryString;

            DownloadLinkPrefix = RootFolder + CurrentFolder + "/";

            IsSubFolder = true;
        }
        else
        {
            DownloadLinkPrefix = RootFolder + "/";
        }

        //if the folder does not exist or is it blocked, then redirect to base url
        if (!Directory.Exists(Server.MapPath(RootFolder + CurrentFolder)) || BlockedFolders.Any(x => x.ToLower() == QueryString.ToLower()))
        {
            Response.Redirect(RootFolderNav);
        }

        //get the current folder info
        var di = new DirectoryInfo(Server.MapPath(RootFolder + CurrentFolder));

        //find all the files
        AllFiles = di.GetFiles("*", SearchOption.TopDirectoryOnly)
            .Where(x => AllowedFileTypes.Any(y => y.ToLower() == Path.GetExtension(x.Name).ToLower()))
            .OrderBy(y => y.Name).ToList();

        //find all the folders
        if (BrowseSubFolders)
        {
            AllFolders = di.GetDirectories()
                .Where(x => !BlockedFolders.Any(y => y.ToLower() == x.Name.ToLower()))
                .OrderBy(y => y.Name).ToList();
        }

        //which size to display
        SizeDivider = 1024;
        if (ShowSizeInMb)
        {
            SizeDivider = SizeDivider * SizeDivider;
        }

        //create the parent folder link
        if (IsSubFolder)
        {
            string LastPart = CurrentFolder.Split('/').Last();

            if (!string.IsNullOrEmpty(LastPart))
            {
                ParentFolder = CurrentFolder.Replace(LastPart, "").TrimEnd('/');
            }
        }
    }
</script>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, device-height, initial-scale=1, shrink-to-fit=no">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">

    <title>Nya <%= CurrentFolder %></title>
</head>
<body>

    <div class="container mt-3 mb-3">

        <!-- breadcrumb path -->

        <% if ((UseDataTables && UseDataTablesSearch) || (BrowseSubFolders && ShowBreadCrumbs))
            { %>

        <div class="row mb-3">
            <div class="col-12 col-md-9 col-xxl-10 h5">

                <% if (BrowseSubFolders && ShowBreadCrumbs)
                    { %>

                <div class="float-start fw-bold pe-2"><%= TxtCurrentFolder %>:</div>

                <nav class="float-start" aria-label="breadcrumb">
                    <ol class="breadcrumb ">

                        <% if (IsSubFolder)
                            {
                        %>

                        <li class="breadcrumb-item"><a class="text-decoration-none" href="<%= RootFolderNav %>"><%= TxtRoot %></a></li>

                        <%
                            var folders = CurrentFolder.Split('/').Skip(1).ToList();

                            for (int i = 0; i < folders.Count(); i++)
                            {
                                if (CurrentFolder.EndsWith("/" + folders[i]))
                                {
                        %>

                        <li class="breadcrumb-item active"><%= folders[i] %></li>

                        <% }
                            else
                            {  %>

                        <li class="breadcrumb-item"><a class="text-decoration-none" href="<%= RootFolderNav %>?folder=<%= "/" + string.Join("/", folders.Take(i + 1)) %>"><%= folders[i] %></a></li>

                        <% }
                                }
                            }
                            else
                            {  %>

                        <li class="breadcrumb-item"><%= CurrentFolder %></li>

                        <% } %>
                    </ol>
                </nav>

                <% } %>
            </div>

            <%
                if (UseDataTables && UseDataTablesSearch)
                {
            %>

            

            <% } %>
        </div>

        

        <% } %>

        <div class="center">
            
            <div class="col-12 col-md-3 searchbar col-xl-2">
                <input type="search" placeholder="<%= TxtDatatableSearch %>" maxlength="50" class="form-control form-control-sm search-datatable">
            </div>
            <div class="row">
                <div class="col">

                    <!-- the table with all the files -->

                    <table class="table table-striped table-datatable <%= UseDataTables ? "opacity-0" : "" %>" id="vdwwd_datatable_<%= Regex.Replace(CurrentFolder, "[^a-zA-Z0-9]", "") %>">
                        <thead>
                            <tr>
                                <% if (UseDataTables)
                                    { %>

                                <th class="d-none"></th>

                                <% } %>

                                <th class="w-75"><%= TxtColumnFileName %>&nbsp;</th>
                                <th class="text-end"><%= TxtColumnDate %>&nbsp;</th>
                                <th class="text-end"><%= TxtColumnType %>&nbsp;</th>
                                <th class="text-end"><%= TxtColumnSize %>&nbsp;</th>
                            </tr>
                        </thead>
                        <tbody>

                            <!-- loop all the folders -->

                            <% if (BrowseSubFolders)
                                {
                                    if (!string.IsNullOrEmpty(CurrentFolder))
                                    {
                            %>

                            <!-- add the up folder link if not root -->

                            <% if (IsSubFolder)
                                { %>

                            <tr>

                                <% if (UseDataTables)
                                    { %>

                                <td class="d-none">0</td>

                                <% } %>

                                <td>
                                    <div class="float-start">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="me-3">
                                            <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
                                            <line x1="9" y1="14" x2="15" y2="14"></line>
                                        </svg>
                                    </div>
                                    <div class="fw-bold">
                                        <a href="<%= RootFolderNav %>?folder=<%= ParentFolder %>" class="text-decoration-none">
                                            <%= TxtFolderUp %>
                                        </a>
                                    </div>
                                </td>
                                <td></td>
                                <td></td>
                                <td></td>
                            </tr>

                            <% } %>

                            <!-- loop the folders -->

                            <%
                                }

                                foreach (var Folder in AllFolders)
                                { %>

                            <tr>

                                <% if (UseDataTables)
                                    { %>

                                <td class="d-none">1</td>

                                <% } %>

                                <td>
                                    <div class="float-start">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="me-3">
                                            <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
                                        </svg>
                                    </div>
                                    <div class="fw-bold">
                                        <a href="<%= RootFolderNav %>?folder=<%= (IsSubFolder ? CurrentFolder + "/" : CurrentFolder) + Folder.Name.Replace(" ", "%20") %>" class="text-decoration-none">
                                            <%= Folder.Name %>
                                        </a>
                                    </div>
                                </td>
                                <td></td>
                                <td></td>
                                <td></td>
                            </tr>

                            <% }
                                } %>

                            <!-- loop all the files -->

                            <% foreach (var File in AllFiles)
                                { %>

                            <tr>

                                <% if (UseDataTables)
                                    { %>

                                <td class="d-none">2</td>

                                <% } %>

                                <td>
                                    <a target="_blank" class="text-decoration-none" href="<%: DownloadLinkPrefix + File.Name %>">
                                        <div>
                                            <%= File.Name %>
                                        </div>
                                    </a>
                                </td>
                                <td class="text-end text-nowrap">
                                    <%= File.CreationTime.ToShortDateString() %>
                                </td>
                                <td class="text-end text-nowrap">
                                    <%= File.Extension.Replace(".", "").ToUpper() %>
                                </td>
                                <td class="text-end text-nowrap">
                                    <span class="d-none"><%: File.Length.ToString().PadLeft(15, '0') %></span>
                                    <%= string.Format("{0:N1}", (decimal)File.Length / SizeDivider) %>
                                </td>
                            </tr>

                            <% } %>

                            <!-- if there are no files show error message -->

                            <% if (!AllFiles.Any())
                                { %>

                            <tr>
                                <% if (UseDataTables)
                                    { %>

                                <td class="d-none">1</td>

                                <% } %>

                                <td class="dataTables_empty">
                                    <%= TxtDatatableEmpty %>
                                </td>
                                <td></td>
                                <td></td>
                                <td></td>
                            </tr>

                            <% } %>
                        </tbody>

                        <!-- show the footer -->

                        <% if (ShowFooter)
                            { %>

                        <tfoot>
                            <tr>
                                <td colspan="5" class="fw-bold">
                                    <%= string.Format(TxtFooter, AllFiles.Count(), (decimal)AllFiles.Sum(x => x.Length) / SizeDivider, ShowSizeInMb ? TxtSizeMb : TxtSizeKb) %>
                                </td>
                            </tr>
                        </tfoot>

                        <% } %>
                    </table>

                </div>
            </div>
        </div>

    </div>

    <% if (UseDataTables)
        { %>

    <!-- if datatables are allowed -->

    <script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
    <link href="https://cdn.datatables.net/1.13.4/css/jquery.dataTables.min.css" rel="stylesheet" />

    <% if (UseDataTablesSearch)
        { %>

    <script src="https://cdn.jsdelivr.net/g/mark.js(jquery.mark.min.js)"></script>
    <script src="https://cdn.datatables.net/plug-ins/1.10.13/features/mark.js/datatables.mark.js"></script>

    <% } %>

    <style>
        .dataTables_filter {
            display: none;
        }

        table.dataTable td.dataTables_empty {
            text-align: left;
            padding: 20px;
            color: rgb(255, 158, 120);
        }

        mark {
            background: orange;
            color: black;
            padding: 0px 2px;
        }

        a {
            color: rgb(255, 123, 0);

        }

        a:hover {
            color: rgb(196, 105, 0);
        }

        body{
            background-image: url(../img/13-Ventura-Dark.jpg);
            background-size: cover;
            position: relative;
            flex-direction: column;
            background-color: rgb(32, 20, 55);
            background-repeat: no-repeat;
            background-position:right top;
            height: fit-content;
        }


        table.table-striped tbody .text-end.text-nowrap, .table-striped .text-end.sorting, .fw-bold, .w-75.sorting, .even, .odd {
            color: rgb(204, 204, 204);
            border-color: rgba(119, 119, 119, 0);
        
        }

        .dataTable{
            background-color: rgba(0, 0, 0, 0.377);
            border-radius: 13.5px;
            backdrop-filter: blur(8px);
            
        }

        .float-start, .breadcrumb  {
            color: rgba(255, 255, 255, 0.849);
        }

        table.dataTable tfoot th, table.dataTable tfoot td{
            border-top: 0px solid rgba(97, 97, 97, 0.247);
        }

        div.center div.col-12.col-md-3.col-xl-2{
            align-self: center;
            display: flex;
            box-sizing: border-box;
            justify-content: center;
            margin-bottom: 20px;
        }

        .center {
            display: flex;
            flex-direction: column;
            position: absolute;
            align-self: center;
            justify-content: center;
            vertical-align: middle;
            top: 50%;
            /* transform: translateY(50%); */
        }

        .searchbar {
            width: 50%;
            margin-top: 18%;
            backdrop-filter: blur(8px);
            border-radius: 20px;
        }

        input:focus.search-datatable, .search-datatable{
            background-color: rgba(56, 48, 65, 0.377) ;  
            border-color: rgba(71, 71, 71, 0.733) ;
            border-radius: 1.225rem;
            color:rgba(255, 255, 255, 0.884) ;
        }

        input.search-datatable, .search-datatable::placeholder{
            text-align: center; 
            height: 2.3rem;
            color: rgba(255, 255, 255, 0.685);
            opacity: 1; /* Firefox */
        }
 
        .container.mt-3.mb-3 {
            display: flex;
            flex-direction: column;
            justify-content: center;
            position: relative;
            box-sizing: border-box;
            vertical-align: middle;
        }    

        
        
    </style>

    <script>
        $(document).ready(function () {
            var $table = $('.table-datatable');
            var $search = $table.closest('.container').find('.search-datatable');

            //initialze the datatable
            var $datatable = $table.DataTable({
                'stateSave': true,
                'stateDuration': -1,
                'searching': <%= UseDataTablesSearch.ToString().ToLower() %>,
                'paging': false,
                'info': false,
                'mark': {
                    separateWordSearch: false
                },
                'orderFixed': [0, 'asc'],
                'language': {
                    'emptyTable': '<%= TxtDatatableEmpty %>',
                    'search': '<%= TxtDatatableSearch %>:',
                    'zeroRecords': '<%= TxtDatatableNohits %>'
                },
            });

            //only show the datatable after initialization to hide the flickering of content due to creating or sorting contents
            $table.removeClass('opacity-0');

    <% if (UseDataTablesSearch)
        { %>

            //search the datatable on keyup from an external input
            $search.on('keyup', function () {
                $datatable.search(this.value).draw();
            });

            //make the x button in the search input remove the search from the datatable
            $search.on('search', function () {
                if ($(this).val() === '') {
                    $search.trigger('keyup');
                }
            });

            //if there is a search saved in the savestate of the datatable then fill the external input with that value
            $search.val($datatable.search());

            <% } %>

        });
    </script>

    <% } %>
</body>
</html>
