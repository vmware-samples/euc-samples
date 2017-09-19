$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Create Auth String" {
    It "creates a basic auth header" {
        Create-BasicAuthHeader -username "Test" -password "Password" | Should Be "Basic VGVzdDpQYXNzd29yZA=="
    }
}

Describe "Create API Headers" {
    It "creates a header dictionary" {
        $headers = Create-Headers -authString "authString" -tenantCode "tenant" -acceptType "application\json" -contentType "application\json"
        $headers | Should Be System.Collections.Hashtable
        $headers.Get_Item("Authorization") | Should Be "authString"
        $headers.Get_Item("aw-tenant-code") | Should Be "tenant"
        $headers.Get_Item("Accept") | Should Be "application\json"
        $headers.Get_Item("Content-Type") | Should Be "application\json"
    }
}

Describe "Upload Blob" {
    It "creates the blob endpoint url" {
       $server = "https://test.awmdm.com"
       $filename = "TestMSI"
       $groupID = "1234"

       $url = Create-BlobURL -baseURL $server -filename $filename -groupID $groupID

       $url | Should be "$server/api/mam/blobs/uploadblob?filename=$filename&organizationgroupid=$groupID"
    }

    It "returns 200 and Blob id" {

        # Given
        $headers = Create-Headers -authString "fakeuser" -tenantCode "fakeTenant" -acceptType "application\json" -contentType "application\json"
        $server = "https://test.awmdm.com"
        $filename = "TestMSI"
        $filepath = "c:\tmp\TestMSI.msi"
        $groupID = "1111"

        $mockRes = @{Status = 200; Value = 1234}

        Mock Invoke-RestMethod {return $mockRes}
        
        # When
        $res = Upload-Blob -airwatchServer $server `
            -filename $filename `
            -filepath $filepath `
            -groupID $groupID `
            -headers $headers

        # Then
        $res.Status | Should be 200
        $res.Value | Should be 1234
    }
}
