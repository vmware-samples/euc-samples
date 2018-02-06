// Here You can type your custom JavaScript...
function applyTemplate(){
    console.log("Applying");
    $tray = $("div.tray.editor")
    if(($tray.find("div#customtemplatesactivator")).length < 1){
        $tray.prepend("<div id='customtemplatesactivator' style='display:block;position:absolute;" +
                        ";width:100%;height:60px;'>"+
                        "<input id='customtemplatesaccess' type='button' style='font-size:12pt;position:absolute;" + 
                        "right:100px;top:100px;z-index:8' Value='Custom Templates' />" +
                        "</div>"
                        );
    }
    
    $slideshow = $("div.slideshow-wrapper[data-payloadtype='WinRT_com.airwatch.winrt.customsettings']");
    if($slideshow.length < 1){
        console.log("slide_show not available");
        return;
    }
    $card = $slideshow.find("div.card");
    
    $textObj = $("div.field[data-property='CustomSettings'] textarea");
    if($textObj.length > 0){
        $text = $textObj.val();
        $profileId = $("form#formEditProfileDetail input#Id").val();
    
        if(($card.find("div#customtemplatecontainer")).length < 1){
            $card.prepend("<div id='customtemplatecontainer' style='display:none;margin-top:40px;position:absolute;" +
                        "background-color:#ffffff;width:800px;height:440px;z-index:10;" +
                        "border-top:solid 1px black'>"+
                        "<h5 style='text-align:center'>Custom Profile</h5>" +  
                        "<select id='customtemplateselect' style='font-size:8pt;'><option value='SmarterGroups'>Smarter Groups</option>" +
                        "<option value='CustomAttributes'>Custom Attributes</option>" + 
                        "<option value='GroupPolicy'>Group Policy</option></select>" +
                        "<br />" + 
                        
                        "<div id='customtemplateRawTemplate' style='display:block'>" +
                        "<textarea id='customtemplatebox' style='color:black;font-size:8pt;width:770px;height:340px' ></textarea>" +
                        "<input id='customtemplatebutton' type='button' value='Apply' />" + 
                        "<span id='customtemplateresult' style='font-size:8pt;color:red'></span></div>" +
                        "</div>" + 
                         "<div id='customtemplateSmarterGroups' style='display:none'>" +
                         "<input id='customtemplatebutton' type='button' value='Apply' />" +
                         
                         "</div>" +
                        "</div>"
                        );
        } else {
            console.log("Not found");
        }
    
        $parser = new DOMParser();

        if($text.length > 0){
            if($text.indexOf("XPROFILE") > -1){
                $("div#customtemplatecontainer").css("display","block");
                $xmlDoc = $parser.parseFromString($text,"text/xml");
                $PowerShell = $xmlDoc.getElementsByTagName("parm")[0].getAttribute("value");
                $myMatches = $PowerShell.match(/\@\"(.*)\"\@/m);
                if($myMatches){
                    $template = $myMatches[1];
                    $template = atob($template);
                }
                $myMatches2 = $PowerShell.match(/\$templateType\=\"([^\"\;]*)\"/m);
                if($myMatches2){
                    $templateType = $myMatches2[1];
                }
                $card.find("select#customtemplateselect").val($templateType);
                $card.find("textarea#customtemplatebox").val($template);
            } 
        } 
    }
}

$("body#aw-console").on("click","a[data-payloadtype='WinRT_com.airwatch.winrt.customsettings']",function(){
    applyTemplate();
});

$("body#aw-console").on("click","input#customtemplatesaccess",function(){
    $slideshow = $("div.slideshow-wrapper[data-payloadtype='WinRT_com.airwatch.winrt.customsettings']");
    if($slideshow.length < 1){
        console.log("slide_show not available");
        return;
    }
    $card = $slideshow.find("div.card");
    if(($card.find("div#customtemplatecontainer")).length < 1){
        applyTemplate();   
    }
    
    if($("div#customtemplatecontainer").css("display") == "block"){
        $("div#customtemplatecontainer").css("display","none");
    } else {
        $("div#customtemplatecontainer").css("display","block"); 
    }
});

$("body#aw-console").on("click","input#customtemplatebutton",function(){
    $selector = $("select[title='Target']");
    if($selector.length > 0){
        if($selector.val() == 1){
            $selector.val(2);
        }
    }
    $includeAtomic = $("div.field[data-property='IncludeAtomic'] input.check-box");
    if($includeAtomic.length > 0){
        if($includeAtomic.prop("checked") === true){
            $includeAtomic.prop("checked", false);
        }  
    }
    if($('select#customtemplateselect').val() != "GroupPolicy"){
        try{
        var $obj = JSON.parse($('textarea#customtemplatebox').val());
        } catch (err){
            $('p#customtemplateresult').text(err.message);
            return;
        }
    }
    
    $TemplateInfo = window.btoa($('textarea#customtemplatebox').val());
    $TemplateType = $('select#customtemplateselect').val();
    $PowerShellTemplates = "<wap-provisioningdoc id=\"c14e8e45-792c-4ec3-88e1-be121d8c33dc\" name=\"customprofile\">"+
            "\r\n<characteristic type=\"com.airwatch.winrt.powershellcommand\" uuid=\"7957d046-7765-4422-9e39-6fd5eef38174\">" +
            "\r\n<parm name=\"PowershellCommand\" value='$type=\"XPROFILE\";\r\n" +
            "$templateType=\"" + $TemplateType + "\";\r\n"  +
            "$x=\r\n@\"\r\n" + 
            $TemplateInfo + 
            "\r\n\"@\r\n\r\n" +
            "$InstallPath = \"C:\\Temp\\Reg\\Queue\"\r\n" +
            "If(!(Test-Path $InstallPath)){\r\n" +
            "    $InstallPath = \"C:\\Temp\"\r\n" +
            "}\r\n" +
            "\r\n" + 
            "Set-Content ($InstallPath + \"\\" + $TemplateType + "-" + $profileId + ".profile\") $x;\r\n"+
            "$TaskCheck = (Get-ScheduledTask | where { $_.TaskName -eq \"Install_Profiles\" -and $_.TaskPath -like \"*AirWatch MDM*\"} | Measure);\r\n" +
            "If($TaskCheck.Count -gt 0){\r\n" +
            "   Start-ScheduledTask -TaskName \"Install_Profiles\" -TaskPath \"\\AirWatch MDM\\\";\r\n" +
            "}\r\n" +
             "\r\n'/>\r\n" +
            "</characteristic>\r\n</wap-provisioningdoc>";
    $text = $("div.field[data-property='CustomSettings'] textarea");
    $text.val($PowerShellTemplates);        
    $('div#customtemplatecontainer').css("display","none");
});