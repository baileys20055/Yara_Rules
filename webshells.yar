rule ChinaChopper_Generic {
	meta:
		description = "China Chopper Webshells - PHP and ASPX"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Florian Roth"
		reference = "https://www.fireeye.com/content/dam/legacy/resources/pdfs/fireeye-china-chopper-report.pdf"
		date = "2015/03/10"
	strings:
		$aspx = /%@\sPage\sLanguage=.Jscript.%><%eval\(Request\.Item\[.{,100}unsafe/
		$php = /<?php.\@eval\(\$_POST./
	condition:
		1 of them
}
rule WEBSHELL_ASP_Embedded_Mar21_1 {
   meta:
      description = "Detects ASP webshells"
      author = "Florian Roth"
      reference = "Internal Research"
      date = "2021-03-05"
      score = 85
   strings:
      $s1 = "<script runat=\"server\">" nocase
      $s2 = "new System.IO.StreamWriter(Request.Form["
      $s3 = ".Write(Request.Form["
   condition:
      filesize < 100KB and all of them
}

rule APT_WEBSHELL_HAFNIUM_SecChecker_Mar21_1 {
   meta:
      description = "Detects HAFNIUM SecChecker webshell"
      author = "Florian Roth"
      reference = "https://twitter.com/markus_neis/status/1367794681237667840"
      date = "2021-03-05"
      hash1 = "b75f163ca9b9240bf4b37ad92bc7556b40a17e27c2b8ed5c8991385fe07d17d0"
   strings:
      $x1 = "<%if(System.IO.File.Exists(\"c:\\\\program files (x86)\\\\fireeye\\\\xagt.exe" ascii
      $x2 = "\\csfalconservice.exe\")){Response.Write( \"3\");}%></head>" ascii fullword
   condition:
      uint16(0) == 0x253c and
      filesize < 1KB and
      1 of them or 2 of them
}

rule APT_HAFNIUM_Forensic_Artefacts_Mar21_1 {
   meta:
      description = "Detects forensic artefacts found in HAFNIUM intrusions"
      author = "Florian Roth"
      reference = "https://www.microsoft.com/security/blog/2021/03/02/hafnium-targeting-exchange-servers/"
      date = "2021-03-02"
   strings:
      $s1 = "lsass.exe C:\\windows\\temp\\lsass" ascii wide fullword
      $s2 = "c:\\ProgramData\\it.zip" ascii wide fullword
      $s3 = "powercat.ps1'); powercat -c" ascii wide fullword
   condition:
      1 of them
}

rule APT_WEBSHELL_HAFNIUM_Chopper_WebShell: APT Hafnium WebShell {
   meta:
      description = "Detects Chopper WebShell Injection Variant (not only Hafnium related)"
      author = "Markus Neis,Swisscom"
      date = "2021-03-05"
      reference = "https://www.volexity.com/blog/2021/03/02/active-exploitation-of-microsoft-exchange-zero-day-vulnerabilities/"
   strings:
      $x1 = "runat=\"server\">" nocase

      $s1 = "<script language=\"JScript\" runat=\"server\">function Page_Load(){eval(Request" nocase
      $s2 = "protected void Page_Load(object sender, EventArgs e){System.IO.StreamWriter sw = new System.IO.StreamWriter(Request.Form[\"p\"] , false, Encoding.Default);sw.Write(Request.Form[\"f\"]);"
      $s3 = "<script language=\"JScript\" runat=\"server\"> function Page_Load(){eval (Request[\"" nocase  
   condition:
      filesize < 10KB and $x1 and 1 of ($s*) 
}

rule APT_WEBSHELL_Tiny_WebShell : APT Hafnium WebShell {
   meta:
      description = "Detects WebShell Injection"
      author = "Markus Neis,Swisscom"
      hash = "099c8625c58b315b6c11f5baeb859f4c"
      date = "2021-03-05"
      reference = "https://www.volexity.com/blog/2021/03/02/active-exploitation-of-microsoft-exchange-zero-day-vulnerabilities/"
   strings:
      $x1 = "<%@ Page Language=\"Jscript\" Debug=true%>"

      $s1 = "=Request.Form(\""
      $s2 = "eval("
   condition:
      filesize < 300 and all of ($s*) and $x1
} 

rule HKTL_PS1_PowerCat_Mar21 {
   meta:
      description = "Detects PowerCat hacktool"
      author = "Florian Roth"
      reference = "https://github.com/besimorhino/powercat"
      date = "2021-03-02"
      hash1 = "c55672b5d2963969abe045fe75db52069d0300691d4f1f5923afeadf5353b9d2"
   strings:
      $x1 = "powercat -l -p 8000 -r dns:10.1.1.1:53:c2.example.com" ascii fullword
      $x2 = "try{[byte[]]$ReturnedData = $Encoding.GetBytes((IEX $CommandToExecute 2>&1 | Out-String))}" ascii fullword

      $s1 = "Returning Encoded Payload..." ascii
      $s2 = "$CommandToExecute =" ascii fullword
      $s3 = "[alias(\"Execute\")][string]$e=\"\"," ascii
   condition:
      uint16(0) == 0x7566 and
      filesize < 200KB and
      1 of ($x*) or 3 of them
}

rule HKTL_Nishang_PS1_Invoke_PowerShellTcpOneLine {
   meta:
      description = "Detects PowerShell Oneliner in Nishang's repository"
      author = "Florian Roth"
      reference = "https://github.com/samratashok/nishang/blob/master/Shells/Invoke-PowerShellTcpOneLine.ps1"
      date = "2021-03-03"
      hash1 = "2f4c948974da341412ab742e14d8cdd33c1efa22b90135fcfae891f08494ac32"
   strings:
      $s1 = "=([text.encoding]::ASCII).GetBytes((iex $" ascii wide
      $s2 = ".GetStream();[byte[]]$" ascii wide
      $s3 = "New-Object Net.Sockets.TCPClient('" ascii wide
   condition:
      all of them
}

rule WEBSHELL_ASPX_SimpleSeeSharp : Webshell Unclassified {
   meta:
      author = "threatintel@volexity.com"
      date = "2021-03-01"
      description = "A simple ASPX Webshell that allows an attacker to write further files to disk."
      hash = "893cd3583b49cb706b3e55ecb2ed0757b977a21f5c72e041392d1256f31166e2"
      reference = "https://www.volexity.com/blog/2021/03/02/active-exploitation-of-microsoft-exchange-zero-day-vulnerabilities/"
   strings:
      $header = "<%@ Page Language=\"C#\" %>"
      $body = "<% HttpPostedFile thisFile = Request.Files[0];thisFile.SaveAs(Path.Combine"
   condition:
      $header at 0 and
      $body and
      filesize < 1KB
}

rule WEBSHELL_ASPX_reGeorgTunnel : Webshell Commodity {
   meta:
      author = "threatintel@volexity.com"
      date = "2021-03-01"
      description = "variation on reGeorgtunnel"
      hash = "406b680edc9a1bb0e2c7c451c56904857848b5f15570401450b73b232ff38928"
      reference = "https://github.com/sensepost/reGeorg/blob/master/tunnel.aspx"
   strings:
      $s1 = "System.Net.Sockets"
      $s2 = "System.Text.Encoding.Default.GetString(Convert.FromBase64String(StrTr(Request.Headers.Get"
      $t1 = ".Split('|')"
      $t2 = "Request.Headers.Get"
      $t3 = ".Substring("
      $t4 = "new Socket("
      $t5 = "IPAddress ip;"
   condition:
      all of ($s*) or
      all of ($t*)
}

rule WEBSHELL_ASPX_SportsBall {
   meta:
      author = "threatintel@volexity.com"
      date = "2021-03-01"
      description = "The SPORTSBALL webshell allows attackers to upload files or execute commands on the system."
      hash = "2fa06333188795110bba14a482020699a96f76fb1ceb80cbfa2df9d3008b5b0a"
      reference = "https://www.volexity.com/blog/2021/03/02/active-exploitation-of-microsoft-exchange-zero-day-vulnerabilities/"
   strings:
      $uniq1 = "HttpCookie newcook = new HttpCookie(\"fqrspt\", HttpContext.Current.Request.Form"
      $uniq2 = "ZN2aDAB4rXsszEvCLrzgcvQ4oi5J1TuiRULlQbYwldE="

      $var1 = "Result.InnerText = string.Empty;"
      $var2 = "newcook.Expires = DateTime.Now.AddDays("
      $var3 = "System.Diagnostics.Process process = new System.Diagnostics.Process();"
      $var4 = "process.StandardInput.WriteLine(HttpContext.Current.Request.Form[\""
      $var5 = "else if (!string.IsNullOrEmpty(HttpContext.Current.Request.Form[\""
      $var6 = "<input type=\"submit\" value=\"Upload\" />"
   condition:
      any of ($uniq*) or
      all of ($var*)
}

rule WEBSHELL_CVE_2021_27065_Webshells {
   meta:
      description = "Detects web shells dropped by CVE-2021-27065. All actors, not specific to HAFNIUM. TLP:WHITE"
      author = "Joe Hannon, Microsoft Threat Intelligence Center (MSTIC)"
      date = "2021-03-05"
      reference = "https://www.microsoft.com/security/blog/2021/03/02/hafnium-targeting-exchange-servers/"
   strings:
      $script1 = "script language" ascii wide nocase
      $script2 = "page language" ascii wide nocase
      $script3 = "runat=\"server\"" ascii wide nocase
      $script4 = "/script" ascii wide nocase
      $externalurl = "externalurl" ascii wide nocase
      $internalurl = "internalurl" ascii wide nocase
      $internalauthenticationmethods = "internalauthenticationmethods" ascii wide nocase
      $extendedprotectiontokenchecking = "extendedprotectiontokenchecking" ascii wide nocase
   condition:
      filesize < 50KB and any of ($script*) and ($externalurl or $internalurl) and $internalauthenticationmethods and $extendedprotectiontokenchecking
}

rule APT_MAL_ASPX_HAFNIUM_Chopper_Mar21_3 {
   meta:
      description = "Detects HAFNIUM ASPX files dropped on compromised servers"
      author = "Florian Roth"
      reference = "https://www.microsoft.com/security/blog/2021/03/02/hafnium-targeting-exchange-servers/"
      date = "2021-03-07"
      score = 85
   strings:
      $s1 = "runat=\"server\">void Page_Load(object" ascii wide 
      $s2 = "Request.Files[0].SaveAs(Server.MapPath(" ascii wide
   condition:
      filesize < 50KB and
      all of them
}

rule APT_MAL_ASPX_HAFNIUM_Chopper_Mar21_4 {
   meta:
      description = "Detects HAFNIUM ASPX files dropped on compromised servers"
      author = "Florian Roth"
      reference = "https://www.microsoft.com/security/blog/2021/03/02/hafnium-targeting-exchange-servers/"
      date = "2021-03-07"
      score = 85
   strings:
      $s1 = "<%@Page Language=\"Jscript\"%>" ascii wide nocase
      $s2 = ".FromBase64String(" ascii wide nocase
      $s3 = "eval(System.Text.Encoding." ascii wide nocase
   condition:
      filesize < 850 and
      all of them
}

rule APT_HAFNIUM_ForensicArtefacts_WER_Mar21_1 {
   meta:
      description = "Detects a Windows Error Report (WER) that indicates and exploitation attempt of the Exchange server as described in CVE-2021-26857 after the corresponding patches have been applied. WER files won't be written upon successful exploitation before applying the patch. Therefore, this indicates an unsuccessful attempt."
      author = "Florian Roth"
      reference = "https://twitter.com/cyb3rops/status/1368471533048446976"
      date = "2021-03-07"
      score = 40
   strings:
      $s1 = "AppPath=c:\\windows\\system32\\inetsrv\\w3wp.exe" wide fullword
      $s7 = ".Value=w3wp#MSExchangeECPAppPool" wide
   condition:
      uint16(0) == 0xfeff and
      filesize < 8KB and
      all of them
}

rule APT_HAFNIUM_ForensicArtefacts_Cab_Recon_Mar21_1 {
   meta:
      description = "Detects suspicious CAB files used by HAFNIUM for recon activity"
      author = "Florian Roth"
      reference = "https://discuss.elastic.co/t/detection-and-response-for-hafnium-activity/266289/3?u=dstepanic"
      date = "2021-03-11"
      score = 70
   strings:
      $s1 = "ip.txt" ascii fullword
      $s2 = "arp.txt" ascii fullword
      $s3 = "system" ascii fullword 
      $s4 = "security" ascii fullword
   condition:
      uint32(0) == 0x4643534d and
      filesize < 10000KB and (
         $s1 in (0..200) and 
         $s2 in (0..200) and
         $s3 in (0..200) and
         $s4 in (0..200)
      )
}

rule WEBSHELL_Compiled_Webshell_Mar2021_1 {
   meta:
      description = "Triggers on temporary pe files containing strings commonly used in webshells."
      author = "Bundesamt fuer Sicherheit in der Informationstechnik"
      date = "2021-03-05"
      modified = "2021-03-12"
      reference = "https://www.bsi.bund.de/SharedDocs/Downloads/DE/BSI/Cyber-Sicherheit/Vorfaelle/Exchange-Schwachstellen-2021/MSExchange_Schwachstelle_Detektion_Reaktion.pdf"
   strings:
      $x1 = /App_Web_[a-zA-Z0-9]{7,8}.dll/ ascii wide fullword
      $a1 = "~/aspnet_client/" ascii wide nocase
      $a2 = "~/auth/" ascii wide nocase
      $b1 = "JScriptEvaluate" ascii wide fullword
      $c1 = "get_Request" ascii wide fullword
      $c2 = "get_Files" ascii wide fullword
      $c3 = "get_Count" ascii wide fullword
      $c4 = "get_Item" ascii wide fullword
      $c5 = "get_Server" ascii wide fullword
   condition:
      uint16(0) == 0x5a4d and filesize > 5KB and filesize < 40KB and all of ($x*) and 1 of ($a*) and ( all of ($b*) or all of ($c*) )
}

rule APT_MAL_ASP_DLL_HAFNIUM_Mar21_1 {
   meta:
      description = "Detects HAFNIUM compiled ASP.NET DLLs dropped on compromised servers"
      author = "Florian Roth"
      reference = "https://www.microsoft.com/security/blog/2021/03/02/hafnium-targeting-exchange-servers/"
      date = "2021-03-05"
      score = 65
      hash1 = "097f5f700c000a13b91855beb61a931d34fb0abb738a110368f525e25c5bc738"
      hash2 = "15744e767cbaa9b37ff7bb5c036dda9b653fc54fc9a96fe73fbd639150b3daa3"
      hash3 = "52ae4de2e3f0ef7fe27c699cb60d41129a3acd4a62be60accc85d88c296e1ddb"
      hash4 = "5f0480035ee23a12302c88be10e54bf3adbcf271a4bb1106d4975a28234d3af8"
      hash5 = "6243fd2826c528ee329599153355fd00153dee611ca33ec17effcf00205a6e4e"
      hash6 = "ebf6799bb86f0da2b05e66a0fe5a9b42df6dac848f4b951b2ed7b7a4866f19ef"
   strings:
      $s1 = "Page_Load" ascii fullword
      
      $sc1 = { 20 00 3A 00 20 00 68 00 74 00 74 00 70 00 3A 00
               2F 00 2F 00 (66|67) 00 2F 00 00 89 A3 0D 00 0A 00 }

      $op1 = { 00 43 00 58 00 77 00 30 00 4a 00 45 00 00 51 7e 00 2f }
      $op2 = { 58 00 77 00 30 00 4a 00 45 00 00 51 7e 00 2f 00 61 00 }
      $op3 = { 01 0e 0e 05 20 01 01 11 79 04 07 01 12 2d 04 07 01 12 31 02 }
      $op4 = { 5e 00 03 00 bc 22 00 00 00 00 01 00 85 03 2b 00 03 00 cc }
   condition:
      uint16(0) == 0x5a4d and
      filesize < 50KB and
      all of ($s*) or all of ($op*)
}


rule WEBSHELL_HAFNIUM_CISA_10328929_01 : trojan webshell exploit CVE_2021_27065 {
   meta:
       author = "CISA Code & Media Analysis"
       date = "2021-03-17"
       description = "Detects CVE-2021-27065 Webshellz"
       hash = "c8a7b5ffcf23c7a334bb093dda19635ec06ca81f6196325bb2d811716c90f3c5"
       reference = "https://us-cert.cisa.gov/ncas/analysis-reports/ar21-084a"
   strings:
       $s0 = { 65 76 61 6C 28 52 65 71 75 65 73 74 5B 22 [1-32] 5D 2C 22 75 6E 73 61 66 65 22 29 }
       $s1 = { 65 76 61 6C 28 }
       $s2 = { 28 52 65 71 75 65 73 74 2E 49 74 65 6D 5B [1-36] 5D 29 29 2C 22 75 6E 73 61 66 65 22 29 }
       $s3 = { 49 4F 2E 53 74 72 65 61 6D 57 72 69 74 65 72 28 52 65 71 75 65 73 74 2E 46 6F 72 6D 5B [1-24] 5D }
       $s4 = { 57 72 69 74 65 28 52 65 71 75 65 73 74 2E 46 6F 72 6D 5B [1-24] 5D }
   condition:
       $s0 or ($s1 and $s2) or ($s3 and $s4)
}

rule WEBSHELL_HAFNIUM_CISA_10328929_02 : trojan webshell exploit CVE_2021_27065 {
   meta:
       author = "CISA Code & Media Analysis"
       date = "2021-03-17"
       description = "Detects CVE-2021-27065 Exchange OAB VD MOD"
       hash = "c8a7b5ffcf23c7a334bb093dda19635ec06ca81f6196325bb2d811716c90f3c5"
       reference = "https://us-cert.cisa.gov/ncas/analysis-reports/ar21-084a"
   strings:
       $s0 = { 4F 66 66 6C 69 6E 65 41 64 64 72 65 73 73 42 6F 6F 6B 73 }
       $s1 = { 3A 20 68 74 74 70 3A 2F 2F [1] 2F }
       $s2 = { 45 78 74 65 72 6E 61 6C 55 72 6C 20 20 20 20 }
   condition:
       $s0 and $s1 and $s2
}


rule WEBSHELL_ASPX_FileExplorer_Mar21_1 {
   meta:
      description = "Detects Chopper like ASPX Webshells"
      author = "Florian Roth"
      reference = "Internal Research"
      date = "2021-03-31"
      score = 80
      hash1 = "a8c63c418609c1c291b3e731ca85ded4b3e0fba83f3489c21a3199173b176a75"
   strings:
      $x1 = "<span style=\"background-color: #778899; color: #fff; padding: 5px; cursor: pointer\" onclick=" ascii
      $xc1 = { 3C 61 73 70 3A 48 69 64 64 65 6E 46 69 65 6C 64
               20 72 75 6E 61 74 3D 22 73 65 72 76 65 72 22 20
               49 44 3D 22 ?? ?? ?? ?? ?? 22 20 2F 3E 3C 62 72
               20 2F 3E 3C 62 72 20 2F 3E 20 50 72 6F 63 65 73
               73 20 4E 61 6D 65 3A 3C 61 73 70 3A 54 65 78 74
               42 6F 78 20 49 44 3D } 
      $xc2 = { 22 3E 43 6F 6D 6D 61 6E 64 3C 2F 6C 61 62 65 6C
               3E 3C 69 6E 70 75 74 20 69 64 3D 22 ?? ?? ?? ??
               ?? 22 20 74 79 70 65 3D 22 72 61 64 69 6F 22 20
               6E 61 6D 65 3D 22 74 61 62 73 22 3E 3C 6C 61 62
               65 6C 20 66 6F 72 3D 22 ?? ?? ?? ?? ?? 22 3E 46
               69 6C 65 20 45 78 70 6C 6F 72 65 72 3C 2F 6C 61
               62 65 6C 3E 3C 25 2D 2D }

      $r1 = "(Request.Form[" ascii
      $s1 = ".Text + \" Created!\";" ascii
      $s2 = "DriveInfo.GetDrives()" ascii
      $s3 = "Encoding.UTF8.GetString(FromBase64String(str.Replace(" ascii
      $s4 = "encodeURIComponent(btoa(String.fromCharCode.apply(null, new Uint8Array(bytes))));;"
   condition:
      uint16(0) == 0x253c and
      filesize < 100KB and
      ( 1 of ($x*) or 2 of them ) or 4 of them
}

rule WEBSHELL_ASPX_Chopper_Like_Mar21_1 {
   meta:
      description = "Detects Chopper like ASPX Webshells"
      author = "Florian Roth"
      reference = "Internal Research"
      date = "2021-03-31"
      score = 85
      hash1 = "ac44513e5ef93d8cbc17219350682c2246af6d5eb85c1b4302141d94c3b06c90"
   strings:
      $s1 = "http://f/<script language=\"JScript\" runat=\"server\">var _0x" ascii
      $s2 = "));function Page_Load(){var _0x" ascii
      $s3 = ";eval(Request[_0x" ascii
      $s4 = "','orange','unsafe','" ascii
   condition:
      filesize < 3KB and
      1 of them or 2 of them
}

rule webshell_php_generic
{
	meta:
		description = "php webshell having some kind of input and some kind of payload. restricted to small files or big ones inclusing suspicious strings"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/14"
		hash = "bee1b76b1455105d4bfe2f45191071cf05e83a309ae9defcf759248ca9bceddd"

	strings:
		$wfp_tiny1 = "escapeshellarg" fullword
		$wfp_tiny2 = "addslashes" fullword
	
		//strings from private rule php_false_positive_tiny
		// try to use only strings which would be flagged by themselves as suspicous by other rules, e.g. eval 
		//$gfp_tiny1 = "addslashes" fullword
		//$gfp_tiny2 = "escapeshellarg" fullword
		$gfp_tiny3 = "include \"./common.php\";" // xcache
		$gfp_tiny4 = "assert('FALSE');"
		$gfp_tiny5 = "assert(false);"
		$gfp_tiny6 = "assert(FALSE);"
		$gfp_tiny7 = "assert('array_key_exists("
		$gfp_tiny8 = "echo shell_exec($aspellcommand . ' 2>&1');"
		$gfp_tiny9 = "throw new Exception('Could not find authentication source with id ' . $sourceId);"
		$gfp_tiny10= "return isset( $_POST[ $key ] ) ? $_POST[ $key ] : ( isset( $_REQUEST[ $key ] ) ? $_REQUEST[ $key ] : $default );"
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
		//strings from private rule capa_php_input
		$inp1 = "php://input" wide ascii
		$inp2 = /_GET\s?\[/ wide ascii
        // for passing $_GET to a function 
		$inp3 = /\(\s?\$_GET\s?\)/ wide ascii
		$inp4 = /_POST\s?\[/ wide ascii
		$inp5 = /\(\s?\$_POST\s?\)/ wide ascii
		$inp6 = /_REQUEST\s?\[/ wide ascii
		$inp7 = /\(\s?\$_REQUEST\s?\)/ wide ascii
		// PHP automatically adds all the request headers into the $_SERVER global array, prefixing each header name by the "HTTP_" string, so e.g. @eval($_SERVER['HTTP_CMD']) will run any code in the HTTP header CMD
		$inp15 = "_SERVER['HTTP_" wide ascii
		$inp16 = "_SERVER[\"HTTP_" wide ascii
		$inp17 = /getenv[\t ]{0,20}\([\t ]{0,20}['"]HTTP_/ wide ascii
		$inp18 = "array_values($_SERVER)" wide ascii
		$inp19 = /file_get_contents\("https?:\/\// wide ascii
	
		//strings from private rule capa_php_payload
		// \([^)] to avoid matching on e.g. eval() in comments
		$cpayload1 = /\beval[\t ]*\([^)]/ nocase wide ascii
		$cpayload2 = /\bexec[\t ]*\([^)]/ nocase wide ascii
		$cpayload3 = /\bshell_exec[\t ]*\([^)]/ nocase wide ascii
		$cpayload4 = /\bpassthru[\t ]*\([^)]/ nocase wide ascii
		$cpayload5 = /\bsystem[\t ]*\([^)]/ nocase wide ascii
		$cpayload6 = /\bpopen[\t ]*\([^)]/ nocase wide ascii
		$cpayload7 = /\bproc_open[\t ]*\([^)]/ nocase wide ascii
		$cpayload8 = /\bpcntl_exec[\t ]*\([^)]/ nocase wide ascii
		$cpayload9 = /\bassert[\t ]*\([^)0]/ nocase wide ascii
		$cpayload10 = /\bpreg_replace[\t ]*\(.{1,100}\/[ismxADSUXju]{0,11}(e|\\x65)/ nocase wide ascii
		$cpayload12 = /\bmb_ereg_replace[\t ]*\([^\)]{1,100}'e'/ nocase wide ascii
		$cpayload13 = /\bmb_eregi_replace[\t ]*\([^\)]{1,100}'e'/ nocase wide ascii
		$cpayload20 = /\bcreate_function[\t ]*\([^)]/ nocase wide ascii
		$cpayload21 = /\bReflectionFunction[\t ]*\([^)]/ nocase wide ascii

		$m_cpayload_preg_filter1 = /\bpreg_filter[\t ]*\([^\)]/ nocase wide ascii
		$m_cpayload_preg_filter2 = "'|.*|e'" nocase wide ascii
		// TODO backticks
	
		//strings from private rule capa_gen_sus

        // these strings are just a bit suspicious, so several of them are needed, depending on filesize
        $gen_bit_sus1  = /:\s{0,20}eval}/ nocase wide ascii
        $gen_bit_sus2  = /\.replace\(\/\w\/g/ nocase wide ascii
        $gen_bit_sus6  = "self.delete"
        $gen_bit_sus9  = "\"cmd /c" nocase
        $gen_bit_sus10 = "\"cmd\"" nocase
        $gen_bit_sus11 = "\"cmd.exe" nocase
        $gen_bit_sus12 = "%comspec%" wide ascii
        $gen_bit_sus13 = "%COMSPEC%" wide ascii
        //TODO:$gen_bit_sus12 = ".UserName" nocase
        $gen_bit_sus18 = "Hklm.GetValueNames();" nocase
        // bonus string for proxylogon exploiting webshells
        $gen_bit_sus19 = "http://schemas.microsoft.com/exchange/" wide ascii
        $gen_bit_sus21 = "\"upload\"" wide ascii
        $gen_bit_sus22 = "\"Upload\"" wide ascii
        $gen_bit_sus23 = "UPLOAD" fullword wide ascii
        $gen_bit_sus24 = "fileupload" wide ascii
        $gen_bit_sus25 = "file_upload" wide ascii
        // own base64 func
        $gen_bit_sus29 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" fullword wide ascii
        $gen_bit_sus30 = "serv-u" wide ascii
        $gen_bit_sus31 = "Serv-u" wide ascii
        $gen_bit_sus32 = "Army" fullword wide ascii
        // single letter paramweter
        $gen_bit_sus33 = /\$_(GET|POST|REQUEST)\["\w"\]/ fullword wide ascii
        $gen_bit_sus34 = "Content-Transfer-Encoding: Binary" wide ascii
        $gen_bit_sus35 = "crack" fullword wide ascii

        $gen_bit_sus44 = "<pre>" wide ascii
        $gen_bit_sus45 = "<PRE>" wide ascii
        $gen_bit_sus46 = "shell_" wide ascii
        $gen_bit_sus47 = "Shell" fullword wide ascii
        $gen_bit_sus50 = "bypass" wide ascii
        $gen_bit_sus51 = "suhosin" wide ascii
        $gen_bit_sus52 = " ^ $" wide ascii
        $gen_bit_sus53 = ".ssh/authorized_keys" wide ascii
        $gen_bit_sus55 = /\w'\.'\w/ wide ascii
        $gen_bit_sus56 = /\w\"\.\"\w/ wide ascii
        $gen_bit_sus57 = "dumper" wide ascii
        $gen_bit_sus59 = "'cmd'" wide ascii
        $gen_bit_sus60 = "\"execute\"" wide ascii
        $gen_bit_sus61 = "/bin/sh" wide ascii
        $gen_bit_sus62 = "Cyber" wide ascii
        $gen_bit_sus63 = "portscan" fullword wide ascii
        //$gen_bit_sus64 = "\"command\"" fullword wide ascii
        //$gen_bit_sus65 = "'command'" fullword wide ascii
        $gen_bit_sus66 = "whoami" fullword wide ascii
        $gen_bit_sus67 = "$password='" fullword wide ascii
        $gen_bit_sus68 = "$password=\"" fullword wide ascii
        $gen_bit_sus69 = "$cmd" fullword wide ascii
        $gen_bit_sus70 = "\"?>\"." fullword wide ascii
        $gen_bit_sus71 = "Hacking" fullword wide ascii
        $gen_bit_sus72 = "hacking" fullword wide ascii
        $gen_bit_sus73 = ".htpasswd" wide ascii
        $gen_bit_sus74 = /\btouch\(\$[^,]{1,30},/ wide ascii

        // very suspicious strings, one is enough
        $gen_much_sus7  = "Web Shell" nocase
        $gen_much_sus8  = "WebShell" nocase
        $gen_much_sus3  = "hidded shell" 
        $gen_much_sus4  = "WScript.Shell.1" nocase
        $gen_much_sus5  = "AspExec" 
        $gen_much_sus14 = "\\pcAnywhere\\" nocase
        $gen_much_sus15 = "antivirus" nocase
        $gen_much_sus16 = "McAfee" nocase
        $gen_much_sus17 = "nishang" 
        $gen_much_sus18 = "\"unsafe" fullword wide ascii
        $gen_much_sus19 = "'unsafe" fullword wide ascii
        $gen_much_sus24 = "exploit" fullword wide ascii
        $gen_much_sus25 = "Exploit" fullword wide ascii
        $gen_much_sus26 = "TVqQAAMAAA" wide ascii
        $gen_much_sus30 = "Hacker" wide ascii
        $gen_much_sus31 = "HACKED" fullword wide ascii
        $gen_much_sus32 = "hacked" fullword wide ascii
        $gen_much_sus33 = "hacker" wide ascii
        $gen_much_sus34 = "grayhat" nocase wide ascii
        $gen_much_sus35 = "Microsoft FrontPage" wide ascii
        $gen_much_sus36 = "Rootkit" wide ascii
        $gen_much_sus37 = "rootkit" wide ascii
        $gen_much_sus38 = "/*-/*-*/" wide ascii
        $gen_much_sus39 = "u\"+\"n\"+\"s" wide ascii
        $gen_much_sus40 = "\"e\"+\"v" wide ascii
        $gen_much_sus41 = "a\"+\"l\"" wide ascii
        $gen_much_sus42 = "\"+\"(\"+\"" wide ascii
        $gen_much_sus43 = "q\"+\"u\"" wide ascii
        $gen_much_sus44 = "\"u\"+\"e" wide ascii
        $gen_much_sus45 = "/*//*/" wide ascii
        $gen_much_sus46 = "(\"/*/\"" wide ascii
        $gen_much_sus47 = "eval(eval(" wide ascii
        // self remove
        $gen_much_sus48 = "unlink(__FILE__)" wide ascii
        $gen_much_sus49 = "Shell.Users" wide ascii
        $gen_much_sus50 = "PasswordType=Regular" wide ascii
        $gen_much_sus51 = "-Expire=0" wide ascii
        $gen_much_sus60 = "_=$$_" wide ascii
        $gen_much_sus61 = "_=$$_" wide ascii
        $gen_much_sus62 = "++;$" wide ascii
        $gen_much_sus63 = "++; $" wide ascii
        $gen_much_sus64 = "_.=$_" wide ascii
        $gen_much_sus70 = "-perm -04000" wide ascii
        $gen_much_sus71 = "-perm -02000" wide ascii
        $gen_much_sus72 = "grep -li password" wide ascii
        $gen_much_sus73 = "-name config.inc.php" wide ascii
        // touch without parameters sets the time to now, not malicious and gives fp
        $gen_much_sus75 = "password crack" wide ascii
        $gen_much_sus76 = "mysqlDll.dll" wide ascii
        $gen_much_sus77 = "net user" wide ascii
        $gen_much_sus78 = "suhosin.executor.disable_" wide ascii
        $gen_much_sus79 = "disabled_suhosin" wide ascii
        $gen_much_sus80 = "fopen(\".htaccess\",\"w" wide ascii
        $gen_much_sus81 = /strrev\(['"]/ wide ascii
        $gen_much_sus82 = "PHPShell" fullword wide ascii
        $gen_much_sus821= "PHP Shell" fullword wide ascii
        $gen_much_sus83 = "phpshell" fullword wide ascii
        $gen_much_sus84 = "PHPshell" fullword wide ascii
        $gen_much_sus87 = "deface" wide ascii
        $gen_much_sus88 = "Deface" wide ascii
        $gen_much_sus89 = "backdoor" wide ascii
        $gen_much_sus90 = "r00t" fullword wide ascii
        $gen_much_sus91 = "xp_cmdshell" fullword wide ascii

        $gif = { 47 49 46 38 }

	
		//strings from private rule capa_php_payload_multiple
		// \([^)] to avoid matching on e.g. eval() in comments
		$cmpayload1 = /\beval[\t ]*\([^)]/ nocase wide ascii
		$cmpayload2 = /\bexec[\t ]*\([^)]/ nocase wide ascii
		$cmpayload3 = /\bshell_exec[\t ]*\([^)]/ nocase wide ascii
		$cmpayload4 = /\bpassthru[\t ]*\([^)]/ nocase wide ascii
		$cmpayload5 = /\bsystem[\t ]*\([^)]/ nocase wide ascii
		$cmpayload6 = /\bpopen[\t ]*\([^)]/ nocase wide ascii
		$cmpayload7 = /\bproc_open[\t ]*\([^)]/ nocase wide ascii
		$cmpayload8 = /\bpcntl_exec[\t ]*\([^)]/ nocase wide ascii
		$cmpayload9 = /\bassert[\t ]*\([^)0]/ nocase wide ascii
		$cmpayload10 = /\bpreg_replace[\t ]*\([^\)]{1,100}\/e/ nocase wide ascii
		$cmpayload11 = /\bpreg_filter[\t ]*\([^\)]{1,100}\/e/ nocase wide ascii
		$cmpayload12 = /\bmb_ereg_replace[\t ]*\([^\)]{1,100}'e'/ nocase wide ascii
		$cmpayload20 = /\bcreate_function[\t ]*\([^)]/ nocase wide ascii
		$cmpayload21 = /\bReflectionFunction[\t ]*\([^)]/ nocase wide ascii
	
	condition:
		not ( 
			any of ( $gfp_tiny* ) 
		)
		and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and ( 
			any of ( $inp* ) 
		)
		and ( 
			any of ( $cpayload* ) or
        all of ( $m_cpayload_preg_filter* ) 
		)
		and 
		( ( filesize < 1000 and not any of ( $wfp_tiny* ) ) or 
		( ( 
        $gif at 0 or
        (
            filesize < 4KB and 
            (
                1 of ( $gen_much_sus* ) or
                2 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 20KB and 
            (
                2 of ( $gen_much_sus* ) or
                3 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 50KB and 
            (
                2 of ( $gen_much_sus* ) or
                4 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 100KB and 
            (
                2 of ( $gen_much_sus* ) or
                6 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 150KB and 
            (
                3 of ( $gen_much_sus* ) or
                7 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 500KB and 
            (
                4 of ( $gen_much_sus* ) or
                8 of ( $gen_bit_sus* )
            )
        ) 
		)
		and 
		( filesize > 5KB or not any of ( $wfp_tiny* ) ) ) or 
		( filesize < 500KB and ( 
			4 of ( $cmpayload* ) 
		)
		) )
}

rule webshell_php_generic_callback
{
	meta:
		description = "php webshell having some kind of input and using a callback to execute the payload. restricted to small files or would give lots of false positives"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/14"
		hash = "e98889690101b59260e871c49263314526f2093f"

	strings:

		//strings from private rule php_false_positive
		// try to use only strings which would be flagged by themselves as suspicous by other rules, e.g. eval 
        // a good choice is a string with good atom quality = ideally 4 unusual characters next to each other
		$gfp1  = "eval(\"return [$serialised_parameter" // elgg
		$gfp2  = "$this->assert(strpos($styles, $"
		$gfp3  = "$module = new $_GET['module']($_GET['scope']);"
		$gfp4  = "$plugin->$_POST['action']($_POST['id']);"
		$gfp5  = "$_POST[partition_by]($_POST["
		$gfp6  = "$object = new $_REQUEST['type']($_REQUEST['id']);"
		$gfp7  = "The above example code can be easily exploited by passing in a string such as" // ... ;)
		$gfp8  = "Smarty_Internal_Debug::start_render($_template);"
		$gfp9  = "?p4yl04d=UNION%20SELECT%20'<?%20system($_GET['command']);%20?>',2,3%20INTO%20OUTFILE%20'/var/www/w3bsh3ll.php"
		$gfp10 = "[][}{;|]\\|\\\\[+=]\\|<?=>?"
		$gfp11 = "(eval (getenv \"EPROLOG\")))"
		$gfp12 = "ZmlsZV9nZXRfY29udGVudHMoJ2h0dHA6Ly9saWNlbnNlLm9wZW5jYXJ0LWFwaS5jb20vbGljZW5zZS5waHA/b3JkZXJ"
	
		//strings from private rule php_false_positive_tiny
		// try to use only strings which would be flagged by themselves as suspicous by other rules, e.g. eval 
		//$gfp_tiny1 = "addslashes" fullword
		//$gfp_tiny2 = "escapeshellarg" fullword
		$gfp_tiny3 = "include \"./common.php\";" // xcache
		$gfp_tiny4 = "assert('FALSE');"
		$gfp_tiny5 = "assert(false);"
		$gfp_tiny6 = "assert(FALSE);"
		$gfp_tiny7 = "assert('array_key_exists("
		$gfp_tiny8 = "echo shell_exec($aspellcommand . ' 2>&1');"
		$gfp_tiny9 = "throw new Exception('Could not find authentication source with id ' . $sourceId);"
		$gfp_tiny10= "return isset( $_POST[ $key ] ) ? $_POST[ $key ] : ( isset( $_REQUEST[ $key ] ) ? $_REQUEST[ $key ] : $default );"
	
		//strings from private rule capa_php_input
		$inp1 = "php://input" wide ascii
		$inp2 = /_GET\s?\[/ wide ascii
        // for passing $_GET to a function 
		$inp3 = /\(\s?\$_GET\s?\)/ wide ascii
		$inp4 = /_POST\s?\[/ wide ascii
		$inp5 = /\(\s?\$_POST\s?\)/ wide ascii
		$inp6 = /_REQUEST\s?\[/ wide ascii
		$inp7 = /\(\s?\$_REQUEST\s?\)/ wide ascii
		// PHP automatically adds all the request headers into the $_SERVER global array, prefixing each header name by the "HTTP_" string, so e.g. @eval($_SERVER['HTTP_CMD']) will run any code in the HTTP header CMD
		$inp15 = "_SERVER['HTTP_" wide ascii
		$inp16 = "_SERVER[\"HTTP_" wide ascii
		$inp17 = /getenv[\t ]{0,20}\([\t ]{0,20}['"]HTTP_/ wide ascii
		$inp18 = "array_values($_SERVER)" wide ascii
		$inp19 = /file_get_contents\("https?:\/\// wide ascii
	
		//strings from private rule capa_php_callback
		$callback1 = /\bob_start[\t ]*\([^)]/ nocase wide ascii
		$callback2 = /\barray_diff_uassoc[\t ]*\([^)]/ nocase wide ascii
		$callback3 = /\barray_diff_ukey[\t ]*\([^)]/ nocase wide ascii
		$callback4 = /\barray_filter[\t ]*\([^)]/ nocase wide ascii
		$callback5 = /\barray_intersect_uassoc[\t ]*\([^)]/ nocase wide ascii
		$callback6 = /\barray_intersect_ukey[\t ]*\([^)]/ nocase wide ascii
		$callback7 = /\barray_map[\t ]*\([^)]/ nocase wide ascii
		$callback8 = /\barray_reduce[\t ]*\([^)]/ nocase wide ascii
		$callback9 = /\barray_udiff_assoc[\t ]*\([^)]/ nocase wide ascii
		$callback10 = /\barray_udiff_uassoc[\t ]*\([^)]/ nocase wide ascii
		$callback11 = /\barray_udiff[\t ]*\([^)]/ nocase wide ascii
		$callback12 = /\barray_uintersect_assoc[\t ]*\([^)]/ nocase wide ascii
		$callback13 = /\barray_uintersect_uassoc[\t ]*\([^)]/ nocase wide ascii
		$callback14 = /\barray_uintersect[\t ]*\([^)]/ nocase wide ascii
		$callback15 = /\barray_walk_recursive[\t ]*\([^)]/ nocase wide ascii
		$callback16 = /\barray_walk[\t ]*\([^)]/ nocase wide ascii
		$callback17 = /\bassert_options[\t ]*\([^)]/ nocase wide ascii
		$callback18 = /\buasort[\t ]*\([^)]/ nocase wide ascii
		$callback19 = /\buksort[\t ]*\([^)]/ nocase wide ascii
		$callback20 = /\busort[\t ]*\([^)]/ nocase wide ascii
		$callback21 = /\bpreg_replace_callback[\t ]*\([^)]/ nocase wide ascii
		$callback22 = /\bspl_autoload_register[\t ]*\([^)]/ nocase wide ascii
		$callback23 = /\biterator_apply[\t ]*\([^)]/ nocase wide ascii
		$callback24 = /\bcall_user_func[\t ]*\([^)]/ nocase wide ascii
		$callback25 = /\bcall_user_func_array[\t ]*\([^)]/ nocase wide ascii
		$callback26 = /\bregister_shutdown_function[\t ]*\([^)]/ nocase wide ascii
		$callback27 = /\bregister_tick_function[\t ]*\([^)]/ nocase wide ascii
		$callback28 = /\bset_error_handler[\t ]*\([^)]/ nocase wide ascii
		$callback29 = /\bset_exception_handler[\t ]*\([^)]/ nocase wide ascii
		$callback30 = /\bsession_set_save_handler[\t ]*\([^)]/ nocase wide ascii
		$callback31 = /\bsqlite_create_aggregate[\t ]*\([^)]/ nocase wide ascii
		$callback32 = /\bsqlite_create_function[\t ]*\([^)]/ nocase wide ascii
		$callback33 = /\bmb_ereg_replace_callback[\t ]*\([^)]/ nocase wide ascii

		$m_callback1 = /\bfilter_var[\t ]*\([^)]/ nocase wide ascii
		$m_callback2 = "FILTER_CALLBACK" fullword wide ascii

		$cfp1 = /ob_start\(['\"]ob_gzhandler/ nocase wide ascii
        $cfp2 = "IWPML_Backend_Action_Loader" ascii wide
		$cfp3 = "<?phpclass WPML" ascii
	
		//strings from private rule capa_gen_sus

        // these strings are just a bit suspicious, so several of them are needed, depending on filesize
        $gen_bit_sus1  = /:\s{0,20}eval}/ nocase wide ascii
        $gen_bit_sus2  = /\.replace\(\/\w\/g/ nocase wide ascii
        $gen_bit_sus6  = "self.delete"
        $gen_bit_sus9  = "\"cmd /c" nocase
        $gen_bit_sus10 = "\"cmd\"" nocase
        $gen_bit_sus11 = "\"cmd.exe" nocase
        $gen_bit_sus12 = "%comspec%" wide ascii
        $gen_bit_sus13 = "%COMSPEC%" wide ascii
        //TODO:$gen_bit_sus12 = ".UserName" nocase
        $gen_bit_sus18 = "Hklm.GetValueNames();" nocase
        // bonus string for proxylogon exploiting webshells
        $gen_bit_sus19 = "http://schemas.microsoft.com/exchange/" wide ascii
        $gen_bit_sus21 = "\"upload\"" wide ascii
        $gen_bit_sus22 = "\"Upload\"" wide ascii
        $gen_bit_sus23 = "UPLOAD" fullword wide ascii
        $gen_bit_sus24 = "fileupload" wide ascii
        $gen_bit_sus25 = "file_upload" wide ascii
        // own base64 func
        $gen_bit_sus29 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" fullword wide ascii
        $gen_bit_sus30 = "serv-u" wide ascii
        $gen_bit_sus31 = "Serv-u" wide ascii
        $gen_bit_sus32 = "Army" fullword wide ascii
        // single letter paramweter
        $gen_bit_sus33 = /\$_(GET|POST|REQUEST)\["\w"\]/ fullword wide ascii
        $gen_bit_sus34 = "Content-Transfer-Encoding: Binary" wide ascii
        $gen_bit_sus35 = "crack" fullword wide ascii

        $gen_bit_sus44 = "<pre>" wide ascii
        $gen_bit_sus45 = "<PRE>" wide ascii
        $gen_bit_sus46 = "shell_" wide ascii
        $gen_bit_sus47 = "Shell" fullword wide ascii
        $gen_bit_sus50 = "bypass" wide ascii
        $gen_bit_sus51 = "suhosin" wide ascii
        $gen_bit_sus52 = " ^ $" wide ascii
        $gen_bit_sus53 = ".ssh/authorized_keys" wide ascii
        $gen_bit_sus55 = /\w'\.'\w/ wide ascii
        $gen_bit_sus56 = /\w\"\.\"\w/ wide ascii
        $gen_bit_sus57 = "dumper" wide ascii
        $gen_bit_sus59 = "'cmd'" wide ascii
        $gen_bit_sus60 = "\"execute\"" wide ascii
        $gen_bit_sus61 = "/bin/sh" wide ascii
        $gen_bit_sus62 = "Cyber" wide ascii
        $gen_bit_sus63 = "portscan" fullword wide ascii
        //$gen_bit_sus64 = "\"command\"" fullword wide ascii
        //$gen_bit_sus65 = "'command'" fullword wide ascii
        $gen_bit_sus66 = "whoami" fullword wide ascii
        $gen_bit_sus67 = "$password='" fullword wide ascii
        $gen_bit_sus68 = "$password=\"" fullword wide ascii
        $gen_bit_sus69 = "$cmd" fullword wide ascii
        $gen_bit_sus70 = "\"?>\"." fullword wide ascii
        $gen_bit_sus71 = "Hacking" fullword wide ascii
        $gen_bit_sus72 = "hacking" fullword wide ascii
        $gen_bit_sus73 = ".htpasswd" wide ascii
        $gen_bit_sus74 = /\btouch\(\$[^,]{1,30},/ wide ascii

        // very suspicious strings, one is enough
        $gen_much_sus7  = "Web Shell" nocase
        $gen_much_sus8  = "WebShell" nocase
        $gen_much_sus3  = "hidded shell" 
        $gen_much_sus4  = "WScript.Shell.1" nocase
        $gen_much_sus5  = "AspExec" 
        $gen_much_sus14 = "\\pcAnywhere\\" nocase
        $gen_much_sus15 = "antivirus" nocase
        $gen_much_sus16 = "McAfee" nocase
        $gen_much_sus17 = "nishang" 
        $gen_much_sus18 = "\"unsafe" fullword wide ascii
        $gen_much_sus19 = "'unsafe" fullword wide ascii
        $gen_much_sus24 = "exploit" fullword wide ascii
        $gen_much_sus25 = "Exploit" fullword wide ascii
        $gen_much_sus26 = "TVqQAAMAAA" wide ascii
        $gen_much_sus30 = "Hacker" wide ascii
        $gen_much_sus31 = "HACKED" fullword wide ascii
        $gen_much_sus32 = "hacked" fullword wide ascii
        $gen_much_sus33 = "hacker" wide ascii
        $gen_much_sus34 = "grayhat" nocase wide ascii
        $gen_much_sus35 = "Microsoft FrontPage" wide ascii
        $gen_much_sus36 = "Rootkit" wide ascii
        $gen_much_sus37 = "rootkit" wide ascii
        $gen_much_sus38 = "/*-/*-*/" wide ascii
        $gen_much_sus39 = "u\"+\"n\"+\"s" wide ascii
        $gen_much_sus40 = "\"e\"+\"v" wide ascii
        $gen_much_sus41 = "a\"+\"l\"" wide ascii
        $gen_much_sus42 = "\"+\"(\"+\"" wide ascii
        $gen_much_sus43 = "q\"+\"u\"" wide ascii
        $gen_much_sus44 = "\"u\"+\"e" wide ascii
        $gen_much_sus45 = "/*//*/" wide ascii
        $gen_much_sus46 = "(\"/*/\"" wide ascii
        $gen_much_sus47 = "eval(eval(" wide ascii
        // self remove
        $gen_much_sus48 = "unlink(__FILE__)" wide ascii
        $gen_much_sus49 = "Shell.Users" wide ascii
        $gen_much_sus50 = "PasswordType=Regular" wide ascii
        $gen_much_sus51 = "-Expire=0" wide ascii
        $gen_much_sus60 = "_=$$_" wide ascii
        $gen_much_sus61 = "_=$$_" wide ascii
        $gen_much_sus62 = "++;$" wide ascii
        $gen_much_sus63 = "++; $" wide ascii
        $gen_much_sus64 = "_.=$_" wide ascii
        $gen_much_sus70 = "-perm -04000" wide ascii
        $gen_much_sus71 = "-perm -02000" wide ascii
        $gen_much_sus72 = "grep -li password" wide ascii
        $gen_much_sus73 = "-name config.inc.php" wide ascii
        // touch without parameters sets the time to now, not malicious and gives fp
        $gen_much_sus75 = "password crack" wide ascii
        $gen_much_sus76 = "mysqlDll.dll" wide ascii
        $gen_much_sus77 = "net user" wide ascii
        $gen_much_sus78 = "suhosin.executor.disable_" wide ascii
        $gen_much_sus79 = "disabled_suhosin" wide ascii
        $gen_much_sus80 = "fopen(\".htaccess\",\"w" wide ascii
        $gen_much_sus81 = /strrev\(['"]/ wide ascii
        $gen_much_sus82 = "PHPShell" fullword wide ascii
        $gen_much_sus821= "PHP Shell" fullword wide ascii
        $gen_much_sus83 = "phpshell" fullword wide ascii
        $gen_much_sus84 = "PHPshell" fullword wide ascii
        $gen_much_sus87 = "deface" wide ascii
        $gen_much_sus88 = "Deface" wide ascii
        $gen_much_sus89 = "backdoor" wide ascii
        $gen_much_sus90 = "r00t" fullword wide ascii
        $gen_much_sus91 = "xp_cmdshell" fullword wide ascii

        $gif = { 47 49 46 38 }

	
	condition:
		not ( 
			any of ( $gfp* ) 
		)
		and not ( 
			any of ( $gfp_tiny* ) 
		)
		and ( 
			any of ( $inp* ) 
		)
		and ( 
			not any of ( $cfp* ) and
        (
            any of ( $callback* )  or
            all of ( $m_callback* )
        ) 
		)
		and 
		( filesize < 1000 or ( 
        $gif at 0 or
        (
            filesize < 4KB and 
            (
                1 of ( $gen_much_sus* ) or
                2 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 20KB and 
            (
                2 of ( $gen_much_sus* ) or
                3 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 50KB and 
            (
                2 of ( $gen_much_sus* ) or
                4 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 100KB and 
            (
                2 of ( $gen_much_sus* ) or
                6 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 150KB and 
            (
                3 of ( $gen_much_sus* ) or
                7 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 500KB and 
            (
                4 of ( $gen_much_sus* ) or
                8 of ( $gen_bit_sus* )
            )
        ) 
		)
		)
}

rule webshell_php_base64_encoded_payloads
{
	meta:
		description = "php webshell containing base64 encoded payload"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/07"
		hash = "88d0d4696c9cb2d37d16e330e236cb37cfaec4cd"

	strings:
		$decode1 = "base64_decode" fullword nocase wide ascii
		$decode2 = "openssl_decrypt" fullword nocase wide ascii
		// exec
		$one1 = "leGVj"
		$one2 = "V4ZW"
		$one3 = "ZXhlY"
		$one4 = "UAeABlAGMA"
		$one5 = "lAHgAZQBjA"
		$one6 = "ZQB4AGUAYw"
		// shell_exec
		$two1 = "zaGVsbF9leGVj"
		$two2 = "NoZWxsX2V4ZW"
		$two3 = "c2hlbGxfZXhlY"
		$two4 = "MAaABlAGwAbABfAGUAeABlAGMA"
		$two5 = "zAGgAZQBsAGwAXwBlAHgAZQBjA"
		$two6 = "cwBoAGUAbABsAF8AZQB4AGUAYw"
		// passthru
		$three1 = "wYXNzdGhyd"
		$three2 = "Bhc3N0aHJ1"
		$three3 = "cGFzc3Rocn"
		$three4 = "AAYQBzAHMAdABoAHIAdQ"
		$three5 = "wAGEAcwBzAHQAaAByAHUA"
		$three6 = "cABhAHMAcwB0AGgAcgB1A"
		// system
		$four1 = "zeXN0ZW"
		$four2 = "N5c3Rlb"
		$four3 = "c3lzdGVt"
		$four4 = "MAeQBzAHQAZQBtA"
		$four5 = "zAHkAcwB0AGUAbQ"
		$four6 = "cwB5AHMAdABlAG0A"
		// popen
		$five1 = "wb3Blb"
		$five2 = "BvcGVu"
		$five3 = "cG9wZW"
		$five4 = "AAbwBwAGUAbg"
		$five5 = "wAG8AcABlAG4A"
		$five6 = "cABvAHAAZQBuA"
		// proc_open
		$six1 = "wcm9jX29wZW"
		$six2 = "Byb2Nfb3Blb"
		$six3 = "cHJvY19vcGVu"
		$six4 = "AAcgBvAGMAXwBvAHAAZQBuA"
		$six5 = "wAHIAbwBjAF8AbwBwAGUAbg"
		$six6 = "cAByAG8AYwBfAG8AcABlAG4A"
		// pcntl_exec
		$seven1 = "wY250bF9leGVj"
		$seven2 = "BjbnRsX2V4ZW"
		$seven3 = "cGNudGxfZXhlY"
		$seven4 = "AAYwBuAHQAbABfAGUAeABlAGMA"
		$seven5 = "wAGMAbgB0AGwAXwBlAHgAZQBjA"
		$seven6 = "cABjAG4AdABsAF8AZQB4AGUAYw"
		// eval
		$eight1 = "ldmFs"
		$eight2 = "V2YW"
		$eight3 = "ZXZhb"
		$eight4 = "UAdgBhAGwA"
		$eight5 = "lAHYAYQBsA"
		$eight6 = "ZQB2AGEAbA"
		// assert
		$nine1 = "hc3Nlcn"
		$nine2 = "Fzc2Vyd"
		$nine3 = "YXNzZXJ0"
		$nine4 = "EAcwBzAGUAcgB0A"
		$nine5 = "hAHMAcwBlAHIAdA"
		$nine6 = "YQBzAHMAZQByAHQA"

        // false positives

        // execu
        $execu1 = "leGVjd"
		$execu2 = "V4ZWN1"
		$execu3 = "ZXhlY3"

        // esystem like e.g. filesystem
        $esystem1 = "lc3lzdGVt"
		$esystem2 = "VzeXN0ZW"
		$esystem3 = "ZXN5c3Rlb"

        // opening
        $opening1 = "vcGVuaW5n"
		$opening2 = "9wZW5pbm"
		$opening3 = "b3BlbmluZ"

        // false positives
        $fp1 = { D0 CF 11 E0 A1 B1 1A E1 }
        // api.telegram
        $fp2 = "YXBpLnRlbGVncmFtLm9" 

	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
	condition:
		filesize < 300KB and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and not any of ( $fp* ) and any of ( $decode* ) and 
		( ( any of ( $one* ) and not any of ( $execu* ) ) or any of ( $two* ) or any of ( $three* ) or 
		( any of ( $four* ) and not any of ( $esystem* ) ) or 
		( any of ( $five* ) and not any of ( $opening* ) ) or any of ( $six* ) or any of ( $seven* ) or any of ( $eight* ) or any of ( $nine* ) )
}

rule webshell_php_unknown_1
{
	meta:
		description = "obfuscated php webshell"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		hash = "12ce6c7167b33cc4e8bdec29fb1cfc44ac9487d1"
		hash = "cf4abbd568ce0c0dfce1f2e4af669ad2"
		date = "2021/01/07"

	strings:
		$sp0 = /^<\?php \$[a-z]{3,30} = '/ wide ascii
		$sp1 = "=explode(chr(" wide ascii
		$sp2 = "; if (!function_exists('" wide ascii
		$sp3 = " = NULL; for(" wide ascii

	condition:
		filesize <300KB and all of ($sp*)
}

rule webshell_php_generic_eval
{
	meta:
		description = "Generic PHP webshell which uses any eval/exec function in the same line with user input"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		hash = "a61437a427062756e2221bfb6d58cd62439d09d9"
		hash = "90c5cc724ec9cf838e4229e5e08955eec4d7bf95"
		date = "2021/01/07"

	strings:
        // new: eval($GLOBALS['_POST'
		$geval = /\b(exec|shell_exec|passthru|system|popen|proc_open|pcntl_exec|eval|assert)[\t ]*(\(base64_decode)?(\(stripslashes)?[\t ]*(\(trim)?[\t ]*\(\$(_POST|_GET|_REQUEST|_SERVER\s?\[['"]HTTP_|GLOBALS\[['"]_(POST|GET|REQUEST))/ wide ascii
	
		//strings from private rule php_false_positive
		// try to use only strings which would be flagged by themselves as suspicous by other rules, e.g. eval 
        // a good choice is a string with good atom quality = ideally 4 unusual characters next to each other
		$gfp1  = "eval(\"return [$serialised_parameter" // elgg
		$gfp2  = "$this->assert(strpos($styles, $"
		$gfp3  = "$module = new $_GET['module']($_GET['scope']);"
		$gfp4  = "$plugin->$_POST['action']($_POST['id']);"
		$gfp5  = "$_POST[partition_by]($_POST["
		$gfp6  = "$object = new $_REQUEST['type']($_REQUEST['id']);"
		$gfp7  = "The above example code can be easily exploited by passing in a string such as" // ... ;)
		$gfp8  = "Smarty_Internal_Debug::start_render($_template);"
		$gfp9  = "?p4yl04d=UNION%20SELECT%20'<?%20system($_GET['command']);%20?>',2,3%20INTO%20OUTFILE%20'/var/www/w3bsh3ll.php"
		$gfp10 = "[][}{;|]\\|\\\\[+=]\\|<?=>?"
		$gfp11 = "(eval (getenv \"EPROLOG\")))"
		$gfp12 = "ZmlsZV9nZXRfY29udGVudHMoJ2h0dHA6Ly9saWNlbnNlLm9wZW5jYXJ0LWFwaS5jb20vbGljZW5zZS5waHA/b3JkZXJ"
	
	condition:
		filesize < 300KB and not ( 
			any of ( $gfp* ) 
		)
		and $geval
}

rule webshell_php_double_eval_tiny
{
	meta:
		description = "PHP webshell which probably hides the input inside an eval()ed obfuscated string"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		hash = "aabfd179aaf716929c8b820eefa3c1f613f8dcac"
		date = "2021/01/11"
		score = 50

	strings:
		$payload = /(\beval[\t ]*\([^)]|\bassert[\t ]*\([^)])/ nocase wide ascii
		$fp1 = "clone" fullword wide ascii
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
	condition:
		filesize > 70 and filesize < 300 and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and #payload >= 2 and not any of ( $fp* )
}

rule webshell_php_obfuscated
{
	meta:
		description = "PHP webshell obfuscated"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/12"
		hash = "eec9ac58a1e763f5ea0f7fa249f1fe752047fa60"

	strings:

		//strings from private rule php_false_positive
		// try to use only strings which would be flagged by themselves as suspicous by other rules, e.g. eval 
        // a good choice is a string with good atom quality = ideally 4 unusual characters next to each other
		$gfp1  = "eval(\"return [$serialised_parameter" // elgg
		$gfp2  = "$this->assert(strpos($styles, $"
		$gfp3  = "$module = new $_GET['module']($_GET['scope']);"
		$gfp4  = "$plugin->$_POST['action']($_POST['id']);"
		$gfp5  = "$_POST[partition_by]($_POST["
		$gfp6  = "$object = new $_REQUEST['type']($_REQUEST['id']);"
		$gfp7  = "The above example code can be easily exploited by passing in a string such as" // ... ;)
		$gfp8  = "Smarty_Internal_Debug::start_render($_template);"
		$gfp9  = "?p4yl04d=UNION%20SELECT%20'<?%20system($_GET['command']);%20?>',2,3%20INTO%20OUTFILE%20'/var/www/w3bsh3ll.php"
		$gfp10 = "[][}{;|]\\|\\\\[+=]\\|<?=>?"
		$gfp11 = "(eval (getenv \"EPROLOG\")))"
		$gfp12 = "ZmlsZV9nZXRfY29udGVudHMoJ2h0dHA6Ly9saWNlbnNlLm9wZW5jYXJ0LWFwaS5jb20vbGljZW5zZS5waHA/b3JkZXJ"
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
		//strings from private rule capa_php_obfuscation_multi
		$o1 = "chr(" nocase wide ascii
		$o2 = "chr (" nocase wide ascii
		// not excactly a string function but also often used in obfuscation
		$o3 = "goto" fullword nocase wide ascii
		$o4 = "\\x9" wide ascii
		$o5 = "\\x3" wide ascii
		// just picking some random numbers because they should appear often enough in a long obfuscated blob and it's faster than a regex
		$o6 = "\\61" wide ascii
		$o7 = "\\44" wide ascii
		$o8 = "\\112" wide ascii
		$o9 = "\\120" wide ascii
		$fp1 = "$goto" wide ascii
	
		//strings from private rule capa_php_payload
		// \([^)] to avoid matching on e.g. eval() in comments
		$cpayload1 = /\beval[\t ]*\([^)]/ nocase wide ascii
		$cpayload2 = /\bexec[\t ]*\([^)]/ nocase wide ascii
		$cpayload3 = /\bshell_exec[\t ]*\([^)]/ nocase wide ascii
		$cpayload4 = /\bpassthru[\t ]*\([^)]/ nocase wide ascii
		$cpayload5 = /\bsystem[\t ]*\([^)]/ nocase wide ascii
		$cpayload6 = /\bpopen[\t ]*\([^)]/ nocase wide ascii
		$cpayload7 = /\bproc_open[\t ]*\([^)]/ nocase wide ascii
		$cpayload8 = /\bpcntl_exec[\t ]*\([^)]/ nocase wide ascii
		$cpayload9 = /\bassert[\t ]*\([^)0]/ nocase wide ascii
		$cpayload10 = /\bpreg_replace[\t ]*\(.{1,100}\/[ismxADSUXju]{0,11}(e|\\x65)/ nocase wide ascii
		$cpayload12 = /\bmb_ereg_replace[\t ]*\([^\)]{1,100}'e'/ nocase wide ascii
		$cpayload13 = /\bmb_eregi_replace[\t ]*\([^\)]{1,100}'e'/ nocase wide ascii
		$cpayload20 = /\bcreate_function[\t ]*\([^)]/ nocase wide ascii
		$cpayload21 = /\bReflectionFunction[\t ]*\([^)]/ nocase wide ascii

		$m_cpayload_preg_filter1 = /\bpreg_filter[\t ]*\([^\)]/ nocase wide ascii
		$m_cpayload_preg_filter2 = "'|.*|e'" nocase wide ascii
		// TODO backticks
	
	condition:
		not ( 
			any of ( $gfp* ) 
		)
		and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and ( 
			// allow different amounts of potential obfuscation functions depending on filesize
			not $fp1 and (
				(
						filesize < 20KB and 
						(
							( #o1+#o2 ) > 50 or
							#o3 > 10 or
							( #o4+#o5+#o6+#o7+#o8+#o9 ) > 20 
						) 
				) or (
						filesize < 200KB and 
						(
							( #o1+#o2 ) > 200 or
							#o3 > 30 or
							( #o4+#o5+#o6+#o7+#o8+#o9 ) > 30 
						) 

				)
			)

 
		)
		and ( 
			any of ( $cpayload* ) or
        all of ( $m_cpayload_preg_filter* ) 
		)
		
}

rule webshell_php_obfuscated_encoding
{
	meta:
		description = "PHP webshell obfuscated by encoding"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/04/18"

	strings:
        // one without plain e, one without plain v, to avoid hitting on plain "eval("
		$enc_eval1 = /(e|\\x65|\\101)(\\x76|\\118)(a|\\x61|\\97)(l|\\x6c|\\108)(\(|\\x28|\\40)/ wide ascii nocase
		$enc_eval2 = /(\\x65|\\101)(v|\\x76|\\118)(a|\\x61|\\97)(l|\\x6c|\\108)(\(|\\x28|\\40)/ wide ascii nocase
        // one without plain a, one without plain s, to avoid hitting on plain "assert("
		$enc_assert1 = /(a|\\97|\\x61)(\\115|\\x73)(s|\\115|\\x73)(e|\\101|\\x65)(r|\\114|\\x72)(t|\\116|\\x74)(\(|\\x28|\\40)/ wide ascii nocase
		$enc_assert2 = /(\\97|\\x61)(s|\\115|\\x73)(s|\\115|\\x73)(e|\\101|\\x65)(r|\\114|\\x72)(t|\\116|\\x74)(\(|\\x28|\\40)/ wide ascii nocase
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
	condition:
		filesize < 700KB and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and any of ( $enc* )
}

rule webshell_php_obfuscated_encoding_mixed_dec_and_hex
{
	meta:
		description = "PHP webshell obfuscated by encoding of mixed hex and dec"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/04/18"

	strings:
        // "e\x4a\x48\x5a\x70\x63\62\154\x30\131\171\101\x39\111\x43\x52\x66\x51\
		//$mix = /['"]\\x?[0-9a-f]{2,3}[\\\w]{2,20}\\\d{1,3}[\\\w]{2,20}\\x[0-9a-f]{2}\\/ wide ascii nocase
		$mix = /['"](\w|\\x?[0-9a-f]{2,3})[\\x0-9a-f]{2,20}\\\d{1,3}[\\x0-9a-f]{2,20}\\x[0-9a-f]{2}\\/ wide ascii nocase

	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
	condition:
		filesize < 700KB and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and any of ( $mix* )
}

rule webshell_php_obfuscated_tiny
{
	meta:
		description = "PHP webshell obfuscated"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/12"

	strings:
        // 'ev'.'al'
        $obf1 = /\w'\.'\w/ wide ascii
        $obf2 = /\w\"\.\"\w/ wide ascii
        $obf3 = "].$" wide ascii
	
		//strings from private rule php_false_positive
		// try to use only strings which would be flagged by themselves as suspicous by other rules, e.g. eval 
        // a good choice is a string with good atom quality = ideally 4 unusual characters next to each other
		$gfp1  = "eval(\"return [$serialised_parameter" // elgg
		$gfp2  = "$this->assert(strpos($styles, $"
		$gfp3  = "$module = new $_GET['module']($_GET['scope']);"
		$gfp4  = "$plugin->$_POST['action']($_POST['id']);"
		$gfp5  = "$_POST[partition_by]($_POST["
		$gfp6  = "$object = new $_REQUEST['type']($_REQUEST['id']);"
		$gfp7  = "The above example code can be easily exploited by passing in a string such as" // ... ;)
		$gfp8  = "Smarty_Internal_Debug::start_render($_template);"
		$gfp9  = "?p4yl04d=UNION%20SELECT%20'<?%20system($_GET['command']);%20?>',2,3%20INTO%20OUTFILE%20'/var/www/w3bsh3ll.php"
		$gfp10 = "[][}{;|]\\|\\\\[+=]\\|<?=>?"
		$gfp11 = "(eval (getenv \"EPROLOG\")))"
		$gfp12 = "ZmlsZV9nZXRfY29udGVudHMoJ2h0dHA6Ly9saWNlbnNlLm9wZW5jYXJ0LWFwaS5jb20vbGljZW5zZS5waHA/b3JkZXJ"
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
		//strings from private rule capa_php_payload
		// \([^)] to avoid matching on e.g. eval() in comments
		$cpayload1 = /\beval[\t ]*\([^)]/ nocase wide ascii
		$cpayload2 = /\bexec[\t ]*\([^)]/ nocase wide ascii
		$cpayload3 = /\bshell_exec[\t ]*\([^)]/ nocase wide ascii
		$cpayload4 = /\bpassthru[\t ]*\([^)]/ nocase wide ascii
		$cpayload5 = /\bsystem[\t ]*\([^)]/ nocase wide ascii
		$cpayload6 = /\bpopen[\t ]*\([^)]/ nocase wide ascii
		$cpayload7 = /\bproc_open[\t ]*\([^)]/ nocase wide ascii
		$cpayload8 = /\bpcntl_exec[\t ]*\([^)]/ nocase wide ascii
		$cpayload9 = /\bassert[\t ]*\([^)0]/ nocase wide ascii
		$cpayload10 = /\bpreg_replace[\t ]*\(.{1,100}\/[ismxADSUXju]{0,11}(e|\\x65)/ nocase wide ascii
		$cpayload12 = /\bmb_ereg_replace[\t ]*\([^\)]{1,100}'e'/ nocase wide ascii
		$cpayload13 = /\bmb_eregi_replace[\t ]*\([^\)]{1,100}'e'/ nocase wide ascii
		$cpayload20 = /\bcreate_function[\t ]*\([^)]/ nocase wide ascii
		$cpayload21 = /\bReflectionFunction[\t ]*\([^)]/ nocase wide ascii

		$m_cpayload_preg_filter1 = /\bpreg_filter[\t ]*\([^\)]/ nocase wide ascii
		$m_cpayload_preg_filter2 = "'|.*|e'" nocase wide ascii
		// TODO backticks
	
	condition:
		filesize < 500 and not ( 
			any of ( $gfp* ) 
		)
		and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and ( 
			any of ( $cpayload* ) or
        all of ( $m_cpayload_preg_filter* ) 
		)
		and 
		( ( #obf1 + #obf2 ) > 2 or #obf3 > 10 )
}

rule webshell_php_obfuscated_str_replace
{
	meta:
		description = "PHP webshell which eval()s obfuscated string"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/12"
		hash = "691305753e26884d0f930cda0fe5231c6437de94"
		hash = "7efd463aeb5bf0120dc5f963b62463211bd9e678"
		hash = "fb655ddb90892e522ae1aaaf6cd8bde27a7f49ef"
		hash = "d1863aeca1a479462648d975773f795bb33a7af2"
		hash = "4d31d94b88e2bbd255cf501e178944425d40ee97"
		hash = "e1a2af3477d62a58f9e6431f5a4a123fb897ea80"

	strings:
		$payload1 = "str_replace" fullword wide ascii
		$payload2 = "function" fullword wide ascii
		$goto = "goto" fullword wide ascii
		//$hex  = "\\x"
		$chr1  = "\\61" wide ascii
		$chr2  = "\\112" wide ascii
		$chr3  = "\\120" wide ascii
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
	condition:
		filesize < 300KB and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and any of ( $payload* ) and #goto > 1 and 
		( #chr1 > 10 or #chr2 > 10 or #chr3 > 10 )
}

rule webshell_php_obfuscated_fopo
{
	meta:
		description = "PHP webshell which eval()s obfuscated string"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		hash = "fbcff8ea5ce04fc91c05384e847f2c316e013207"
		hash = "6da57ad8be1c587bb5cc8a1413f07d10fb314b72"
		hash = "a698441f817a9a72908a0d93a34133469f33a7b34972af3e351bdccae0737d99"
		date = "2021/01/12"

	strings:
		$payload = /(\beval[\t ]*\([^)]|\bassert[\t ]*\([^)])/ nocase wide ascii
		// ;@eval(
		$one1 = "7QGV2YWwo" wide ascii
		$one2 = "tAZXZhbC" wide ascii
		$one3 = "O0BldmFsK" wide ascii
		$one4 = "sAQABlAHYAYQBsACgA" wide ascii
		$one5 = "7AEAAZQB2AGEAbAAoA" wide ascii
		$one6 = "OwBAAGUAdgBhAGwAKA" wide ascii
		// ;@assert(
		$two1 = "7QGFzc2VydC" wide ascii
		$two2 = "tAYXNzZXJ0K" wide ascii
		$two3 = "O0Bhc3NlcnQo" wide ascii
		$two4 = "sAQABhAHMAcwBlAHIAdAAoA" wide ascii
		$two5 = "7AEAAYQBzAHMAZQByAHQAKA" wide ascii
		$two6 = "OwBAAGEAcwBzAGUAcgB0ACgA" wide ascii
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
	condition:
		filesize < 3000KB and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and $payload and 
		( any of ( $one* ) or any of ( $two* ) )
}

rule webshell_php_gzinflated
{
	meta:
		description = "PHP webshell which directly eval()s obfuscated string"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/12"
		hash = "49e5bc75a1ec36beeff4fbaeb16b322b08cf192d"

	strings:
		$payload2 = /eval\s?\(\s?("\?>".)?gzinflate\s?\(\s?base64_decode\s?\(/ wide ascii nocase
		$payload4 = /eval\s?\(\s?("\?>".)?gzuncompress\s?\(\s?(base64_decode|gzuncompress)/ wide ascii nocase
		$payload6 = /eval\s?\(\s?("\?>".)?gzdecode\s?\(\s?base64_decode\s?\(/ wide ascii nocase
		$payload7 = /eval\s?\(\s?base64_decode\s?\(/ wide ascii nocase
		$payload8 = /eval\s?\(\s?pack\s?\(/ wide ascii nocase

        // api.telegram
        $fp1 = "YXBpLnRlbGVncmFtLm9" 
	
		//strings from private rule php_false_positive
		// try to use only strings which would be flagged by themselves as suspicous by other rules, e.g. eval 
        // a good choice is a string with good atom quality = ideally 4 unusual characters next to each other
		$gfp1  = "eval(\"return [$serialised_parameter" // elgg
		$gfp2  = "$this->assert(strpos($styles, $"
		$gfp3  = "$module = new $_GET['module']($_GET['scope']);"
		$gfp4  = "$plugin->$_POST['action']($_POST['id']);"
		$gfp5  = "$_POST[partition_by]($_POST["
		$gfp6  = "$object = new $_REQUEST['type']($_REQUEST['id']);"
		$gfp7  = "The above example code can be easily exploited by passing in a string such as" // ... ;)
		$gfp8  = "Smarty_Internal_Debug::start_render($_template);"
		$gfp9  = "?p4yl04d=UNION%20SELECT%20'<?%20system($_GET['command']);%20?>',2,3%20INTO%20OUTFILE%20'/var/www/w3bsh3ll.php"
		$gfp10 = "[][}{;|]\\|\\\\[+=]\\|<?=>?"
		$gfp11 = "(eval (getenv \"EPROLOG\")))"
		$gfp12 = "ZmlsZV9nZXRfY29udGVudHMoJ2h0dHA6Ly9saWNlbnNlLm9wZW5jYXJ0LWFwaS5jb20vbGljZW5zZS5waHA/b3JkZXJ"
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
	condition:
		filesize < 700KB and not ( 
			any of ( $gfp* ) 
		)
		and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and 1 of ( $payload* ) and not any of ( $fp* )
}

rule webshell_php_obfuscated_3
{
	meta:
		description = "PHP webshell which eval()s obfuscated string"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/04/17"

	strings:
        $obf1 = "chr(" wide ascii
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
		//strings from private rule capa_php_callback
		$callback1 = /\bob_start[\t ]*\([^)]/ nocase wide ascii
		$callback2 = /\barray_diff_uassoc[\t ]*\([^)]/ nocase wide ascii
		$callback3 = /\barray_diff_ukey[\t ]*\([^)]/ nocase wide ascii
		$callback4 = /\barray_filter[\t ]*\([^)]/ nocase wide ascii
		$callback5 = /\barray_intersect_uassoc[\t ]*\([^)]/ nocase wide ascii
		$callback6 = /\barray_intersect_ukey[\t ]*\([^)]/ nocase wide ascii
		$callback7 = /\barray_map[\t ]*\([^)]/ nocase wide ascii
		$callback8 = /\barray_reduce[\t ]*\([^)]/ nocase wide ascii
		$callback9 = /\barray_udiff_assoc[\t ]*\([^)]/ nocase wide ascii
		$callback10 = /\barray_udiff_uassoc[\t ]*\([^)]/ nocase wide ascii
		$callback11 = /\barray_udiff[\t ]*\([^)]/ nocase wide ascii
		$callback12 = /\barray_uintersect_assoc[\t ]*\([^)]/ nocase wide ascii
		$callback13 = /\barray_uintersect_uassoc[\t ]*\([^)]/ nocase wide ascii
		$callback14 = /\barray_uintersect[\t ]*\([^)]/ nocase wide ascii
		$callback15 = /\barray_walk_recursive[\t ]*\([^)]/ nocase wide ascii
		$callback16 = /\barray_walk[\t ]*\([^)]/ nocase wide ascii
		$callback17 = /\bassert_options[\t ]*\([^)]/ nocase wide ascii
		$callback18 = /\buasort[\t ]*\([^)]/ nocase wide ascii
		$callback19 = /\buksort[\t ]*\([^)]/ nocase wide ascii
		$callback20 = /\busort[\t ]*\([^)]/ nocase wide ascii
		$callback21 = /\bpreg_replace_callback[\t ]*\([^)]/ nocase wide ascii
		$callback22 = /\bspl_autoload_register[\t ]*\([^)]/ nocase wide ascii
		$callback23 = /\biterator_apply[\t ]*\([^)]/ nocase wide ascii
		$callback24 = /\bcall_user_func[\t ]*\([^)]/ nocase wide ascii
		$callback25 = /\bcall_user_func_array[\t ]*\([^)]/ nocase wide ascii
		$callback26 = /\bregister_shutdown_function[\t ]*\([^)]/ nocase wide ascii
		$callback27 = /\bregister_tick_function[\t ]*\([^)]/ nocase wide ascii
		$callback28 = /\bset_error_handler[\t ]*\([^)]/ nocase wide ascii
		$callback29 = /\bset_exception_handler[\t ]*\([^)]/ nocase wide ascii
		$callback30 = /\bsession_set_save_handler[\t ]*\([^)]/ nocase wide ascii
		$callback31 = /\bsqlite_create_aggregate[\t ]*\([^)]/ nocase wide ascii
		$callback32 = /\bsqlite_create_function[\t ]*\([^)]/ nocase wide ascii
		$callback33 = /\bmb_ereg_replace_callback[\t ]*\([^)]/ nocase wide ascii

		$m_callback1 = /\bfilter_var[\t ]*\([^)]/ nocase wide ascii
		$m_callback2 = "FILTER_CALLBACK" fullword wide ascii

		$cfp1 = /ob_start\(['\"]ob_gzhandler/ nocase wide ascii
        $cfp2 = "IWPML_Backend_Action_Loader" ascii wide
		$cfp3 = "<?phpclass WPML" ascii
	
		//strings from private rule capa_php_payload
		// \([^)] to avoid matching on e.g. eval() in comments
		$cpayload1 = /\beval[\t ]*\([^)]/ nocase wide ascii
		$cpayload2 = /\bexec[\t ]*\([^)]/ nocase wide ascii
		$cpayload3 = /\bshell_exec[\t ]*\([^)]/ nocase wide ascii
		$cpayload4 = /\bpassthru[\t ]*\([^)]/ nocase wide ascii
		$cpayload5 = /\bsystem[\t ]*\([^)]/ nocase wide ascii
		$cpayload6 = /\bpopen[\t ]*\([^)]/ nocase wide ascii
		$cpayload7 = /\bproc_open[\t ]*\([^)]/ nocase wide ascii
		$cpayload8 = /\bpcntl_exec[\t ]*\([^)]/ nocase wide ascii
		$cpayload9 = /\bassert[\t ]*\([^)0]/ nocase wide ascii
		$cpayload10 = /\bpreg_replace[\t ]*\(.{1,100}\/[ismxADSUXju]{0,11}(e|\\x65)/ nocase wide ascii
		$cpayload12 = /\bmb_ereg_replace[\t ]*\([^\)]{1,100}'e'/ nocase wide ascii
		$cpayload13 = /\bmb_eregi_replace[\t ]*\([^\)]{1,100}'e'/ nocase wide ascii
		$cpayload20 = /\bcreate_function[\t ]*\([^)]/ nocase wide ascii
		$cpayload21 = /\bReflectionFunction[\t ]*\([^)]/ nocase wide ascii

		$m_cpayload_preg_filter1 = /\bpreg_filter[\t ]*\([^\)]/ nocase wide ascii
		$m_cpayload_preg_filter2 = "'|.*|e'" nocase wide ascii
		// TODO backticks
	
		//strings from private rule capa_php_obfuscation_single
		$cobfs1 = "gzinflate" fullword nocase wide ascii
		$cobfs2 = "gzuncompress" fullword nocase wide ascii
		$cobfs3 = "gzdecode" fullword nocase wide ascii
		$cobfs4 = "base64_decode" fullword nocase wide ascii
		$cobfs5 = "pack" fullword nocase wide ascii
		$cobfs6 = "undecode" fullword nocase wide ascii
	
		//strings from private rule capa_gen_sus

        // these strings are just a bit suspicious, so several of them are needed, depending on filesize
        $gen_bit_sus1  = /:\s{0,20}eval}/ nocase wide ascii
        $gen_bit_sus2  = /\.replace\(\/\w\/g/ nocase wide ascii
        $gen_bit_sus6  = "self.delete"
        $gen_bit_sus9  = "\"cmd /c" nocase
        $gen_bit_sus10 = "\"cmd\"" nocase
        $gen_bit_sus11 = "\"cmd.exe" nocase
        $gen_bit_sus12 = "%comspec%" wide ascii
        $gen_bit_sus13 = "%COMSPEC%" wide ascii
        //TODO:$gen_bit_sus12 = ".UserName" nocase
        $gen_bit_sus18 = "Hklm.GetValueNames();" nocase
        // bonus string for proxylogon exploiting webshells
        $gen_bit_sus19 = "http://schemas.microsoft.com/exchange/" wide ascii
        $gen_bit_sus21 = "\"upload\"" wide ascii
        $gen_bit_sus22 = "\"Upload\"" wide ascii
        $gen_bit_sus23 = "UPLOAD" fullword wide ascii
        $gen_bit_sus24 = "fileupload" wide ascii
        $gen_bit_sus25 = "file_upload" wide ascii
        // own base64 func
        $gen_bit_sus29 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" fullword wide ascii
        $gen_bit_sus30 = "serv-u" wide ascii
        $gen_bit_sus31 = "Serv-u" wide ascii
        $gen_bit_sus32 = "Army" fullword wide ascii
        // single letter paramweter
        $gen_bit_sus33 = /\$_(GET|POST|REQUEST)\["\w"\]/ fullword wide ascii
        $gen_bit_sus34 = "Content-Transfer-Encoding: Binary" wide ascii
        $gen_bit_sus35 = "crack" fullword wide ascii

        $gen_bit_sus44 = "<pre>" wide ascii
        $gen_bit_sus45 = "<PRE>" wide ascii
        $gen_bit_sus46 = "shell_" wide ascii
        $gen_bit_sus47 = "Shell" fullword wide ascii
        $gen_bit_sus50 = "bypass" wide ascii
        $gen_bit_sus51 = "suhosin" wide ascii
        $gen_bit_sus52 = " ^ $" wide ascii
        $gen_bit_sus53 = ".ssh/authorized_keys" wide ascii
        $gen_bit_sus55 = /\w'\.'\w/ wide ascii
        $gen_bit_sus56 = /\w\"\.\"\w/ wide ascii
        $gen_bit_sus57 = "dumper" wide ascii
        $gen_bit_sus59 = "'cmd'" wide ascii
        $gen_bit_sus60 = "\"execute\"" wide ascii
        $gen_bit_sus61 = "/bin/sh" wide ascii
        $gen_bit_sus62 = "Cyber" wide ascii
        $gen_bit_sus63 = "portscan" fullword wide ascii
        //$gen_bit_sus64 = "\"command\"" fullword wide ascii
        //$gen_bit_sus65 = "'command'" fullword wide ascii
        $gen_bit_sus66 = "whoami" fullword wide ascii
        $gen_bit_sus67 = "$password='" fullword wide ascii
        $gen_bit_sus68 = "$password=\"" fullword wide ascii
        $gen_bit_sus69 = "$cmd" fullword wide ascii
        $gen_bit_sus70 = "\"?>\"." fullword wide ascii
        $gen_bit_sus71 = "Hacking" fullword wide ascii
        $gen_bit_sus72 = "hacking" fullword wide ascii
        $gen_bit_sus73 = ".htpasswd" wide ascii
        $gen_bit_sus74 = /\btouch\(\$[^,]{1,30},/ wide ascii

        // very suspicious strings, one is enough
        $gen_much_sus7  = "Web Shell" nocase
        $gen_much_sus8  = "WebShell" nocase
        $gen_much_sus3  = "hidded shell" 
        $gen_much_sus4  = "WScript.Shell.1" nocase
        $gen_much_sus5  = "AspExec" 
        $gen_much_sus14 = "\\pcAnywhere\\" nocase
        $gen_much_sus15 = "antivirus" nocase
        $gen_much_sus16 = "McAfee" nocase
        $gen_much_sus17 = "nishang" 
        $gen_much_sus18 = "\"unsafe" fullword wide ascii
        $gen_much_sus19 = "'unsafe" fullword wide ascii
        $gen_much_sus24 = "exploit" fullword wide ascii
        $gen_much_sus25 = "Exploit" fullword wide ascii
        $gen_much_sus26 = "TVqQAAMAAA" wide ascii
        $gen_much_sus30 = "Hacker" wide ascii
        $gen_much_sus31 = "HACKED" fullword wide ascii
        $gen_much_sus32 = "hacked" fullword wide ascii
        $gen_much_sus33 = "hacker" wide ascii
        $gen_much_sus34 = "grayhat" nocase wide ascii
        $gen_much_sus35 = "Microsoft FrontPage" wide ascii
        $gen_much_sus36 = "Rootkit" wide ascii
        $gen_much_sus37 = "rootkit" wide ascii
        $gen_much_sus38 = "/*-/*-*/" wide ascii
        $gen_much_sus39 = "u\"+\"n\"+\"s" wide ascii
        $gen_much_sus40 = "\"e\"+\"v" wide ascii
        $gen_much_sus41 = "a\"+\"l\"" wide ascii
        $gen_much_sus42 = "\"+\"(\"+\"" wide ascii
        $gen_much_sus43 = "q\"+\"u\"" wide ascii
        $gen_much_sus44 = "\"u\"+\"e" wide ascii
        $gen_much_sus45 = "/*//*/" wide ascii
        $gen_much_sus46 = "(\"/*/\"" wide ascii
        $gen_much_sus47 = "eval(eval(" wide ascii
        // self remove
        $gen_much_sus48 = "unlink(__FILE__)" wide ascii
        $gen_much_sus49 = "Shell.Users" wide ascii
        $gen_much_sus50 = "PasswordType=Regular" wide ascii
        $gen_much_sus51 = "-Expire=0" wide ascii
        $gen_much_sus60 = "_=$$_" wide ascii
        $gen_much_sus61 = "_=$$_" wide ascii
        $gen_much_sus62 = "++;$" wide ascii
        $gen_much_sus63 = "++; $" wide ascii
        $gen_much_sus64 = "_.=$_" wide ascii
        $gen_much_sus70 = "-perm -04000" wide ascii
        $gen_much_sus71 = "-perm -02000" wide ascii
        $gen_much_sus72 = "grep -li password" wide ascii
        $gen_much_sus73 = "-name config.inc.php" wide ascii
        // touch without parameters sets the time to now, not malicious and gives fp
        $gen_much_sus75 = "password crack" wide ascii
        $gen_much_sus76 = "mysqlDll.dll" wide ascii
        $gen_much_sus77 = "net user" wide ascii
        $gen_much_sus78 = "suhosin.executor.disable_" wide ascii
        $gen_much_sus79 = "disabled_suhosin" wide ascii
        $gen_much_sus80 = "fopen(\".htaccess\",\"w" wide ascii
        $gen_much_sus81 = /strrev\(['"]/ wide ascii
        $gen_much_sus82 = "PHPShell" fullword wide ascii
        $gen_much_sus821= "PHP Shell" fullword wide ascii
        $gen_much_sus83 = "phpshell" fullword wide ascii
        $gen_much_sus84 = "PHPshell" fullword wide ascii
        $gen_much_sus87 = "deface" wide ascii
        $gen_much_sus88 = "Deface" wide ascii
        $gen_much_sus89 = "backdoor" wide ascii
        $gen_much_sus90 = "r00t" fullword wide ascii
        $gen_much_sus91 = "xp_cmdshell" fullword wide ascii

        $gif = { 47 49 46 38 }

	
	condition:
		( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and 
		( ( 
			not any of ( $cfp* ) and
        (
            any of ( $callback* )  or
            all of ( $m_callback* )
        ) 
		)
		or ( 
			any of ( $cpayload* ) or
        all of ( $m_cpayload_preg_filter* ) 
		)
		) and ( 
			any of ( $cobfs* ) 
		)
		and 
		( filesize < 1KB or 
		( filesize < 3KB and 
		( ( 
        $gif at 0 or
        (
            filesize < 4KB and 
            (
                1 of ( $gen_much_sus* ) or
                2 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 20KB and 
            (
                2 of ( $gen_much_sus* ) or
                3 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 50KB and 
            (
                2 of ( $gen_much_sus* ) or
                4 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 100KB and 
            (
                2 of ( $gen_much_sus* ) or
                6 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 150KB and 
            (
                3 of ( $gen_much_sus* ) or
                7 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 500KB and 
            (
                4 of ( $gen_much_sus* ) or
                8 of ( $gen_bit_sus* )
            )
        ) 
		)
		or #obf1 > 10 ) ) )
}

rule webshell_php_includer_eval
{
	meta:
		description = "PHP webshell which eval()s another included file"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		hash = "3a07e9188028efa32872ba5b6e5363920a6b2489"
		date = "2021/01/13"

	strings:
		$payload1 = "eval" fullword wide ascii
		$payload2 = "assert" fullword wide ascii
		$include1 = "$_FILE" wide ascii
		$include2 = "include" wide ascii
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
	condition:
		filesize < 200 and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and 1 of ( $payload* ) and 1 of ( $include* )
}

rule webshell_php_includer_tiny
{
	meta:
		description = "Suspicious: Might be PHP webshell includer, check the included file"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/04/17"

	strings:
		$php_include1 = /include\(\$_(GET|POST|REQUEST)\[/ nocase wide ascii
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
	condition:
		filesize < 100 and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and any of ( $php_include* )
}

rule webshell_php_dynamic
{
	meta:
		description = "PHP webshell using function name from variable, e.g. $a='ev'.'al'; $a($code)"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		hash = "65dca1e652d09514e9c9b2e0004629d03ab3c3ef"
		hash = "b8ab38dc75cec26ce3d3a91cb2951d7cdd004838"
		hash = "c4765e81550b476976604d01c20e3dbd415366df"
		date = "2021/01/13"
		score = 60

	strings:
		$pd_fp1 = "whoops_add_stack_frame" wide ascii
		$pd_fp2 = "new $ec($code, $mode, $options, $userinfo);" wide ascii
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
		//strings from private rule capa_php_dynamic
        // php variable regex from https://www.php.net/manual/en/language.variables.basics.php
		$dynamic1 = /\$[a-zA-Z_\x80-\xff][a-zA-Z0-9_\x80-\xff\[\]'"]{0,20}\(\$/ wide ascii
		$dynamic2 = /\$[a-zA-Z_\x80-\xff][a-zA-Z0-9_\x80-\xff\[\]'"]{0,20}\("/ wide ascii
		$dynamic3 = /\$[a-zA-Z_\x80-\xff][a-zA-Z0-9_\x80-\xff\[\]'"]{0,20}\('/ wide ascii
		$dynamic4 = /\$[a-zA-Z_\x80-\xff][a-zA-Z0-9_\x80-\xff\[\]'"]{0,20}\(str/ wide ascii
		$dynamic5 = /\$[a-zA-Z_\x80-\xff][a-zA-Z0-9_\x80-\xff\[\]'"]{0,20}\(\)/ wide ascii
		$dynamic6 = /\$[a-zA-Z_\x80-\xff][a-zA-Z0-9_\x80-\xff\[\]'"]{0,20}\(@/ wide ascii
		$dynamic7 = /\$[a-zA-Z_\x80-\xff][a-zA-Z0-9_\x80-\xff\[\]'"]{0,20}\(base64_decode/ wide ascii
	
	condition:
		filesize > 20 and filesize < 200 and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and ( 
			any of ( $dynamic* ) 
		)
		and not any of ( $pd_fp* )
}

rule webshell_php_dynamic_big
{
	meta:
		description = "PHP webshell using $a($code) for kind of eval with encoded blob to decode, e.g. b374k"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/02/07"
		score = 50

	strings:

		//strings from private rule capa_bin_files
        $dex   = { 64 65 ( 78 | 79 ) 0a 30 }
        $pack  = { 50 41 43 4b 00 00 00 02 00 }
	
		//strings from private rule capa_php_new_long
		// no <?=
		$new_php2 = "<?php" nocase wide ascii
		$new_php3 = "<script language=\"php" nocase wide ascii
        $php_short = "<?"
	
		//strings from private rule capa_php_dynamic
        // php variable regex from https://www.php.net/manual/en/language.variables.basics.php
		$dynamic1 = /\$[a-zA-Z_\x80-\xff][a-zA-Z0-9_\x80-\xff\[\]'"]{0,20}\(\$/ wide ascii
		$dynamic2 = /\$[a-zA-Z_\x80-\xff][a-zA-Z0-9_\x80-\xff\[\]'"]{0,20}\("/ wide ascii
		$dynamic3 = /\$[a-zA-Z_\x80-\xff][a-zA-Z0-9_\x80-\xff\[\]'"]{0,20}\('/ wide ascii
		$dynamic4 = /\$[a-zA-Z_\x80-\xff][a-zA-Z0-9_\x80-\xff\[\]'"]{0,20}\(str/ wide ascii
		$dynamic5 = /\$[a-zA-Z_\x80-\xff][a-zA-Z0-9_\x80-\xff\[\]'"]{0,20}\(\)/ wide ascii
		$dynamic6 = /\$[a-zA-Z_\x80-\xff][a-zA-Z0-9_\x80-\xff\[\]'"]{0,20}\(@/ wide ascii
		$dynamic7 = /\$[a-zA-Z_\x80-\xff][a-zA-Z0-9_\x80-\xff\[\]'"]{0,20}\(base64_decode/ wide ascii
	
		//strings from private rule capa_gen_sus

        // these strings are just a bit suspicious, so several of them are needed, depending on filesize
        $gen_bit_sus1  = /:\s{0,20}eval}/ nocase wide ascii
        $gen_bit_sus2  = /\.replace\(\/\w\/g/ nocase wide ascii
        $gen_bit_sus6  = "self.delete"
        $gen_bit_sus9  = "\"cmd /c" nocase
        $gen_bit_sus10 = "\"cmd\"" nocase
        $gen_bit_sus11 = "\"cmd.exe" nocase
        $gen_bit_sus12 = "%comspec%" wide ascii
        $gen_bit_sus13 = "%COMSPEC%" wide ascii
        //TODO:$gen_bit_sus12 = ".UserName" nocase
        $gen_bit_sus18 = "Hklm.GetValueNames();" nocase
        // bonus string for proxylogon exploiting webshells
        $gen_bit_sus19 = "http://schemas.microsoft.com/exchange/" wide ascii
        $gen_bit_sus21 = "\"upload\"" wide ascii
        $gen_bit_sus22 = "\"Upload\"" wide ascii
        $gen_bit_sus23 = "UPLOAD" fullword wide ascii
        $gen_bit_sus24 = "fileupload" wide ascii
        $gen_bit_sus25 = "file_upload" wide ascii
        // own base64 func
        $gen_bit_sus29 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" fullword wide ascii
        $gen_bit_sus30 = "serv-u" wide ascii
        $gen_bit_sus31 = "Serv-u" wide ascii
        $gen_bit_sus32 = "Army" fullword wide ascii
        // single letter paramweter
        $gen_bit_sus33 = /\$_(GET|POST|REQUEST)\["\w"\]/ fullword wide ascii
        $gen_bit_sus34 = "Content-Transfer-Encoding: Binary" wide ascii
        $gen_bit_sus35 = "crack" fullword wide ascii

        $gen_bit_sus44 = "<pre>" wide ascii
        $gen_bit_sus45 = "<PRE>" wide ascii
        $gen_bit_sus46 = "shell_" wide ascii
        $gen_bit_sus47 = "Shell" fullword wide ascii
        $gen_bit_sus50 = "bypass" wide ascii
        $gen_bit_sus51 = "suhosin" wide ascii
        $gen_bit_sus52 = " ^ $" wide ascii
        $gen_bit_sus53 = ".ssh/authorized_keys" wide ascii
        $gen_bit_sus55 = /\w'\.'\w/ wide ascii
        $gen_bit_sus56 = /\w\"\.\"\w/ wide ascii
        $gen_bit_sus57 = "dumper" wide ascii
        $gen_bit_sus59 = "'cmd'" wide ascii
        $gen_bit_sus60 = "\"execute\"" wide ascii
        $gen_bit_sus61 = "/bin/sh" wide ascii
        $gen_bit_sus62 = "Cyber" wide ascii
        $gen_bit_sus63 = "portscan" fullword wide ascii
        //$gen_bit_sus64 = "\"command\"" fullword wide ascii
        //$gen_bit_sus65 = "'command'" fullword wide ascii
        $gen_bit_sus66 = "whoami" fullword wide ascii
        $gen_bit_sus67 = "$password='" fullword wide ascii
        $gen_bit_sus68 = "$password=\"" fullword wide ascii
        $gen_bit_sus69 = "$cmd" fullword wide ascii
        $gen_bit_sus70 = "\"?>\"." fullword wide ascii
        $gen_bit_sus71 = "Hacking" fullword wide ascii
        $gen_bit_sus72 = "hacking" fullword wide ascii
        $gen_bit_sus73 = ".htpasswd" wide ascii
        $gen_bit_sus74 = /\btouch\(\$[^,]{1,30},/ wide ascii

        // very suspicious strings, one is enough
        $gen_much_sus7  = "Web Shell" nocase
        $gen_much_sus8  = "WebShell" nocase
        $gen_much_sus3  = "hidded shell" 
        $gen_much_sus4  = "WScript.Shell.1" nocase
        $gen_much_sus5  = "AspExec" 
        $gen_much_sus14 = "\\pcAnywhere\\" nocase
        $gen_much_sus15 = "antivirus" nocase
        $gen_much_sus16 = "McAfee" nocase
        $gen_much_sus17 = "nishang" 
        $gen_much_sus18 = "\"unsafe" fullword wide ascii
        $gen_much_sus19 = "'unsafe" fullword wide ascii
        $gen_much_sus24 = "exploit" fullword wide ascii
        $gen_much_sus25 = "Exploit" fullword wide ascii
        $gen_much_sus26 = "TVqQAAMAAA" wide ascii
        $gen_much_sus30 = "Hacker" wide ascii
        $gen_much_sus31 = "HACKED" fullword wide ascii
        $gen_much_sus32 = "hacked" fullword wide ascii
        $gen_much_sus33 = "hacker" wide ascii
        $gen_much_sus34 = "grayhat" nocase wide ascii
        $gen_much_sus35 = "Microsoft FrontPage" wide ascii
        $gen_much_sus36 = "Rootkit" wide ascii
        $gen_much_sus37 = "rootkit" wide ascii
        $gen_much_sus38 = "/*-/*-*/" wide ascii
        $gen_much_sus39 = "u\"+\"n\"+\"s" wide ascii
        $gen_much_sus40 = "\"e\"+\"v" wide ascii
        $gen_much_sus41 = "a\"+\"l\"" wide ascii
        $gen_much_sus42 = "\"+\"(\"+\"" wide ascii
        $gen_much_sus43 = "q\"+\"u\"" wide ascii
        $gen_much_sus44 = "\"u\"+\"e" wide ascii
        $gen_much_sus45 = "/*//*/" wide ascii
        $gen_much_sus46 = "(\"/*/\"" wide ascii
        $gen_much_sus47 = "eval(eval(" wide ascii
        // self remove
        $gen_much_sus48 = "unlink(__FILE__)" wide ascii
        $gen_much_sus49 = "Shell.Users" wide ascii
        $gen_much_sus50 = "PasswordType=Regular" wide ascii
        $gen_much_sus51 = "-Expire=0" wide ascii
        $gen_much_sus60 = "_=$$_" wide ascii
        $gen_much_sus61 = "_=$$_" wide ascii
        $gen_much_sus62 = "++;$" wide ascii
        $gen_much_sus63 = "++; $" wide ascii
        $gen_much_sus64 = "_.=$_" wide ascii
        $gen_much_sus70 = "-perm -04000" wide ascii
        $gen_much_sus71 = "-perm -02000" wide ascii
        $gen_much_sus72 = "grep -li password" wide ascii
        $gen_much_sus73 = "-name config.inc.php" wide ascii
        // touch without parameters sets the time to now, not malicious and gives fp
        $gen_much_sus75 = "password crack" wide ascii
        $gen_much_sus76 = "mysqlDll.dll" wide ascii
        $gen_much_sus77 = "net user" wide ascii
        $gen_much_sus78 = "suhosin.executor.disable_" wide ascii
        $gen_much_sus79 = "disabled_suhosin" wide ascii
        $gen_much_sus80 = "fopen(\".htaccess\",\"w" wide ascii
        $gen_much_sus81 = /strrev\(['"]/ wide ascii
        $gen_much_sus82 = "PHPShell" fullword wide ascii
        $gen_much_sus821= "PHP Shell" fullword wide ascii
        $gen_much_sus83 = "phpshell" fullword wide ascii
        $gen_much_sus84 = "PHPshell" fullword wide ascii
        $gen_much_sus87 = "deface" wide ascii
        $gen_much_sus88 = "Deface" wide ascii
        $gen_much_sus89 = "backdoor" wide ascii
        $gen_much_sus90 = "r00t" fullword wide ascii
        $gen_much_sus91 = "xp_cmdshell" fullword wide ascii

        $gif = { 47 49 46 38 }

	
	condition:
		filesize < 500KB and not ( 
        uint16(0) == 0x5a4d or 
        $dex at 0 or 
        $pack at 0 or 
        // fp on jar with zero compression
        uint16(0) == 0x4b50 
		)
		and ( 
			any of ( $new_php* ) or
        $php_short at 0 
		)
		and ( 
			any of ( $dynamic* ) 
		)
		and 
		( ( 
			// file shouldn't be too small to have big enough data for math.entropy
			filesize > 2KB and 
        (
            // base64 : 
            // ignore first and last 500bytes because they usually contain code for decoding and executing
            math.entropy(500, filesize-500) >= 5.7 and
            // encoded text has a higher mean than text or code because it's missing the spaces and special chars with the low numbers
            math.mean(500, filesize-500) > 80 and
            // deviation of base64 is ~20 according to CyberChef_v9.21.0.html#recipe=Generate_Lorem_Ipsum(3,'Paragraphs')To_Base64('A-Za-z0-9%2B/%3D')To_Charcode('Space',10)Standard_Deviation('Space')
            // lets take a bit more because it might not be pure base64 also include some xor, shift, replacement, ...
            // 89 is the mean of the base64 chars
            math.deviation(500, filesize-500, 89.0) < 23
        ) or (
            // gzinflated binary sometimes used in php webshells
            // ignore first and last 500bytes because they usually contain code for decoding and executing
            math.entropy(500, filesize-500) >= 7.7 and
            // encoded text has a higher mean than text or code because it's missing the spaces and special chars with the low numbers
            math.mean(500, filesize-500) > 120 and
            math.mean(500, filesize-500) < 136 and
            // deviation of base64 is ~20 according to CyberChef_v9.21.0.html#recipe=Generate_Lorem_Ipsum(3,'Paragraphs')To_Base64('A-Za-z0-9%2B/%3D')To_Charcode('Space',10)Standard_Deviation('Space')
            // lets take a bit more because it might not be pure base64 also include some xor, shift, replacement, ...
            // 89 is the mean of the base64 chars
            math.deviation(500, filesize-500, 89.0) > 65
        ) 
		)
		or ( 
        $gif at 0 or
        (
            filesize < 4KB and 
            (
                1 of ( $gen_much_sus* ) or
                2 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 20KB and 
            (
                2 of ( $gen_much_sus* ) or
                3 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 50KB and 
            (
                2 of ( $gen_much_sus* ) or
                4 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 100KB and 
            (
                2 of ( $gen_much_sus* ) or
                6 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 150KB and 
            (
                3 of ( $gen_much_sus* ) or
                7 of ( $gen_bit_sus* )
            )
        ) or (
            filesize < 500KB and 
            (
                4 of ( $gen_much_sus* ) or
                8 of ( $gen_bit_sus* )
            )
        ) 
		)
		)
}

rule webshell_php_encoded_big
{
	meta:
		description = "PHP webshell using some kind of eval with encoded blob to decode"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/02/07"
		score = 50
		hash = "1d4b374d284c12db881ba42ee63ebce2759e0b14"

	strings:

		//strings from private rule capa_php_new
		$new_php1 = /<\?=[\w\s@$]/ wide ascii
		$new_php2 = "<?php" nocase wide ascii
		$new_php3 = "<script language=\"php" nocase wide ascii
        $php_short = "<?"
	
		//strings from private rule capa_php_payload
		// \([^)] to avoid matching on e.g. eval() in comments
		$cpayload1 = /\beval[\t ]*\([^)]/ nocase wide ascii
		$cpayload2 = /\bexec[\t ]*\([^)]/ nocase wide ascii
		$cpayload3 = /\bshell_exec[\t ]*\([^)]/ nocase wide ascii
		$cpayload4 = /\bpassthru[\t ]*\([^)]/ nocase wide ascii
		$cpayload5 = /\bsystem[\t ]*\([^)]/ nocase wide ascii
		$cpayload6 = /\bpopen[\t ]*\([^)]/ nocase wide ascii
		$cpayload7 = /\bproc_open[\t ]*\([^)]/ nocase wide ascii
		$cpayload8 = /\bpcntl_exec[\t ]*\([^)]/ nocase wide ascii
		$cpayload9 = /\bassert[\t ]*\([^)0]/ nocase wide ascii
		$cpayload10 = /\bpreg_replace[\t ]*\(.{1,100}\/[ismxADSUXju]{0,11}(e|\\x65)/ nocase wide ascii
		$cpayload12 = /\bmb_ereg_replace[\t ]*\([^\)]{1,100}'e'/ nocase wide ascii
		$cpayload13 = /\bmb_eregi_replace[\t ]*\([^\)]{1,100}'e'/ nocase wide ascii
		$cpayload20 = /\bcreate_function[\t ]*\([^)]/ nocase wide ascii
		$cpayload21 = /\bReflectionFunction[\t ]*\([^)]/ nocase wide ascii

		$m_cpayload_preg_filter1 = /\bpreg_filter[\t ]*\([^\)]/ nocase wide ascii
		$m_cpayload_preg_filter2 = "'|.*|e'" nocase wide ascii
		// TODO backticks
	
	condition:
		filesize < 1000KB and ( 
			any of ( $new_php* ) or
        $php_short at 0 
		)
		and ( 
			any of ( $cpayload* ) or
        all of ( $m_cpayload_preg_filter* ) 
		)
		and ( 
			// file shouldn't be too small to have big enough data for math.entropy
			filesize > 2KB and 
        (
            // base64 : 
            // ignore first and last 500bytes because they usually contain code for decoding and executing
            math.entropy(500, filesize-500) >= 5.7 and
            // encoded text has a higher mean than text or code because it's missing the spaces and special chars with the low numbers
            math.mean(500, filesize-500) > 80 and
            // deviation of base64 is ~20 according to CyberChef_v9.21.0.html#recipe=Generate_Lorem_Ipsum(3,'Paragraphs')To_Base64('A-Za-z0-9%2B/%3D')To_Charcode('Space',10)Standard_Deviation('Space')
            // lets take a bit more because it might not be pure base64 also include some xor, shift, replacement, ...
            // 89 is the mean of the base64 chars
            math.deviation(500, filesize-500, 89.0) < 23
        ) or (
            // gzinflated binary sometimes used in php webshells
            // ignore first and last 500bytes because they usually contain code for decoding and executing
            math.entropy(500, filesize-500) >= 7.7 and
            // encoded text has a higher mean than text or code because it's missing the spaces and special chars with the low numbers
            math.mean(500, filesize-500) > 120 and
            math.mean(500, filesize-500) < 136 and
            // deviation of base64 is ~20 according to CyberChef_v9.21.0.html#recipe=Generate_Lorem_Ipsum(3,'Paragraphs')To_Base64('A-Za-z0-9%2B/%3D')To_Charcode('Space',10)Standard_Deviation('Space')
            // lets take a bit more because it might not be pure base64 also include some xor, shift, replacement, ...
            // 89 is the mean of the base64 chars
            math.deviation(500, filesize-500, 89.0) > 65
        ) 
		)
		
}

rule webshell_php_generic_backticks
{
	meta:
		description = "Generic PHP webshell which uses backticks directly on user input"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/07"
		hash = "339f32c883f6175233f0d1a30510caa52fdcaa37"

	strings:
		$backtick = /`[\t ]*\$(_POST\[|_GET\[|_REQUEST\[|_SERVER\['HTTP_)/ wide ascii
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
	condition:
		( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and $backtick and filesize < 200
}

rule webshell_php_generic_backticks_obfuscated
{
	meta:
		description = "Generic PHP webshell which uses backticks directly on user input"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		hash = "23dc299f941d98c72bd48659cdb4673f5ba93697"
		date = "2021/01/07"

	strings:
		$s1 = /echo[\t ]*\(?`\$/ wide ascii
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
	condition:
		filesize < 500 and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and $s1
}

rule webshell_php_by_string_known_webshell
{
	meta:
		description = "Known PHP Webshells which contain unique strings, lousy rule for low hanging fruits. Most are catched by other rules in here but maybe these catch different versions."
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/09"
		hash = "d889da22893536d5965541c30896f4ed4fdf461d"
		hash = "10f4988a191774a2c6b85604344535ee610b844c1708602a355cf7e9c12c3605"
		hash = "7b6471774d14510cf6fa312a496eed72b614f6fc"

	strings:
		$pbs1 = "b374k shell" wide ascii
		$pbs2 = "b374k/b374k" wide ascii
		$pbs3 = "\"b374k" wide ascii
		$pbs4 = "$b374k(\"" wide ascii
		$pbs5 = "b374k " wide ascii
		$pbs6 = "0de664ecd2be02cdd54234a0d1229b43" wide ascii
		$pbs7 = "pwnshell" wide ascii
		$pbs8 = "reGeorg" fullword wide ascii
		$pbs9 = "Georg says, 'All seems fine" fullword wide ascii
		$pbs10 = "My PHP Shell - A very simple web shell" wide ascii
		$pbs11 = "<title>My PHP Shell <?echo VERSION" wide ascii
		$pbs12 = "F4ckTeam" fullword wide ascii
		$pbs15 = "MulCiShell" fullword wide ascii
		// crawler avoid string
		$pbs30 = "bot|spider|crawler|slurp|teoma|archive|track|snoopy|java|lwp|wget|curl|client|python|libwww" wide ascii
		// <?=($pbs_=@$_GET[2]).@$_($_GET[1])?>
		$pbs35 = /@\$_GET\s?\[\d\]\)\.@\$_\(\$_GET\s?\[\d\]\)/ wide ascii
		$pbs36 = /@\$_GET\s?\[\d\]\)\.@\$_\(\$_POST\s?\[\d\]\)/ wide ascii
		$pbs37 = /@\$_POST\s?\[\d\]\)\.@\$_\(\$_GET\s?\[\d\]\)/ wide ascii
		$pbs38 = /@\$_POST\[\d\]\)\.@\$_\(\$_POST\[\d\]\)/ wide ascii
		$pbs39 = /@\$_REQUEST\[\d\]\)\.@\$_\(\$_REQUEST\[\d\]\)/ wide ascii
		$pbs42 = "array(\"find config.inc.php files\", \"find / -type f -name config.inc.php\")" wide ascii
		$pbs43 = "$_SERVER[\"\\x48\\x54\\x54\\x50" wide ascii
		$pbs52 = "preg_replace(\"/[checksql]/e\""
		$pbs53 = "='http://www.zjjv.com'"
		$pbs54 = "=\"http://www.zjjv.com\""

        $pbs60 = /setting\["AccountType"\]\s?=\s?3/
        $pbs61 = "~+d()\"^\"!{+{}"
        $pbs62 = "use function \\eval as "
        $pbs63 = "use function \\assert as "

		$front1 = "<?php eval(" nocase wide ascii
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
		//strings from private rule capa_bin_files
        $dex   = { 64 65 ( 78 | 79 ) 0a 30 }
        $pack  = { 50 41 43 4b 00 00 00 02 00 }
	
	condition:
		filesize < 500KB and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and not ( 
        uint16(0) == 0x5a4d or 
        $dex at 0 or 
        $pack at 0 or 
        // fp on jar with zero compression
        uint16(0) == 0x4b50 
		)
		and 
		( any of ( $pbs* ) or $front1 in ( 0 .. 60 ) )
}

rule webshell_php_by_string_obfuscation
{
	meta:
		description = "PHP file containing obfuscation strings. Might be legitimate code obfuscated for whatever reasons, a webshell or can be used to insert malicious Javascript for credit card skimming"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/09"
		hash = "e4a15637c90e8eabcbdc748366ae55996dbec926382220c423e754bd819d22bc"

	strings:
		$opbs13 = "{\"_P\"./*-/*-*/\"OS\"./*-/*-*/\"T\"}" wide ascii
		$opbs14 = "/*-/*-*/\"" wide ascii
		$opbs16 = "'ev'.'al'" wide ascii
		$opbs17 = "'e'.'val'" wide ascii
		$opbs18 = "e'.'v'.'a'.'l" wide ascii
		$opbs19 = "bas'.'e6'." wide ascii
		$opbs20 = "ba'.'se6'." wide ascii
		$opbs21 = "as'.'e'.'6'" wide ascii
		$opbs22 = "gz'.'inf'." wide ascii
		$opbs23 = "gz'.'un'.'c" wide ascii
		$opbs24 = "e'.'co'.'d" wide ascii
		$opbs25 = "cr\".\"eat" wide ascii
		$opbs26 = "un\".\"ct" wide ascii
		$opbs27 = "'c'.'h'.'r'" wide ascii
		$opbs28 = "\"ht\".\"tp\".\":/\"" wide ascii
		$opbs29 = "\"ht\".\"tp\".\"s:" wide ascii
		$opbs31 = "'ev'.'al'" nocase wide ascii
		$opbs32 = "eval/*" nocase wide ascii
		$opbs33 = "eval(/*" nocase wide ascii
		$opbs34 = "eval(\"/*" nocase wide ascii
		$opbs36 = "assert/*" nocase wide ascii
		$opbs37 = "assert(/*" nocase wide ascii
		$opbs38 = "assert(\"/*" nocase wide ascii
		$opbs40 = "'ass'.'ert'" nocase wide ascii
		$opbs41 = "${'_'.$_}['_'](${'_'.$_}['__'])" wide ascii
		$opbs44 = "'s'.'s'.'e'.'r'.'t'" nocase wide ascii
		$opbs45 = "'P'.'O'.'S'.'T'" wide ascii
		$opbs46 = "'G'.'E'.'T'" wide ascii
		$opbs47 = "'R'.'E'.'Q'.'U'" wide ascii
		$opbs48 = "se'.(32*2)" nocase
		$opbs49 = "'s'.'t'.'r_'" nocase
		$opbs50 = "'ro'.'t13'" nocase
		$opbs51 = "c'.'od'.'e" nocase
		$opbs53 = "e'. 128/2 .'_' .'d"
        // move malicious code out of sight if line wrapping not enabled
		$opbs54 = "<?php                                                                                                                                                                                " //here I end
		$opbs55 = "=chr(99).chr(104).chr(114);$_"
		$opbs56 = "\\x47LOBAL"
		$opbs57 = "pay\".\"load"
		$opbs58 = "bas'.'e64"
		$opbs59 = "dec'.'ode"
		$opbs60 = "fla'.'te"
        // rot13 of eval($_POST
		$opbs70 = "riny($_CBFG["
		$opbs71 = "riny($_TRG["
		$opbs72 = "riny($_ERDHRFG["
		$opbs73 = "eval(str_rot13("
		$opbs74 = "\"p\".\"r\".\"e\".\"g\""
		$opbs75 = "$_'.'GET"
		$opbs76 = "'ev'.'al("
        // eval( in hex
		$opbs77 = "\\x65\\x76\\x61\\x6c\\x28" wide ascii nocase
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
	condition:
		filesize < 500KB and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and any of ( $opbs* )
}

rule webshell_php_strings_susp
{
	meta:
		description = "typical webshell strings, suspicious"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/12"
		hash = "0dd568dbe946b5aa4e1d33eab1decbd71903ea04"
		score = 50

	strings:
		$sstring1 = "eval(\"?>\"" nocase wide ascii
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
		//strings from private rule php_false_positive
		// try to use only strings which would be flagged by themselves as suspicous by other rules, e.g. eval 
        // a good choice is a string with good atom quality = ideally 4 unusual characters next to each other
		$gfp1  = "eval(\"return [$serialised_parameter" // elgg
		$gfp2  = "$this->assert(strpos($styles, $"
		$gfp3  = "$module = new $_GET['module']($_GET['scope']);"
		$gfp4  = "$plugin->$_POST['action']($_POST['id']);"
		$gfp5  = "$_POST[partition_by]($_POST["
		$gfp6  = "$object = new $_REQUEST['type']($_REQUEST['id']);"
		$gfp7  = "The above example code can be easily exploited by passing in a string such as" // ... ;)
		$gfp8  = "Smarty_Internal_Debug::start_render($_template);"
		$gfp9  = "?p4yl04d=UNION%20SELECT%20'<?%20system($_GET['command']);%20?>',2,3%20INTO%20OUTFILE%20'/var/www/w3bsh3ll.php"
		$gfp10 = "[][}{;|]\\|\\\\[+=]\\|<?=>?"
		$gfp11 = "(eval (getenv \"EPROLOG\")))"
		$gfp12 = "ZmlsZV9nZXRfY29udGVudHMoJ2h0dHA6Ly9saWNlbnNlLm9wZW5jYXJ0LWFwaS5jb20vbGljZW5zZS5waHA/b3JkZXJ"
	
		//strings from private rule capa_php_input
		$inp1 = "php://input" wide ascii
		$inp2 = /_GET\s?\[/ wide ascii
        // for passing $_GET to a function 
		$inp3 = /\(\s?\$_GET\s?\)/ wide ascii
		$inp4 = /_POST\s?\[/ wide ascii
		$inp5 = /\(\s?\$_POST\s?\)/ wide ascii
		$inp6 = /_REQUEST\s?\[/ wide ascii
		$inp7 = /\(\s?\$_REQUEST\s?\)/ wide ascii
		// PHP automatically adds all the request headers into the $_SERVER global array, prefixing each header name by the "HTTP_" string, so e.g. @eval($_SERVER['HTTP_CMD']) will run any code in the HTTP header CMD
		$inp15 = "_SERVER['HTTP_" wide ascii
		$inp16 = "_SERVER[\"HTTP_" wide ascii
		$inp17 = /getenv[\t ]{0,20}\([\t ]{0,20}['"]HTTP_/ wide ascii
		$inp18 = "array_values($_SERVER)" wide ascii
		$inp19 = /file_get_contents\("https?:\/\// wide ascii
	
	condition:
		filesize < 700KB and ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and not ( 
			any of ( $gfp* ) 
		)
		and 
		( 2 of ( $sstring* ) or 
		( 1 of ( $sstring* ) and ( 
			any of ( $inp* ) 
		)
		) )
}

rule webshell_php_in_htaccess
{
	meta:
		description = "Use Apache .htaccess to execute php code inside .htaccess"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/07"
		hash = "c026d4512a32d93899d486c6f11d1e13b058a713"

	strings:
		$hta = "AddType application/x-httpd-php .htaccess" wide ascii

	condition:
		filesize <100KB and $hta
}

rule webshell_php_function_via_get
{
	meta:
		description = "Webshell which sends eval/assert via GET"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		hash = "ce739d65c31b3c7ea94357a38f7bd0dc264da052d4fd93a1eabb257f6e3a97a6"
		hash = "d870e971511ea3e082662f8e6ec22e8a8443ca79"
		hash = "73fa97372b3bb829835270a5e20259163ecc3fdbf73ef2a99cb80709ea4572be"
		date = "2021/01/09"

	strings:
		$sr0 = /\$_GET\s?\[.{1,30}\]\(\$_GET\s?\[/ wide ascii
		$sr1 = /\$_POST\s?\[.{1,30}\]\(\$_GET\s?\[/ wide ascii
		$sr2 = /\$_POST\s?\[.{1,30}\]\(\$_POST\s?\[/ wide ascii
		$sr3 = /\$_GET\s?\[.{1,30}\]\(\$_POST\s?\[/ wide ascii
		$sr4 = /\$_REQUEST\s?\[.{1,30}\]\(\$_REQUEST\s?\[/ wide ascii
		$sr5 = /\$_SERVER\s?\[HTTP_.{1,30}\]\(\$_SERVER\s?\[HTTP_/ wide ascii
	
		//strings from private rule php_false_positive
		// try to use only strings which would be flagged by themselves as suspicous by other rules, e.g. eval 
        // a good choice is a string with good atom quality = ideally 4 unusual characters next to each other
		$gfp1  = "eval(\"return [$serialised_parameter" // elgg
		$gfp2  = "$this->assert(strpos($styles, $"
		$gfp3  = "$module = new $_GET['module']($_GET['scope']);"
		$gfp4  = "$plugin->$_POST['action']($_POST['id']);"
		$gfp5  = "$_POST[partition_by]($_POST["
		$gfp6  = "$object = new $_REQUEST['type']($_REQUEST['id']);"
		$gfp7  = "The above example code can be easily exploited by passing in a string such as" // ... ;)
		$gfp8  = "Smarty_Internal_Debug::start_render($_template);"
		$gfp9  = "?p4yl04d=UNION%20SELECT%20'<?%20system($_GET['command']);%20?>',2,3%20INTO%20OUTFILE%20'/var/www/w3bsh3ll.php"
		$gfp10 = "[][}{;|]\\|\\\\[+=]\\|<?=>?"
		$gfp11 = "(eval (getenv \"EPROLOG\")))"
		$gfp12 = "ZmlsZV9nZXRfY29udGVudHMoJ2h0dHA6Ly9saWNlbnNlLm9wZW5jYXJ0LWFwaS5jb20vbGljZW5zZS5waHA/b3JkZXJ"
	
	condition:
		filesize < 500KB and not ( 
			any of ( $gfp* ) 
		)
		and any of ( $sr* )
}

rule webshell_php_writer
{
	meta:
		description = "PHP webshell which only writes an uploaded file to disk"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/04/17"
		score = 50

	strings:
        $sus4 = "\"upload\"" wide ascii
        $sus5 = "\"Upload\"" wide ascii
        $sus6 = "gif89" wide ascii
        //$sus13= "<textarea " wide ascii
        $sus16= "Army" fullword wide ascii
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
		//strings from private rule capa_php_input
		$inp1 = "php://input" wide ascii
		$inp2 = /_GET\s?\[/ wide ascii
        // for passing $_GET to a function 
		$inp3 = /\(\s?\$_GET\s?\)/ wide ascii
		$inp4 = /_POST\s?\[/ wide ascii
		$inp5 = /\(\s?\$_POST\s?\)/ wide ascii
		$inp6 = /_REQUEST\s?\[/ wide ascii
		$inp7 = /\(\s?\$_REQUEST\s?\)/ wide ascii
		// PHP automatically adds all the request headers into the $_SERVER global array, prefixing each header name by the "HTTP_" string, so e.g. @eval($_SERVER['HTTP_CMD']) will run any code in the HTTP header CMD
		$inp15 = "_SERVER['HTTP_" wide ascii
		$inp16 = "_SERVER[\"HTTP_" wide ascii
		$inp17 = /getenv[\t ]{0,20}\([\t ]{0,20}['"]HTTP_/ wide ascii
		$inp18 = "array_values($_SERVER)" wide ascii
		$inp19 = /file_get_contents\("https?:\/\// wide ascii
	
		//strings from private rule capa_php_write_file
		$php_multi_write1 = "fopen(" wide ascii
		$php_multi_write2 = "fwrite(" wide ascii
		$php_write1 = "move_uploaded_file" fullword wide ascii
	
	condition:
		( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and ( 
			any of ( $inp* ) 
		)
		and ( 
        any of ( $php_write* ) or
        all of ( $php_multi_write* ) 
		)
		and 
		( filesize < 400 or 
		( filesize < 4000 and 1 of ( $sus* ) ) )
}

rule webshell_asp_writer
{
	meta:
		description = "ASP webshell which only writes an uploaded file to disk"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/03/07"
		score = 60

	strings:
        $sus1 = "password" fullword wide ascii
        $sus2 = "pwd" fullword wide ascii
        $sus3 = "<asp:TextBox" fullword nocase wide ascii
        $sus4 = "\"upload\"" wide ascii
        $sus5 = "\"Upload\"" wide ascii
        $sus6 = "gif89" wide ascii
        $sus7 = "\"&\"" wide ascii
        $sus8 = "authkey" fullword wide ascii
        $sus9 = "AUTHKEY" fullword wide ascii
        $sus10= "test.asp" fullword wide ascii
        $sus11= "cmd.asp" fullword wide ascii
        $sus12= ".Write(Request." wide ascii
        $sus13= "<textarea " wide ascii
        $sus14= "\"unsafe" fullword wide ascii
        $sus15= "'unsafe" fullword wide ascii
        $sus16= "Army" fullword wide ascii
	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
		//strings from private rule capa_asp_input
        // Request.BinaryRead
        // Request.Form
		$asp_input1 = "request" fullword nocase wide ascii
		$asp_input2 = "Page_Load" fullword nocase wide ascii
        // base64 of Request.Form(
		$asp_input3 = "UmVxdWVzdC5Gb3JtK" fullword wide ascii
		$asp_xml_http = "Microsoft.XMLHTTP" fullword nocase wide ascii
		$asp_xml_method1 = "GET" fullword wide ascii
		$asp_xml_method2 = "POST" fullword wide ascii
		$asp_xml_method3 = "HEAD" fullword wide ascii
        // dynamic form
        $asp_form1 = "<form " wide ascii
        $asp_form2 = "<Form " wide ascii
        $asp_form3 = "<FORM " wide ascii
        $asp_asp   = "<asp:" wide ascii
        $asp_text1 = ".text" wide ascii
        $asp_text2 = ".Text" wide ascii
	
		//strings from private rule capa_asp_write_file
		// $asp_write1 = "ADODB.Stream" wide ascii # just a string, can be easily obfuscated
		$asp_always_write1 = /\.write/ nocase wide ascii
		$asp_always_write2 = /\.swrite/ nocase wide ascii
		//$asp_write_way_one1 = /\.open\b/ nocase wide ascii
		$asp_write_way_one2 = "SaveToFile" fullword nocase wide ascii
		$asp_write_way_one3 = "CREAtEtExtFiLE" fullword nocase wide ascii
		$asp_cr_write1 = "CreateObject(" fullword nocase wide ascii
		$asp_cr_write2 = "CreateObject (" fullword nocase wide ascii
		$asp_streamwriter1 = "streamwriter" fullword nocase wide ascii
		$asp_streamwriter2 = "filestream" fullword nocase wide ascii
	
	condition:
		( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		and ( 
			any of ( $asp_input* ) or
        (
            $asp_xml_http and
            any of ( $asp_xml_method* )
        ) or
        (
            any of ( $asp_form* ) and
            any of ( $asp_text* ) and
            $asp_asp
        ) 
		)
		and ( 
        any of ( $asp_always_write* ) and
        (
            any of ( $asp_write_way_one* ) and
            any of ( $asp_cr_write* )
        ) or (
            any of ( $asp_streamwriter* )
        ) 
		)
		and 
		( filesize < 400 or 
		( filesize < 6000 and 1 of ( $sus* ) ) )
}

rule webshell_asp_obfuscated
{
	meta:
		description = "ASP webshell obfuscated"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/12"

	strings:
        $asp_obf1 = "/*-/*-*/" wide ascii
        $asp_obf2 = "u\"+\"n\"+\"s" wide ascii
        $asp_obf3 = "\"e\"+\"v" wide ascii
        $asp_obf4 = "a\"+\"l\"" wide ascii
        $asp_obf5 = "\"+\"(\"+\"" wide ascii
        $asp_obf6 = "q\"+\"u\"" wide ascii
        $asp_obf7 = "\"u\"+\"e" wide ascii
        $asp_obf8 = "/*//*/" wide ascii
	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
		//strings from private rule capa_asp_payload
		$asp_payload0  = "eval_r" fullword nocase wide ascii
		$asp_payload1  = /\beval\s/ nocase wide ascii
		$asp_payload2  = /\beval\(/ nocase wide ascii
		$asp_payload3  = /\beval\"\"/ nocase wide ascii
        // var Fla = {'E':eval};  Fla.E(code)
		$asp_payload4  = /:\s{0,10}eval\b/ nocase wide ascii
		$asp_payload8  = /\bexecute\s?\(/ nocase wide ascii
		$asp_payload9  = /\bexecute\s[\w"]/ nocase wide ascii
		$asp_payload11 = "WSCRIPT.SHELL" fullword nocase wide ascii
		$asp_payload13 = "ExecuteGlobal" fullword nocase wide ascii
		$asp_payload14 = "ExecuteStatement" fullword nocase wide ascii
		$asp_payload15 = "ExecuteStatement" fullword nocase wide ascii
		$asp_multi_payload_one1 = "CreateObject" nocase fullword wide ascii
		$asp_multi_payload_one2 = "addcode" fullword wide ascii
		$asp_multi_payload_one3 = /\.run\b/ wide ascii
		$asp_multi_payload_two1 = "CreateInstanceFromVirtualPath" fullword wide ascii
		$asp_multi_payload_two2 = "ProcessRequest" fullword wide ascii
		$asp_multi_payload_two3 = "BuildManager" fullword wide ascii
		$asp_multi_payload_three1 = "System.Diagnostics" wide ascii
		$asp_multi_payload_three2 = "Process" fullword wide ascii
		$asp_multi_payload_three3 = ".Start" wide ascii
		// this is about "MSXML2.DOMDocument" but since that's easily obfuscated, lets not search for it
		$asp_multi_payload_four1 = "CreateObject" fullword nocase wide ascii
		$asp_multi_payload_four2 = "TransformNode" fullword nocase wide ascii
		$asp_multi_payload_four3 = "loadxml" fullword nocase wide ascii

        // execute cmd.exe /c with arguments using ProcessStartInfo
		$asp_multi_payload_five1 = "ProcessStartInfo" fullword nocase wide ascii
		$asp_multi_payload_five2 = ".Start" nocase wide ascii
		$asp_multi_payload_five3 = ".Filename" nocase wide ascii
		$asp_multi_payload_five4 = ".Arguments" nocase wide ascii

	
		//strings from private rule capa_asp_write_file
		// $asp_write1 = "ADODB.Stream" wide ascii # just a string, can be easily obfuscated
		$asp_always_write1 = /\.write/ nocase wide ascii
		$asp_always_write2 = /\.swrite/ nocase wide ascii
		//$asp_write_way_one1 = /\.open\b/ nocase wide ascii
		$asp_write_way_one2 = "SaveToFile" fullword nocase wide ascii
		$asp_write_way_one3 = "CREAtEtExtFiLE" fullword nocase wide ascii
		$asp_cr_write1 = "CreateObject(" fullword nocase wide ascii
		$asp_cr_write2 = "CreateObject (" fullword nocase wide ascii
		$asp_streamwriter1 = "streamwriter" fullword nocase wide ascii
		$asp_streamwriter2 = "filestream" fullword nocase wide ascii
	
		//strings from private rule capa_asp_obfuscation_multi
        // many Chr or few and a loop????
        //$loop1 = "For "
		//$o1 = "chr(" nocase wide ascii
		//$o2 = "chr (" nocase wide ascii
		// not excactly a string function but also often used in obfuscation
		$o4 = "\\x8" wide ascii
		$o5 = "\\x9" wide ascii
		// just picking some random numbers because they should appear often enough in a long obfuscated blob and it's faster than a regex
		$o6 = "\\61" wide ascii
		$o7 = "\\44" wide ascii
		$o8 = "\\112" wide ascii
		$o9 = "\\120" wide ascii
		//$o10 = " & \"" wide ascii
		//$o11 = " += \"" wide ascii
        // used for e.g. "scr"&"ipt"

        $m_multi_one1 = "Replace(" wide ascii
        $m_multi_one2 = "Len(" wide ascii
        $m_multi_one3 = "Mid(" wide ascii
        $m_multi_one4 = "mid(" wide ascii
        $m_multi_one5 = ".ToString(" wide ascii

        /*
        $m_multi_one5 = "InStr(" wide ascii
        $m_multi_one6 = "Function" wide ascii

        $m_multi_two1 = "for each" wide ascii
        $m_multi_two2 = "split(" wide ascii
        $m_multi_two3 = " & chr(" wide ascii
        $m_multi_two4 = " & Chr(" wide ascii
        $m_multi_two5 = " & Chr (" wide ascii

        $m_multi_three1 = "foreach" fullword wide ascii
        $m_multi_three2 = "(char" wide ascii

        $m_multi_four1 = "FromBase64String(" wide ascii
        $m_multi_four2 = ".Replace(" wide ascii
        $m_multi_five1 = "String.Join(\"\"," wide ascii
        $m_multi_five2 = ".Trim(" wide ascii
        $m_any1 = " & \"2" wide ascii
        $m_any2 = " += \"2" wide ascii
        */

        $m_fp1 = "Author: Andre Teixeira - andret@microsoft.com" /* FPs with 0227f4c366c07c45628b02bae6b4ad01 */

	
		//strings from private rule capa_asp_obfuscation_obviously
		$oo1 = /\w\"&\"\w/ wide ascii
		$oo2 = "*/\").Replace(\"/*" wide ascii
	
	condition:
		filesize < 100KB and ( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		and 
		( ( ( 
			any of ( $asp_payload* ) or
        all of ( $asp_multi_payload_one* ) or
        all of ( $asp_multi_payload_two* ) or
        all of ( $asp_multi_payload_three* ) or
        all of ( $asp_multi_payload_four* ) or
        all of ( $asp_multi_payload_five* ) 
		)
		or ( 
        any of ( $asp_always_write* ) and
        (
            any of ( $asp_write_way_one* ) and
            any of ( $asp_cr_write* )
        ) or (
            any of ( $asp_streamwriter* )
        ) 
		)
		) and 
		( ( 
        (
            filesize < 100KB and 
            not any of ( $m_fp* ) and
            (
                //( #o1+#o2 ) > 50 or
                ( #o4+#o5+#o6+#o7+#o8+#o9 ) > 20 
            ) 
        ) or (
            filesize < 5KB and 
            (
                //( #o1+#o2 ) > 10 or
                ( #o4+#o5+#o6+#o7+#o8+#o9 ) > 5 or
                (
                    //( #o1+#o2 ) > 1 and
                    ( #m_multi_one1 + #m_multi_one2 + #m_multi_one3 + #m_multi_one4 + #m_multi_one5 ) > 3 
                )

            ) 
        ) or (
            filesize < 700 and 
            (
                //( #o1+#o2 ) > 1 or
                ( #o4+#o5+#o6+#o7+#o8+#o9 ) > 3 or
                ( #m_multi_one1 + #m_multi_one2 + #m_multi_one3 + #m_multi_one4 + #m_multi_one5 ) > 2 
            ) 
        )  
		)
		or any of ( $asp_obf* ) ) or ( 
        (
            filesize < 100KB and 
            (
                ( #oo1 ) > 2 or
                $oo2
            ) 
        ) or (
            filesize < 25KB and 
            (
                ( #oo1 ) > 1
            ) 
        ) or (
            filesize < 1KB and 
            (
                ( #oo1 ) > 0 
            ) 
        )  
		)
		)
}

rule webshell_asp_generic_eval_on_input
{
	meta:
		description = "Generic ASP webshell which uses any eval/exec function directly on user input"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/07"
		hash = "d6b96d844ac395358ee38d4524105d331af42ede"
		hash = "9be2088d5c3bfad9e8dfa2d7d7ba7834030c7407"
		hash = "a1df4cfb978567c4d1c353e988915c25c19a0e4a"
		hash = "069ea990d32fc980939fffdf1aed77384bf7806bc57c0a7faaff33bd1a3447f6"

	strings:
		$payload_and_input0 = /\beval_r\s{0,20}\(Request\(/ nocase wide ascii
		$payload_and_input1 = /\beval[\s\(]{1,20}request[.\(\[]/ nocase wide ascii
		$payload_and_input2 = /\bexecute[\s\(]{1,20}request\(/ nocase wide ascii
		$payload_and_input4 = /\bExecuteGlobal\s{1,20}request\(/ nocase wide ascii
	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
	condition:
		( filesize < 1100KB and ( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		and any of ( $payload_and_input* ) ) or 
		( filesize < 100 and any of ( $payload_and_input* ) )
}

rule webshell_asp_nano
{
	meta:
		description = "Generic ASP webshell which uses any eval/exec function"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/13"
		hash = "3b7910a499c603715b083ddb6f881c1a0a3a924d"
		hash = "990e3f129b8ba409a819705276f8fa845b95dad0"
		hash = "22345e956bce23304f5e8e356c423cee60b0912c"
		hash = "c84a6098fbd89bd085526b220d0a3f9ab505bcba"
		hash = "b977c0ad20dc738b5dacda51ec8da718301a75d7"

	strings:
		$susasp1  = "/*-/*-*/"
		$susasp2  = "(\"%1"
		$susasp3  = /[Cc]hr\([Ss]tr\(/
		$susasp4  = "cmd.exe"
		$susasp5  = "cmd /c"
		$susasp7  = "FromBase64String"
        // Request and request in b64:
		$susasp8  = "UmVxdWVzdC"
		$susasp9  = "cmVxdWVzdA"
        $susasp10 = "/*//*/"
        $susasp11 = "(\"/*/\""
        $susasp12 = "eval(eval("
        $fp1      = "eval a"
        $fp2      = "'Eval'"
        $fp3      = "Eval(\""
	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
		//strings from private rule capa_asp_payload
		$asp_payload0  = "eval_r" fullword nocase wide ascii
		$asp_payload1  = /\beval\s/ nocase wide ascii
		$asp_payload2  = /\beval\(/ nocase wide ascii
		$asp_payload3  = /\beval\"\"/ nocase wide ascii
        // var Fla = {'E':eval};  Fla.E(code)
		$asp_payload4  = /:\s{0,10}eval\b/ nocase wide ascii
		$asp_payload8  = /\bexecute\s?\(/ nocase wide ascii
		$asp_payload9  = /\bexecute\s[\w"]/ nocase wide ascii
		$asp_payload11 = "WSCRIPT.SHELL" fullword nocase wide ascii
		$asp_payload13 = "ExecuteGlobal" fullword nocase wide ascii
		$asp_payload14 = "ExecuteStatement" fullword nocase wide ascii
		$asp_payload15 = "ExecuteStatement" fullword nocase wide ascii
		$asp_multi_payload_one1 = "CreateObject" nocase fullword wide ascii
		$asp_multi_payload_one2 = "addcode" fullword wide ascii
		$asp_multi_payload_one3 = /\.run\b/ wide ascii
		$asp_multi_payload_two1 = "CreateInstanceFromVirtualPath" fullword wide ascii
		$asp_multi_payload_two2 = "ProcessRequest" fullword wide ascii
		$asp_multi_payload_two3 = "BuildManager" fullword wide ascii
		$asp_multi_payload_three1 = "System.Diagnostics" wide ascii
		$asp_multi_payload_three2 = "Process" fullword wide ascii
		$asp_multi_payload_three3 = ".Start" wide ascii
		// this is about "MSXML2.DOMDocument" but since that's easily obfuscated, lets not search for it
		$asp_multi_payload_four1 = "CreateObject" fullword nocase wide ascii
		$asp_multi_payload_four2 = "TransformNode" fullword nocase wide ascii
		$asp_multi_payload_four3 = "loadxml" fullword nocase wide ascii

        // execute cmd.exe /c with arguments using ProcessStartInfo
		$asp_multi_payload_five1 = "ProcessStartInfo" fullword nocase wide ascii
		$asp_multi_payload_five2 = ".Start" nocase wide ascii
		$asp_multi_payload_five3 = ".Filename" nocase wide ascii
		$asp_multi_payload_five4 = ".Arguments" nocase wide ascii

	
		//strings from private rule capa_asp_write_file
		// $asp_write1 = "ADODB.Stream" wide ascii # just a string, can be easily obfuscated
		$asp_always_write1 = /\.write/ nocase wide ascii
		$asp_always_write2 = /\.swrite/ nocase wide ascii
		//$asp_write_way_one1 = /\.open\b/ nocase wide ascii
		$asp_write_way_one2 = "SaveToFile" fullword nocase wide ascii
		$asp_write_way_one3 = "CREAtEtExtFiLE" fullword nocase wide ascii
		$asp_cr_write1 = "CreateObject(" fullword nocase wide ascii
		$asp_cr_write2 = "CreateObject (" fullword nocase wide ascii
		$asp_streamwriter1 = "streamwriter" fullword nocase wide ascii
		$asp_streamwriter2 = "filestream" fullword nocase wide ascii
	
	condition:
		( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		and 
		( ( 
			any of ( $asp_payload* ) or
        all of ( $asp_multi_payload_one* ) or
        all of ( $asp_multi_payload_two* ) or
        all of ( $asp_multi_payload_three* ) or
        all of ( $asp_multi_payload_four* ) or
        all of ( $asp_multi_payload_five* ) 
		)
		or ( 
        any of ( $asp_always_write* ) and
        (
            any of ( $asp_write_way_one* ) and
            any of ( $asp_cr_write* )
        ) or (
            any of ( $asp_streamwriter* )
        ) 
		)
		) and not any of ( $fp* ) and 
		( filesize < 200 or 
		( filesize < 1000 and any of ( $susasp* ) ) )
}

rule webshell_asp_encoded
{
	meta:
		description = "Webshell in VBscript or JScript encoded using *.Encode plus a suspicious string"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/03/14"

	strings:
		$encoded1 = "VBScript.Encode" nocase wide ascii
		$encoded2 = "JScript.Encode" nocase wide ascii
		$data1 = "#@~^" wide ascii
		$sus1 = "shell" nocase wide ascii
		$sus2 = "cmd" fullword wide ascii
		$sus3 = "password" fullword wide ascii
		$sus4 = "UserPass" fullword wide ascii
	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
	condition:
		filesize < 500KB and ( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		and any of ( $encoded* ) and any of ( $data* ) and 
		( any of ( $sus* ) or 
		( filesize < 20KB and #data1 > 4 ) or 
		( filesize < 700 and #data1 > 0 ) )
}

rule webshell_asp_encoded_aspcoding
{
	meta:
		description = "ASP Webshell encoded using ASPEncodeDLL.AspCoding"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/03/14"
		score = 60

	strings:
		$encoded1 = "ASPEncodeDLL" fullword nocase wide ascii
		$encoded2 = ".Runt" nocase wide ascii
		$encoded3 = "Request" fullword nocase wide ascii
		$encoded4 = "Response" fullword nocase wide ascii
		$data1 = "AspCoding.EnCode" wide ascii
		//$sus1 = "shell" nocase wide ascii
		//$sus2 = "cmd" fullword wide ascii
		//$sus3 = "password" fullword wide ascii
		//$sus4 = "UserPass" fullword wide ascii
	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
	condition:
		filesize < 500KB and ( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		and all of ( $encoded* ) and any of ( $data* )
}

rule webshell_asp_by_string
{
	meta:
		description = "Known ASP Webshells which contain unique strings, lousy rule for low hanging fruits. Most are catched by other rules in here but maybe these catch different versions."
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/13"
		hash = "f72252b13d7ded46f0a206f63a1c19a66449f216"

	strings:
        // reversed
		$asp_string1  = "tseuqer lave" wide ascii
		$asp_string2  = ":eval request(" wide ascii
		$asp_string3  = ":eval request(" wide ascii
		$asp_string4  = "SItEuRl=\"http://www.zjjv.com\"" wide ascii
		$asp_string5  = "ServerVariables(\"HTTP_HOST\"),\"gov.cn\"" wide ascii
        // e+k-v+k-a+k-l
        // e+x-v+x-a+x-l
		$asp_string6  = /e\+.-v\+.-a\+.-l/ wide ascii
		$asp_string7  = "r+x-e+x-q+x-u" wide ascii
		$asp_string8  = "add6bb58e139be10" fullword wide ascii
		$asp_string9  = "WebAdmin2Y.x.y(\"" wide ascii
		$asp_string10 = "<%if (Request.Files.Count!=0) { Request.Files[0].SaveAs(Server.MapPath(Request[" wide ascii
		$asp_string11 = "<% If Request.Files.Count <> 0 Then Request.Files(0).SaveAs(Server.MapPath(Request(" wide ascii
        // Request.Item["
		$asp_string12 = "UmVxdWVzdC5JdGVtWyJ" wide ascii

        // eval( in utf7 in base64 all 3 versions
        $asp_string13 = "UAdgBhAGwAKA" wide ascii
		$asp_string14 = "lAHYAYQBsACgA" wide ascii
		$asp_string15 = "ZQB2AGEAbAAoA" wide ascii
        // request in utf7 in base64 all 3 versions
        $asp_string16 = "IAZQBxAHUAZQBzAHQAKA" wide ascii
		$asp_string17 = "yAGUAcQB1AGUAcwB0ACgA" wide ascii
		$asp_string18 = "cgBlAHEAdQBlAHMAdAAoA" wide ascii

		$asp_string19 = "\"ev\"&\"al" wide ascii
		$asp_string20 = "\"Sc\"&\"ri\"&\"p" wide ascii
		$asp_string21 = "C\"&\"ont\"&\"" wide ascii
		$asp_string22 = "\"vb\"&\"sc" wide ascii
		$asp_string23 = "\"A\"&\"do\"&\"d" wide ascii
		$asp_string24 = "St\"&\"re\"&\"am\"" wide ascii
		$asp_string25 = "*/eval(" wide ascii
		$asp_string26 = "\"e\"&\"v\"&\"a\"&\"l" nocase
		$asp_string27 = "<%eval\"\"&(\"" nocase wide ascii
		$asp_string28 = "6877656D2B736972786677752B237E232C2A"  wide ascii
		$asp_string29 = "ws\"&\"cript.shell" wide ascii
		$asp_string30 = "SerVer.CreAtEoBjECT(\"ADODB.Stream\")" wide ascii
		$asp_string31 = "ASPShell - web based shell" wide ascii
		$asp_string32 = "<++ CmdAsp.asp ++>" wide ascii
		$asp_string33 = "\"scr\"&\"ipt\"" wide ascii
		$asp_string34 = "Regex regImg = new Regex(\"[a-z|A-Z]{1}:\\\\\\\\[a-z|A-Z| |0-9|\\u4e00-\\u9fa5|\\\\~|\\\\\\\\|_|{|}|\\\\.]*\");" wide ascii
		$asp_string35 = "\"she\"&\"ll." wide ascii
		$asp_string36 = "LH\"&\"TTP" wide ascii
		$asp_string37 = "<title>Web Sniffer</title>" wide ascii
		$asp_string38 = "<title>WebSniff" wide ascii
		$asp_string39 = "cript\"&\"ing" wide ascii
		$asp_string40 = "tcejbOmetsySeliF.gnitpircS" wide ascii
		$asp_string41 = "tcejbOetaerC.revreS" wide ascii
		$asp_string42 = "This file is part of A Black Path Toward The Sun (\"ABPTTS\")" wide ascii
		$asp_string43 = "if ((Request.Headers[headerNameKey] != null) && (Request.Headers[headerNameKey].Trim() == headerValueKey.Trim()))" wide ascii
		$asp_string44 = "if (request.getHeader(headerNameKey).toString().trim().equals(headerValueKey.trim()))" wide ascii
		$asp_string45 = "Response.Write(Server.HtmlEncode(ExcutemeuCmd(txtArg.Text)));" wide ascii
		$asp_string46 = "\"c\" + \"m\" + \"d\"" wide ascii
		$asp_string47 = "\".\"+\"e\"+\"x\"+\"e\"" wide ascii

	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
	condition:
		filesize < 200KB and ( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		and any of ( $asp_string* )
}

rule webshell_asp_sniffer
{
	meta:
		description = "ASP webshell which can sniff local traffic"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/03/14"

	strings:
		$sniff1 = "Socket(" wide ascii
		$sniff2 = ".Bind(" wide ascii
		$sniff3 = ".SetSocketOption(" wide ascii
		$sniff4 = ".IOControl(" wide ascii
		$sniff5 = "PacketCaptureWriter" fullword wide ascii
	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
		//strings from private rule capa_asp_input
        // Request.BinaryRead
        // Request.Form
		$asp_input1 = "request" fullword nocase wide ascii
		$asp_input2 = "Page_Load" fullword nocase wide ascii
        // base64 of Request.Form(
		$asp_input3 = "UmVxdWVzdC5Gb3JtK" fullword wide ascii
		$asp_xml_http = "Microsoft.XMLHTTP" fullword nocase wide ascii
		$asp_xml_method1 = "GET" fullword wide ascii
		$asp_xml_method2 = "POST" fullword wide ascii
		$asp_xml_method3 = "HEAD" fullword wide ascii
        // dynamic form
        $asp_form1 = "<form " wide ascii
        $asp_form2 = "<Form " wide ascii
        $asp_form3 = "<FORM " wide ascii
        $asp_asp   = "<asp:" wide ascii
        $asp_text1 = ".text" wide ascii
        $asp_text2 = ".Text" wide ascii
	
	condition:
		( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		and ( 
			any of ( $asp_input* ) or
        (
            $asp_xml_http and
            any of ( $asp_xml_method* )
        ) or
        (
            any of ( $asp_form* ) and
            any of ( $asp_text* ) and
            $asp_asp
        ) 
		)
		and filesize < 30KB and all of ( $sniff* )
}

rule webshell_asp_generic_tiny
{
	meta:
		description = "Generic tiny ASP webshell which uses any eval/exec function indirectly on user input or writes a file"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/07"
		hash = "990e3f129b8ba409a819705276f8fa845b95dad0"
		hash = "52ce724580e533da983856c4ebe634336f5fd13a"

	strings:
        $fp1 = "net.rim.application.ipproxyservice.AdminCommand.execute"
	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
		//strings from private rule capa_asp_input
        // Request.BinaryRead
        // Request.Form
		$asp_input1 = "request" fullword nocase wide ascii
		$asp_input2 = "Page_Load" fullword nocase wide ascii
        // base64 of Request.Form(
		$asp_input3 = "UmVxdWVzdC5Gb3JtK" fullword wide ascii
		$asp_xml_http = "Microsoft.XMLHTTP" fullword nocase wide ascii
		$asp_xml_method1 = "GET" fullword wide ascii
		$asp_xml_method2 = "POST" fullword wide ascii
		$asp_xml_method3 = "HEAD" fullword wide ascii
        // dynamic form
        $asp_form1 = "<form " wide ascii
        $asp_form2 = "<Form " wide ascii
        $asp_form3 = "<FORM " wide ascii
        $asp_asp   = "<asp:" wide ascii
        $asp_text1 = ".text" wide ascii
        $asp_text2 = ".Text" wide ascii
	
		//strings from private rule capa_bin_files
        $dex   = { 64 65 ( 78 | 79 ) 0a 30 }
        $pack  = { 50 41 43 4b 00 00 00 02 00 }
	
		//strings from private rule capa_asp_payload
		$asp_payload0  = "eval_r" fullword nocase wide ascii
		$asp_payload1  = /\beval\s/ nocase wide ascii
		$asp_payload2  = /\beval\(/ nocase wide ascii
		$asp_payload3  = /\beval\"\"/ nocase wide ascii
        // var Fla = {'E':eval};  Fla.E(code)
		$asp_payload4  = /:\s{0,10}eval\b/ nocase wide ascii
		$asp_payload8  = /\bexecute\s?\(/ nocase wide ascii
		$asp_payload9  = /\bexecute\s[\w"]/ nocase wide ascii
		$asp_payload11 = "WSCRIPT.SHELL" fullword nocase wide ascii
		$asp_payload13 = "ExecuteGlobal" fullword nocase wide ascii
		$asp_payload14 = "ExecuteStatement" fullword nocase wide ascii
		$asp_payload15 = "ExecuteStatement" fullword nocase wide ascii
		$asp_multi_payload_one1 = "CreateObject" nocase fullword wide ascii
		$asp_multi_payload_one2 = "addcode" fullword wide ascii
		$asp_multi_payload_one3 = /\.run\b/ wide ascii
		$asp_multi_payload_two1 = "CreateInstanceFromVirtualPath" fullword wide ascii
		$asp_multi_payload_two2 = "ProcessRequest" fullword wide ascii
		$asp_multi_payload_two3 = "BuildManager" fullword wide ascii
		$asp_multi_payload_three1 = "System.Diagnostics" wide ascii
		$asp_multi_payload_three2 = "Process" fullword wide ascii
		$asp_multi_payload_three3 = ".Start" wide ascii
		// this is about "MSXML2.DOMDocument" but since that's easily obfuscated, lets not search for it
		$asp_multi_payload_four1 = "CreateObject" fullword nocase wide ascii
		$asp_multi_payload_four2 = "TransformNode" fullword nocase wide ascii
		$asp_multi_payload_four3 = "loadxml" fullword nocase wide ascii

        // execute cmd.exe /c with arguments using ProcessStartInfo
		$asp_multi_payload_five1 = "ProcessStartInfo" fullword nocase wide ascii
		$asp_multi_payload_five2 = ".Start" nocase wide ascii
		$asp_multi_payload_five3 = ".Filename" nocase wide ascii
		$asp_multi_payload_five4 = ".Arguments" nocase wide ascii

	
		//strings from private rule capa_asp_write_file
		// $asp_write1 = "ADODB.Stream" wide ascii # just a string, can be easily obfuscated
		$asp_always_write1 = /\.write/ nocase wide ascii
		$asp_always_write2 = /\.swrite/ nocase wide ascii
		//$asp_write_way_one1 = /\.open\b/ nocase wide ascii
		$asp_write_way_one2 = "SaveToFile" fullword nocase wide ascii
		$asp_write_way_one3 = "CREAtEtExtFiLE" fullword nocase wide ascii
		$asp_cr_write1 = "CreateObject(" fullword nocase wide ascii
		$asp_cr_write2 = "CreateObject (" fullword nocase wide ascii
		$asp_streamwriter1 = "streamwriter" fullword nocase wide ascii
		$asp_streamwriter2 = "filestream" fullword nocase wide ascii
	
	condition:
		( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		and ( 
			any of ( $asp_input* ) or
        (
            $asp_xml_http and
            any of ( $asp_xml_method* )
        ) or
        (
            any of ( $asp_form* ) and
            any of ( $asp_text* ) and
            $asp_asp
        ) 
		)
		and not 1 of ( $fp* ) and not ( 
        uint16(0) == 0x5a4d or 
        $dex at 0 or 
        $pack at 0 or 
        // fp on jar with zero compression
        uint16(0) == 0x4b50 
		)
		and 
		( filesize < 700 and 
		( ( 
			any of ( $asp_payload* ) or
        all of ( $asp_multi_payload_one* ) or
        all of ( $asp_multi_payload_two* ) or
        all of ( $asp_multi_payload_three* ) or
        all of ( $asp_multi_payload_four* ) or
        all of ( $asp_multi_payload_five* ) 
		)
		or ( 
        any of ( $asp_always_write* ) and
        (
            any of ( $asp_write_way_one* ) and
            any of ( $asp_cr_write* )
        ) or (
            any of ( $asp_streamwriter* )
        ) 
		)
		) )
}

rule webshell_asp_generic
{
	meta:
		description = "Generic ASP webshell which uses any eval/exec function indirectly on user input or writes a file"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/03/07"
		score = 60
		hash = "a8c63c418609c1c291b3e731ca85ded4b3e0fba83f3489c21a3199173b176a75"

	strings:
        $asp_much_sus7  = "Web Shell" nocase
        $asp_much_sus8  = "WebShell" nocase
        $asp_much_sus3  = "hidded shell" 
        $asp_much_sus4  = "WScript.Shell.1" nocase
        $asp_much_sus5  = "AspExec" 
        $asp_much_sus14 = "\\pcAnywhere\\" nocase
        $asp_much_sus15 = "antivirus" nocase
        $asp_much_sus16 = "McAfee" nocase
        $asp_much_sus17 = "nishang" 
        $asp_much_sus18 = "\"unsafe" fullword wide ascii
        $asp_much_sus19 = "'unsafe" fullword wide ascii
        $asp_much_sus28 = "exploit" fullword wide ascii
        $asp_much_sus30 = "TVqQAAMAAA" wide ascii
        $asp_much_sus31 = "HACKED" fullword wide ascii
        $asp_much_sus32 = "hacked" fullword wide ascii
        $asp_much_sus33 = "hacker" wide ascii
        $asp_much_sus34 = "grayhat" nocase wide ascii
        $asp_much_sus35 = "Microsoft FrontPage" wide ascii
        $asp_much_sus36 = "Rootkit" wide ascii
        $asp_much_sus37 = "rootkit" wide ascii
        $asp_much_sus38 = "/*-/*-*/" wide ascii
        $asp_much_sus39 = "u\"+\"n\"+\"s" wide ascii
        $asp_much_sus40 = "\"e\"+\"v" wide ascii
        $asp_much_sus41 = "a\"+\"l\"" wide ascii
        $asp_much_sus42 = "\"+\"(\"+\"" wide ascii
        $asp_much_sus43 = "q\"+\"u\"" wide ascii
        $asp_much_sus44 = "\"u\"+\"e" wide ascii
        $asp_much_sus45 = "/*//*/" wide ascii
        $asp_much_sus46 = "(\"/*/\"" wide ascii
        $asp_much_sus47 = "eval(eval(" wide ascii
        $asp_much_sus48 = "Shell.Users" wide ascii
        $asp_much_sus49 = "PasswordType=Regular" wide ascii
        $asp_much_sus50 = "-Expire=0" wide ascii
        $asp_much_sus51 = "sh\"&\"el" wide ascii

        $asp_gen_sus1  = /:\s{0,20}eval}/ nocase wide ascii
        $asp_gen_sus2  = /\.replace\(\/\w\/g/ nocase wide ascii
        $asp_gen_sus6  = "self.delete"
        $asp_gen_sus9  = "\"cmd /c" nocase
        $asp_gen_sus10 = "\"cmd\"" nocase
        $asp_gen_sus11 = "\"cmd.exe" nocase
        $asp_gen_sus12 = "%comspec%" wide ascii
        $asp_gen_sus13 = "%COMSPEC%" wide ascii
        //TODO:$asp_gen_sus12 = ".UserName" nocase
        $asp_gen_sus18 = "Hklm.GetValueNames();" nocase
        // bonus string for proxylogon exploiting webshells
        $asp_gen_sus19 = "http://schemas.microsoft.com/exchange/" wide ascii
        $asp_gen_sus21 = "\"upload\"" wide ascii
        $asp_gen_sus22 = "\"Upload\"" wide ascii
        $asp_gen_sus25 = "shell_" wide ascii
        //$asp_gen_sus26 = "password" fullword wide ascii
        //$asp_gen_sus27 = "passw" fullword wide ascii
        // own base64 func
        $asp_gen_sus29 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" fullword wide ascii
        $asp_gen_sus30 = "serv-u" wide ascii
        $asp_gen_sus31 = "Serv-u" wide ascii
        $asp_gen_sus32 = "Army" fullword wide ascii

        $asp_slightly_sus1 = "<pre>" wide ascii
        $asp_slightly_sus2 = "<PRE>" wide ascii


        // "e"+"x"+"e"
        $asp_gen_obf1 = "\"+\"" wide ascii 

        $fp1 = "DataBinder.Eval" 
	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
		//strings from private rule capa_bin_files
        $dex   = { 64 65 ( 78 | 79 ) 0a 30 }
        $pack  = { 50 41 43 4b 00 00 00 02 00 }
	
		//strings from private rule capa_asp_input
        // Request.BinaryRead
        // Request.Form
		$asp_input1 = "request" fullword nocase wide ascii
		$asp_input2 = "Page_Load" fullword nocase wide ascii
        // base64 of Request.Form(
		$asp_input3 = "UmVxdWVzdC5Gb3JtK" fullword wide ascii
		$asp_xml_http = "Microsoft.XMLHTTP" fullword nocase wide ascii
		$asp_xml_method1 = "GET" fullword wide ascii
		$asp_xml_method2 = "POST" fullword wide ascii
		$asp_xml_method3 = "HEAD" fullword wide ascii
        // dynamic form
        $asp_form1 = "<form " wide ascii
        $asp_form2 = "<Form " wide ascii
        $asp_form3 = "<FORM " wide ascii
        $asp_asp   = "<asp:" wide ascii
        $asp_text1 = ".text" wide ascii
        $asp_text2 = ".Text" wide ascii
	
		//strings from private rule capa_asp_payload
		$asp_payload0  = "eval_r" fullword nocase wide ascii
		$asp_payload1  = /\beval\s/ nocase wide ascii
		$asp_payload2  = /\beval\(/ nocase wide ascii
		$asp_payload3  = /\beval\"\"/ nocase wide ascii
        // var Fla = {'E':eval};  Fla.E(code)
		$asp_payload4  = /:\s{0,10}eval\b/ nocase wide ascii
		$asp_payload8  = /\bexecute\s?\(/ nocase wide ascii
		$asp_payload9  = /\bexecute\s[\w"]/ nocase wide ascii
		$asp_payload11 = "WSCRIPT.SHELL" fullword nocase wide ascii
		$asp_payload13 = "ExecuteGlobal" fullword nocase wide ascii
		$asp_payload14 = "ExecuteStatement" fullword nocase wide ascii
		$asp_payload15 = "ExecuteStatement" fullword nocase wide ascii
		$asp_multi_payload_one1 = "CreateObject" nocase fullword wide ascii
		$asp_multi_payload_one2 = "addcode" fullword wide ascii
		$asp_multi_payload_one3 = /\.run\b/ wide ascii
		$asp_multi_payload_two1 = "CreateInstanceFromVirtualPath" fullword wide ascii
		$asp_multi_payload_two2 = "ProcessRequest" fullword wide ascii
		$asp_multi_payload_two3 = "BuildManager" fullword wide ascii
		$asp_multi_payload_three1 = "System.Diagnostics" wide ascii
		$asp_multi_payload_three2 = "Process" fullword wide ascii
		$asp_multi_payload_three3 = ".Start" wide ascii
		// this is about "MSXML2.DOMDocument" but since that's easily obfuscated, lets not search for it
		$asp_multi_payload_four1 = "CreateObject" fullword nocase wide ascii
		$asp_multi_payload_four2 = "TransformNode" fullword nocase wide ascii
		$asp_multi_payload_four3 = "loadxml" fullword nocase wide ascii

        // execute cmd.exe /c with arguments using ProcessStartInfo
		$asp_multi_payload_five1 = "ProcessStartInfo" fullword nocase wide ascii
		$asp_multi_payload_five2 = ".Start" nocase wide ascii
		$asp_multi_payload_five3 = ".Filename" nocase wide ascii
		$asp_multi_payload_five4 = ".Arguments" nocase wide ascii

	
		//strings from private rule capa_asp_write_file
		// $asp_write1 = "ADODB.Stream" wide ascii # just a string, can be easily obfuscated
		$asp_always_write1 = /\.write/ nocase wide ascii
		$asp_always_write2 = /\.swrite/ nocase wide ascii
		//$asp_write_way_one1 = /\.open\b/ nocase wide ascii
		$asp_write_way_one2 = "SaveToFile" fullword nocase wide ascii
		$asp_write_way_one3 = "CREAtEtExtFiLE" fullword nocase wide ascii
		$asp_cr_write1 = "CreateObject(" fullword nocase wide ascii
		$asp_cr_write2 = "CreateObject (" fullword nocase wide ascii
		$asp_streamwriter1 = "streamwriter" fullword nocase wide ascii
		$asp_streamwriter2 = "filestream" fullword nocase wide ascii
	
		//strings from private rule capa_asp_classid
		$tagasp_capa_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_capa_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_capa_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_capa_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_capa_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
	
	condition:
		( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		and not ( 
        uint16(0) == 0x5a4d or 
        $dex at 0 or 
        $pack at 0 or 
        // fp on jar with zero compression
        uint16(0) == 0x4b50 
		)
		and ( 
			any of ( $asp_input* ) or
        (
            $asp_xml_http and
            any of ( $asp_xml_method* )
        ) or
        (
            any of ( $asp_form* ) and
            any of ( $asp_text* ) and
            $asp_asp
        ) 
		)
		and ( 
			any of ( $asp_payload* ) or
        all of ( $asp_multi_payload_one* ) or
        all of ( $asp_multi_payload_two* ) or
        all of ( $asp_multi_payload_three* ) or
        all of ( $asp_multi_payload_four* ) or
        all of ( $asp_multi_payload_five* ) 
		)
		and not any of ( $fp* ) and 
		( ( filesize < 3KB and 
		( 1 of ( $asp_slightly_sus* ) ) ) or 
		( filesize < 25KB and 
		( 1 of ( $asp_much_sus* ) or 1 of ( $asp_gen_sus* ) or 
		( #asp_gen_obf1 > 2 ) ) ) or 
		( filesize < 50KB and 
		( 1 of ( $asp_much_sus* ) or 3 of ( $asp_gen_sus* ) or 
		( #asp_gen_obf1 > 6 ) ) ) or 
		( filesize < 150KB and 
		( 1 of ( $asp_much_sus* ) or 4 of ( $asp_gen_sus* ) or 
		( #asp_gen_obf1 > 6 ) or 
		( ( 
        any of ( $asp_always_write* ) and
        (
            any of ( $asp_write_way_one* ) and
            any of ( $asp_cr_write* )
        ) or (
            any of ( $asp_streamwriter* )
        ) 
		)
		and 
		( 1 of ( $asp_much_sus* ) or 2 of ( $asp_gen_sus* ) or 
		( #asp_gen_obf1 > 3 ) ) ) ) ) or 
		( filesize < 100KB and ( 
        any of ( $tagasp_capa_classid* ) 
		)
		) )
}

rule webshell_asp_generic_registry_reader
{
	meta:
		description = "Generic ASP webshell which reads the registry (might look for passwords, license keys, database settings, general recon, ..."
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/03/14"
		score = 50

	strings:
        $asp_reg1  = "Registry" fullword wide ascii
        $asp_reg2  = "LocalMachine" fullword wide ascii
        $asp_reg3  = "ClassesRoot" fullword wide ascii
        $asp_reg4  = "CurrentUser" fullword wide ascii
        $asp_reg5  = "Users" fullword wide ascii
        $asp_reg6  = "CurrentConfig" fullword wide ascii
        $asp_reg7  = "Microsoft.Win32" fullword wide ascii
        $asp_reg8  = "OpenSubKey" fullword wide ascii

        $sus1 = "shell" fullword nocase wide ascii
        $sus2 = "cmd.exe" fullword wide ascii
        $sus3 = "<form " wide ascii
        $sus4 = "<table " wide ascii
        $sus5 = "System.Security.SecurityException" wide ascii

        $fp1 = "Avira Operations GmbH" wide
	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
		//strings from private rule capa_asp_input
        // Request.BinaryRead
        // Request.Form
		$asp_input1 = "request" fullword nocase wide ascii
		$asp_input2 = "Page_Load" fullword nocase wide ascii
        // base64 of Request.Form(
		$asp_input3 = "UmVxdWVzdC5Gb3JtK" fullword wide ascii
		$asp_xml_http = "Microsoft.XMLHTTP" fullword nocase wide ascii
		$asp_xml_method1 = "GET" fullword wide ascii
		$asp_xml_method2 = "POST" fullword wide ascii
		$asp_xml_method3 = "HEAD" fullword wide ascii
        // dynamic form
        $asp_form1 = "<form " wide ascii
        $asp_form2 = "<Form " wide ascii
        $asp_form3 = "<FORM " wide ascii
        $asp_asp   = "<asp:" wide ascii
        $asp_text1 = ".text" wide ascii
        $asp_text2 = ".Text" wide ascii
	
	condition:
		( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		and all of ( $asp_reg* ) and any of ( $sus* ) and not any of ( $fp* ) and 
		( filesize < 10KB or 
		( filesize < 150KB and ( 
			any of ( $asp_input* ) or
        (
            $asp_xml_http and
            any of ( $asp_xml_method* )
        ) or
        (
            any of ( $asp_form* ) and
            any of ( $asp_text* ) and
            $asp_asp
        ) 
		)
		) )
}

rule webshell_aspx_regeorg_csharp
{
	meta:
		description = "Webshell regeorg aspx c# version"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		reference = "https://github.com/sensepost/reGeorg"
		hash = "c1f43b7cf46ba12cfc1357b17e4f5af408740af7ae70572c9cf988ac50260ce1"
		author = "Arnim Rupp"
		date = "2021/01/11"

	strings:
		$input_sa1 = "Request.QueryString.Get" fullword nocase wide ascii
		$input_sa2 = "Request.Headers.Get" fullword nocase wide ascii
		$sa1 = "AddressFamily.InterNetwork" fullword nocase wide ascii
		$sa2 = "Response.AddHeader" fullword nocase wide ascii
		$sa3 = "Request.InputStream.Read" nocase wide ascii
		$sa4 = "Response.BinaryWrite" nocase wide ascii
		$sa5 = "Socket" nocase wide ascii
        $georg = "Response.Write(\"Georg says, 'All seems fine'\")"
	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
	condition:
		filesize < 300KB and ( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		and 
		( $georg or 
		( all of ( $sa* ) and any of ( $input_sa* ) ) )
}

rule webshell_csharp_generic
{
	meta:
		description = "Webshell in c#"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		hash = "b6721683aadc4b4eba4f081f2bc6bc57adfc0e378f6d80e2bfa0b1e3e57c85c7"
		date = "2021/01/11"

	strings:
		$input_http = "Request." nocase wide ascii
		$input_form1 = "<asp:" nocase wide ascii
		$input_form2 = ".text" nocase wide ascii
		$exec_proc1 = "new Process" nocase wide ascii
		$exec_proc2 = "start(" nocase wide ascii
		$exec_shell1 = "cmd.exe" nocase wide ascii
		$exec_shell2 = "powershell.exe" nocase wide ascii
	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
	condition:
		( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		and filesize < 300KB and 
		( $input_http or all of ( $input_form* ) ) and all of ( $exec_proc* ) and any of ( $exec_shell* )
}

rule webshell_asp_runtime_compile
{
	meta:
		description = "ASP webshell compiling payload in memory at runtime, e.g. sharpyshell"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		reference = "https://github.com/antonioCoco/SharPyShell"
		date = "2021/01/11"
		hash = "e826c4139282818d38dcccd35c7ae6857b1d1d01"
		hash = "e20e078d9fcbb209e3733a06ad21847c5c5f0e52"
		hash = "57f758137aa3a125e4af809789f3681d1b08ee5b"
		type = "file"

	strings:
		$payload_reflection1 = "System.Reflection" nocase wide ascii
		$payload_reflection2 = "Assembly" fullword nocase wide ascii
		$payload_load_reflection1 = /[."']Load\b/ nocase wide ascii
        // only match on "load" or variable which might contain "load"
		$payload_load_reflection2 = /\bGetMethod\(("load|\w)/ nocase wide ascii
		$payload_compile1 = "GenerateInMemory" nocase wide ascii
		$payload_compile2 = "CompileAssemblyFromSource" nocase wide ascii
		$payload_invoke1 = "Invoke" fullword nocase wide ascii
		$payload_invoke2 = "CreateInstance" fullword nocase wide ascii
        $rc_fp1 = "Request.MapPath"
        $rc_fp2 = "<body><mono:MonoSamplesHeader runat=\"server\"/>" wide ascii
	
		//strings from private rule capa_asp_input
        // Request.BinaryRead
        // Request.Form
		$asp_input1 = "request" fullword nocase wide ascii
		$asp_input2 = "Page_Load" fullword nocase wide ascii
        // base64 of Request.Form(
		$asp_input3 = "UmVxdWVzdC5Gb3JtK" fullword wide ascii
		$asp_xml_http = "Microsoft.XMLHTTP" fullword nocase wide ascii
		$asp_xml_method1 = "GET" fullword wide ascii
		$asp_xml_method2 = "POST" fullword wide ascii
		$asp_xml_method3 = "HEAD" fullword wide ascii
        // dynamic form
        $asp_form1 = "<form " wide ascii
        $asp_form2 = "<Form " wide ascii
        $asp_form3 = "<FORM " wide ascii
        $asp_asp   = "<asp:" wide ascii
        $asp_text1 = ".text" wide ascii
        $asp_text2 = ".Text" wide ascii
	
	condition:
		filesize < 10KB and ( 
			any of ( $asp_input* ) or
        (
            $asp_xml_http and
            any of ( $asp_xml_method* )
        ) or
        (
            any of ( $asp_form* ) and
            any of ( $asp_text* ) and
            $asp_asp
        ) 
		)
		and not any of ( $rc_fp* ) and 
		( ( all of ( $payload_reflection* ) and any of ( $payload_load_reflection* ) ) or all of ( $payload_compile* ) ) and any of ( $payload_invoke* )
}

rule webshell_asp_sql
{
	meta:
		description = "ASP webshell giving SQL access. Might also be a dual use tool."
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/03/14"

	strings:
        $sql1 = "SqlConnection" fullword wide ascii
        $sql2 = "SQLConnection" fullword wide ascii
        $sql3 = "System" fullword wide ascii
        $sql4 = "Data" fullword wide ascii
        $sql5 = "SqlClient" fullword wide ascii
        $sql6 = "SQLClient" fullword wide ascii
        $sql7 = "Open" fullword wide ascii
        $sql8 = "SqlCommand" fullword wide ascii
        $sql9 = "SQLCommand" fullword wide ascii

        $o_sql1 = "SQLOLEDB" fullword wide ascii
        $o_sql2 = "CreateObject" fullword wide ascii
        $o_sql3 = "open" fullword wide ascii

        $a_sql1 = "ADODB.Connection" fullword wide ascii
        $a_sql2 = "adodb.connection" fullword wide ascii
        $a_sql3 = "CreateObject" fullword wide ascii
        $a_sql4 = "createobject" fullword wide ascii
        $a_sql5 = "open" fullword wide ascii

        $c_sql1 = "System.Data.SqlClient" fullword wide ascii
        $c_sql2 = "sqlConnection" fullword wide ascii
        $c_sql3 = "open" fullword wide ascii

        $sus1 = "shell" fullword nocase wide ascii
        $sus2 = "xp_cmdshell" fullword nocase wide ascii
        $sus3 = "aspxspy" fullword nocase wide ascii
        $sus4 = "_KillMe" wide ascii
        $sus5 = "cmd.exe" fullword wide ascii
        $sus6 = "cmd /c" fullword wide ascii
        $sus7 = "net user" fullword wide ascii
        $sus8 = "\\x2D\\x3E\\x7C" wide ascii
        $sus9 = "Hacker" fullword wide ascii
        $sus10 = "hacker" fullword wide ascii
        $sus11 = "HACKER" fullword wide ascii
        $sus12 = "webshell" wide ascii
        $sus13 = "equest[\"sql\"]" wide ascii
        $sus14 = "equest(\"sql\")" wide ascii
        $sus15 = { e5 bc 80 e5 a7 8b e5 af bc e5 }
        $sus16 = "\"sqlCommand\"" wide ascii
        $sus17 = "\"sqlcommand\"" wide ascii

        //$slightly_sus1 = "select * from " wide ascii
        //$slightly_sus2 = "SELECT * FROM " wide ascii
        $slightly_sus3 = "SHOW COLUMNS FROM " wide ascii
        $slightly_sus4 = "show columns from " wide ascii
        
	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
		//strings from private rule capa_asp_input
        // Request.BinaryRead
        // Request.Form
		$asp_input1 = "request" fullword nocase wide ascii
		$asp_input2 = "Page_Load" fullword nocase wide ascii
        // base64 of Request.Form(
		$asp_input3 = "UmVxdWVzdC5Gb3JtK" fullword wide ascii
		$asp_xml_http = "Microsoft.XMLHTTP" fullword nocase wide ascii
		$asp_xml_method1 = "GET" fullword wide ascii
		$asp_xml_method2 = "POST" fullword wide ascii
		$asp_xml_method3 = "HEAD" fullword wide ascii
        // dynamic form
        $asp_form1 = "<form " wide ascii
        $asp_form2 = "<Form " wide ascii
        $asp_form3 = "<FORM " wide ascii
        $asp_asp   = "<asp:" wide ascii
        $asp_text1 = ".text" wide ascii
        $asp_text2 = ".Text" wide ascii
	
	condition:
		( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		and ( 
			any of ( $asp_input* ) or
        (
            $asp_xml_http and
            any of ( $asp_xml_method* )
        ) or
        (
            any of ( $asp_form* ) and
            any of ( $asp_text* ) and
            $asp_asp
        ) 
		)
		and 
		( 6 of ( $sql* ) or all of ( $o_sql* ) or 3 of ( $a_sql* ) or all of ( $c_sql* ) ) and 
		( ( filesize < 150KB and any of ( $sus* ) ) or 
		( filesize < 5KB and any of ( $slightly_sus* ) ) )
}

rule webshell_asp_scan_writable
{
	meta:
		description = "ASP webshell searching for writable directories (to hide more webshells ...)"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/03/14"
		hash = "2409eda9047085baf12e0f1b9d0b357672f7a152"
		hash = "af1c00696243f8b062a53dad9fb8b773fa1f0395631ffe6c7decc42c47eedee7"

	strings:
        $scan1 = "DirectoryInfo" nocase fullword wide ascii
        $scan2 = "GetDirectories" nocase fullword wide ascii
        $scan3 = "Create" nocase fullword wide ascii
        $scan4 = "File" nocase fullword wide ascii
        $scan5 = "System.IO" nocase fullword wide ascii
        // two methods: check permissions or write and delete:
        $scan6 = "CanWrite" nocase fullword wide ascii
        $scan7 = "Delete" nocase fullword wide ascii


        $sus1 = "upload" nocase fullword wide ascii
        $sus2 = "shell" nocase wide ascii
        $sus3 = "orking directory" nocase fullword wide ascii
        $sus4 = "scan" nocase wide ascii
        
	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
		//strings from private rule capa_asp_input
        // Request.BinaryRead
        // Request.Form
		$asp_input1 = "request" fullword nocase wide ascii
		$asp_input2 = "Page_Load" fullword nocase wide ascii
        // base64 of Request.Form(
		$asp_input3 = "UmVxdWVzdC5Gb3JtK" fullword wide ascii
		$asp_xml_http = "Microsoft.XMLHTTP" fullword nocase wide ascii
		$asp_xml_method1 = "GET" fullword wide ascii
		$asp_xml_method2 = "POST" fullword wide ascii
		$asp_xml_method3 = "HEAD" fullword wide ascii
        // dynamic form
        $asp_form1 = "<form " wide ascii
        $asp_form2 = "<Form " wide ascii
        $asp_form3 = "<FORM " wide ascii
        $asp_asp   = "<asp:" wide ascii
        $asp_text1 = ".text" wide ascii
        $asp_text2 = ".Text" wide ascii
	
	condition:
		filesize < 10KB and ( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		and ( 
			any of ( $asp_input* ) or
        (
            $asp_xml_http and
            any of ( $asp_xml_method* )
        ) or
        (
            any of ( $asp_form* ) and
            any of ( $asp_text* ) and
            $asp_asp
        ) 
		)
		and 6 of ( $scan* ) and any of ( $sus* )
}

rule webshell_jsp_regeorg
{
	meta:
		description = "Webshell regeorg JSP version"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		reference = "https://github.com/sensepost/reGeorg"
		hash = "6db49e43722080b5cd5f07e058a073ba5248b584"
		author = "Arnim Rupp"
		date = "2021/01/24"

	strings:
		$jgeorg1 = "request" fullword wide ascii
		$jgeorg2 = "getHeader" fullword wide ascii
		$jgeorg3 = "X-CMD" fullword wide ascii
		$jgeorg4 = "X-STATUS" fullword wide ascii
		$jgeorg5 = "socket" fullword wide ascii
		$jgeorg6 = "FORWARD" fullword wide ascii
	
		//strings from private rule capa_jsp_safe
		$cjsp_short1 = "<%" ascii wide
		$cjsp_short2 = "%>" wide ascii
		$cjsp_long1 = "<jsp:" ascii wide
		$cjsp_long2 = /language=[\"']java[\"\']/ ascii wide
		// JSF
		$cjsp_long3 = "/jstl/core" ascii wide
		$cjsp_long4 = "<%@p" nocase ascii wide
		$cjsp_long5 = "<%@ " nocase ascii wide
		$cjsp_long6 = "<% " ascii wide
		$cjsp_long7 = "< %" ascii wide
	
	condition:
		filesize < 300KB and ( 
        $cjsp_short1 at 0 or
			any of ( $cjsp_long* ) or
			$cjsp_short2 in ( filesize-100..filesize ) or
        (
            $cjsp_short2 and (
                $cjsp_short1 in ( 0..1000 ) or
                $cjsp_short1 in ( filesize-1000..filesize ) 
            )
        ) 
		)
		and all of ( $jgeorg* )
}

rule webshell_jsp_http_proxy
{
	meta:
		description = "Webshell JSP HTTP proxy"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		hash = "2f9b647660923c5262636a5344e2665512a947a4"
		author = "Arnim Rupp"
		date = "2021/01/24"

	strings:
		$jh1 = "OutputStream" fullword wide ascii
		$jh2 = "InputStream"  wide ascii
		$jh3 = "BufferedReader" fullword wide ascii
		$jh4 = "HttpRequest" fullword wide ascii
		$jh5 = "openConnection" fullword wide ascii
		$jh6 = "getParameter" fullword wide ascii
	
		//strings from private rule capa_jsp_safe
		$cjsp_short1 = "<%" ascii wide
		$cjsp_short2 = "%>" wide ascii
		$cjsp_long1 = "<jsp:" ascii wide
		$cjsp_long2 = /language=[\"']java[\"\']/ ascii wide
		// JSF
		$cjsp_long3 = "/jstl/core" ascii wide
		$cjsp_long4 = "<%@p" nocase ascii wide
		$cjsp_long5 = "<%@ " nocase ascii wide
		$cjsp_long6 = "<% " ascii wide
		$cjsp_long7 = "< %" ascii wide
	
	condition:
		filesize < 10KB and ( 
        $cjsp_short1 at 0 or
			any of ( $cjsp_long* ) or
			$cjsp_short2 in ( filesize-100..filesize ) or
        (
            $cjsp_short2 and (
                $cjsp_short1 in ( 0..1000 ) or
                $cjsp_short1 in ( filesize-1000..filesize ) 
            )
        ) 
		)
		and all of ( $jh* )
}

rule webshell_jsp_writer_nano
{
	meta:
		description = "JSP file writer"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/24"
		hash = "ac91e5b9b9dcd373eaa9360a51aa661481ab9429"
		hash = "c718c885b5d6e29161ee8ea0acadb6e53c556513"

	strings:
		$payload1 = ".write" wide ascii
		$payload2 = "getBytes" fullword wide ascii
	
		//strings from private rule capa_jsp_input
		// request.getParameter
		$input1 = "getParameter" fullword ascii wide
		// request.getHeaders
		$input2 = "getHeaders" fullword ascii wide
		$input3 = "getInputStream" fullword ascii wide
		$input4 = "getReader" fullword ascii wide
		$req1 = "request" fullword ascii wide
		$req2 = "HttpServletRequest" fullword ascii wide
		$req3 = "getRequest" fullword ascii wide
	
		//strings from private rule capa_jsp_safe
		$cjsp_short1 = "<%" ascii wide
		$cjsp_short2 = "%>" wide ascii
		$cjsp_long1 = "<jsp:" ascii wide
		$cjsp_long2 = /language=[\"']java[\"\']/ ascii wide
		// JSF
		$cjsp_long3 = "/jstl/core" ascii wide
		$cjsp_long4 = "<%@p" nocase ascii wide
		$cjsp_long5 = "<%@ " nocase ascii wide
		$cjsp_long6 = "<% " ascii wide
		$cjsp_long7 = "< %" ascii wide
	
	condition:
		filesize < 200 and ( 
			any of ( $input* ) and
			any of ( $req* ) 
		)
		and ( 
        $cjsp_short1 at 0 or
			any of ( $cjsp_long* ) or
			$cjsp_short2 in ( filesize-100..filesize ) or
        (
            $cjsp_short2 and (
                $cjsp_short1 in ( 0..1000 ) or
                $cjsp_short1 in ( filesize-1000..filesize ) 
            )
        ) 
		)
		and 2 of ( $payload* )
}

rule webshell_jsp_generic_tiny
{
	meta:
		description = "Generic JSP webshell tiny"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/07"
		hash = "8fd343db0442136e693e745d7af1018a99b042af"

	strings:
		$payload1 = "ProcessBuilder" fullword wide ascii
		$payload2 = "URLClassLoader" fullword wide ascii
		// Runtime.getRuntime().exec(
		$payload_rt1 = "Runtime" fullword wide ascii
		$payload_rt2 = "getRuntime" fullword wide ascii
		$payload_rt3 = "exec" fullword wide ascii
	
		//strings from private rule capa_jsp_safe
		$cjsp_short1 = "<%" ascii wide
		$cjsp_short2 = "%>" wide ascii
		$cjsp_long1 = "<jsp:" ascii wide
		$cjsp_long2 = /language=[\"']java[\"\']/ ascii wide
		// JSF
		$cjsp_long3 = "/jstl/core" ascii wide
		$cjsp_long4 = "<%@p" nocase ascii wide
		$cjsp_long5 = "<%@ " nocase ascii wide
		$cjsp_long6 = "<% " ascii wide
		$cjsp_long7 = "< %" ascii wide
	
		//strings from private rule capa_jsp_input
		// request.getParameter
		$input1 = "getParameter" fullword ascii wide
		// request.getHeaders
		$input2 = "getHeaders" fullword ascii wide
		$input3 = "getInputStream" fullword ascii wide
		$input4 = "getReader" fullword ascii wide
		$req1 = "request" fullword ascii wide
		$req2 = "HttpServletRequest" fullword ascii wide
		$req3 = "getRequest" fullword ascii wide
	
	condition:
		filesize < 250 and ( 
        $cjsp_short1 at 0 or
			any of ( $cjsp_long* ) or
			$cjsp_short2 in ( filesize-100..filesize ) or
        (
            $cjsp_short2 and (
                $cjsp_short1 in ( 0..1000 ) or
                $cjsp_short1 in ( filesize-1000..filesize ) 
            )
        ) 
		)
		and ( 
			any of ( $input* ) and
			any of ( $req* ) 
		)
		and 
		( 1 of ( $payload* ) or all of ( $payload_rt* ) )
}

rule webshell_jsp_generic
{
	meta:
		description = "Generic JSP webshell"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/07"
		hash = "4762f36ca01fb9cda2ab559623d2206f401fc0b1"
		hash = "bdaf9279b3d9e07e955d0ce706d9c42e4bdf9aa1"
		hash = "ee9408eb923f2d16f606a5aaac7e16b009797a07"

	strings:
		$susp0 = "cmd" fullword nocase ascii wide
		$susp1 = "command" fullword nocase ascii wide
		$susp2 = "shell" fullword nocase ascii wide
		$susp3 = "download" fullword nocase ascii wide
		$susp4 = "upload" fullword nocase ascii wide
		$susp5 = "Execute" fullword nocase ascii wide
		$susp6 = "\"pwd\"" ascii wide
		$susp7 = "\"</pre>" ascii wide

        $fp1 = "command = \"cmd.exe /c set\";"
	
		//strings from private rule capa_bin_files
        $dex   = { 64 65 ( 78 | 79 ) 0a 30 }
        $pack  = { 50 41 43 4b 00 00 00 02 00 }
	
		//strings from private rule capa_jsp_safe
		$cjsp_short1 = "<%" ascii wide
		$cjsp_short2 = "%>" wide ascii
		$cjsp_long1 = "<jsp:" ascii wide
		$cjsp_long2 = /language=[\"']java[\"\']/ ascii wide
		// JSF
		$cjsp_long3 = "/jstl/core" ascii wide
		$cjsp_long4 = "<%@p" nocase ascii wide
		$cjsp_long5 = "<%@ " nocase ascii wide
		$cjsp_long6 = "<% " ascii wide
		$cjsp_long7 = "< %" ascii wide
	
		//strings from private rule capa_jsp_input
		// request.getParameter
		$input1 = "getParameter" fullword ascii wide
		// request.getHeaders
		$input2 = "getHeaders" fullword ascii wide
		$input3 = "getInputStream" fullword ascii wide
		$input4 = "getReader" fullword ascii wide
		$req1 = "request" fullword ascii wide
		$req2 = "HttpServletRequest" fullword ascii wide
		$req3 = "getRequest" fullword ascii wide
	
		//strings from private rule capa_jsp_payload
		$payload1 = "ProcessBuilder" fullword ascii wide
		$payload2 = "processCmd" fullword ascii wide
		// Runtime.getRuntime().exec(
		$rt_payload1 = "Runtime" fullword ascii wide
		$rt_payload2 = "getRuntime" fullword ascii wide
		$rt_payload3 = "exec" fullword ascii wide
	
	condition:
		filesize < 300KB and not ( 
        uint16(0) == 0x5a4d or 
        $dex at 0 or 
        $pack at 0 or 
        // fp on jar with zero compression
        uint16(0) == 0x4b50 
		)
		and ( 
        $cjsp_short1 at 0 or
			any of ( $cjsp_long* ) or
			$cjsp_short2 in ( filesize-100..filesize ) or
        (
            $cjsp_short2 and (
                $cjsp_short1 in ( 0..1000 ) or
                $cjsp_short1 in ( filesize-1000..filesize ) 
            )
        ) 
		)
		and ( 
			any of ( $input* ) and
			any of ( $req* ) 
		)
		and ( 
        1 of ( $payload* ) or
        all of ( $rt_payload* ) 
		)
		and not any of ( $fp* ) and any of ( $susp* )
}

rule webshell_jsp_generic_base64
{
	meta:
		description = "Generic JSP webshell with base64 encoded payload"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/24"
		hash = "8b5fe53f8833df3657ae2eeafb4fd101c05f0db0"
		hash = "1b916afdd415dfa4e77cecf47321fd676ba2184d"

	strings:
		// Runtime
		$one1 = "SdW50aW1l" wide ascii
		$one2 = "J1bnRpbW" wide ascii
		$one3 = "UnVudGltZ" wide ascii
		$one4 = "IAdQBuAHQAaQBtAGUA" wide ascii
		$one5 = "SAHUAbgB0AGkAbQBlA" wide ascii
		$one6 = "UgB1AG4AdABpAG0AZQ" wide ascii
		// exec
		$two1 = "leGVj" wide ascii
		$two2 = "V4ZW" wide ascii
		$two3 = "ZXhlY" wide ascii
		$two4 = "UAeABlAGMA" wide ascii
		$two5 = "lAHgAZQBjA" wide ascii
		$two6 = "ZQB4AGUAYw" wide ascii
		// ScriptEngineFactory
		$three1 = "TY3JpcHRFbmdpbmVGYWN0b3J5" wide ascii
		$three2 = "NjcmlwdEVuZ2luZUZhY3Rvcn" wide ascii
		$three3 = "U2NyaXB0RW5naW5lRmFjdG9ye" wide ascii
		$three4 = "MAYwByAGkAcAB0AEUAbgBnAGkAbgBlAEYAYQBjAHQAbwByAHkA" wide ascii
		$three5 = "TAGMAcgBpAHAAdABFAG4AZwBpAG4AZQBGAGEAYwB0AG8AcgB5A" wide ascii
		$three6 = "UwBjAHIAaQBwAHQARQBuAGcAaQBuAGUARgBhAGMAdABvAHIAeQ" wide ascii

	
		//strings from private rule capa_jsp_safe
		$cjsp_short1 = "<%" ascii wide
		$cjsp_short2 = "%>" wide ascii
		$cjsp_long1 = "<jsp:" ascii wide
		$cjsp_long2 = /language=[\"']java[\"\']/ ascii wide
		// JSF
		$cjsp_long3 = "/jstl/core" ascii wide
		$cjsp_long4 = "<%@p" nocase ascii wide
		$cjsp_long5 = "<%@ " nocase ascii wide
		$cjsp_long6 = "<% " ascii wide
		$cjsp_long7 = "< %" ascii wide
	
		//strings from private rule capa_bin_files
        $dex   = { 64 65 ( 78 | 79 ) 0a 30 }
        $pack  = { 50 41 43 4b 00 00 00 02 00 }
	
	condition:
		( 
        $cjsp_short1 at 0 or
			any of ( $cjsp_long* ) or
			$cjsp_short2 in ( filesize-100..filesize ) or
        (
            $cjsp_short2 and (
                $cjsp_short1 in ( 0..1000 ) or
                $cjsp_short1 in ( filesize-1000..filesize ) 
            )
        ) 
		)
		and not ( 
        uint16(0) == 0x5a4d or 
        $dex at 0 or 
        $pack at 0 or 
        // fp on jar with zero compression
        uint16(0) == 0x4b50 
		)
		and filesize < 300KB and 
		( any of ( $one* ) and any of ( $two* ) or any of ( $three* ) )
}

rule webshell_jsp_generic_processbuilder
{
	meta:
		description = "Generic JSP webshell which uses processbuilder to execute user input"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/07"
		hash = "82198670ac2072cd5c2853d59dcd0f8dfcc28923"
		hash = "c05a520d96e4ebf9eb5c73fc0fa446ceb5caf343"

	strings:
		$exec = "ProcessBuilder" fullword wide ascii
		$start = "start" fullword wide ascii
	
		//strings from private rule capa_jsp_input
		// request.getParameter
		$input1 = "getParameter" fullword ascii wide
		// request.getHeaders
		$input2 = "getHeaders" fullword ascii wide
		$input3 = "getInputStream" fullword ascii wide
		$input4 = "getReader" fullword ascii wide
		$req1 = "request" fullword ascii wide
		$req2 = "HttpServletRequest" fullword ascii wide
		$req3 = "getRequest" fullword ascii wide
	
	condition:
		filesize < 2000 and ( 
			any of ( $input* ) and
			any of ( $req* ) 
		)
		and $exec and $start
}

rule webshell_jsp_generic_reflection
{
	meta:
		description = "Generic JSP webshell which uses reflection to execute user input"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/07"
		hash = "62e6c6065b5ca45819c1fc049518c81d7d165744"

	strings:
		$ws_exec = "invoke" fullword wide ascii
		$ws_class = "Class" fullword wide ascii
		$fp = "SOAPConnection"
	
		//strings from private rule capa_jsp_safe
		$cjsp_short1 = "<%" ascii wide
		$cjsp_short2 = "%>" wide ascii
		$cjsp_long1 = "<jsp:" ascii wide
		$cjsp_long2 = /language=[\"']java[\"\']/ ascii wide
		// JSF
		$cjsp_long3 = "/jstl/core" ascii wide
		$cjsp_long4 = "<%@p" nocase ascii wide
		$cjsp_long5 = "<%@ " nocase ascii wide
		$cjsp_long6 = "<% " ascii wide
		$cjsp_long7 = "< %" ascii wide
	
		//strings from private rule capa_jsp_input
		// request.getParameter
		$input1 = "getParameter" fullword ascii wide
		// request.getHeaders
		$input2 = "getHeaders" fullword ascii wide
		$input3 = "getInputStream" fullword ascii wide
		$input4 = "getReader" fullword ascii wide
		$req1 = "request" fullword ascii wide
		$req2 = "HttpServletRequest" fullword ascii wide
		$req3 = "getRequest" fullword ascii wide
	
	condition:
		filesize < 10KB and all of ( $ws_* ) and ( 
        $cjsp_short1 at 0 or
			any of ( $cjsp_long* ) or
			$cjsp_short2 in ( filesize-100..filesize ) or
        (
            $cjsp_short2 and (
                $cjsp_short1 in ( 0..1000 ) or
                $cjsp_short1 in ( filesize-1000..filesize ) 
            )
        ) 
		)
		and ( 
			any of ( $input* ) and
			any of ( $req* ) 
		)
		and not $fp
}

rule webshell_jsp_generic_classloader
{
	meta:
		description = "Generic JSP webshell which uses classloader to execute user input"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		hash = "6b546e78cc7821b63192bb8e087c133e8702a377d17baaeb64b13f0dd61e2347"
		date = "2021/01/07"

	strings:
		$exec = "extends ClassLoader" wide ascii
		$class = "defineClass" fullword wide ascii
	
		//strings from private rule capa_jsp_safe
		$cjsp_short1 = "<%" ascii wide
		$cjsp_short2 = "%>" wide ascii
		$cjsp_long1 = "<jsp:" ascii wide
		$cjsp_long2 = /language=[\"']java[\"\']/ ascii wide
		// JSF
		$cjsp_long3 = "/jstl/core" ascii wide
		$cjsp_long4 = "<%@p" nocase ascii wide
		$cjsp_long5 = "<%@ " nocase ascii wide
		$cjsp_long6 = "<% " ascii wide
		$cjsp_long7 = "< %" ascii wide
	
		//strings from private rule capa_jsp_input
		// request.getParameter
		$input1 = "getParameter" fullword ascii wide
		// request.getHeaders
		$input2 = "getHeaders" fullword ascii wide
		$input3 = "getInputStream" fullword ascii wide
		$input4 = "getReader" fullword ascii wide
		$req1 = "request" fullword ascii wide
		$req2 = "HttpServletRequest" fullword ascii wide
		$req3 = "getRequest" fullword ascii wide
	
	condition:
		filesize < 10KB and ( 
        $cjsp_short1 at 0 or
			any of ( $cjsp_long* ) or
			$cjsp_short2 in ( filesize-100..filesize ) or
        (
            $cjsp_short2 and (
                $cjsp_short1 in ( 0..1000 ) or
                $cjsp_short1 in ( filesize-1000..filesize ) 
            )
        ) 
		)
		and ( 
			any of ( $input* ) and
			any of ( $req* ) 
		)
		and $exec and $class
}

rule webshell_jsp_generic_encoded_shell
{
	meta:
		description = "Generic JSP webshell which contains cmd or /bin/bash encoded in ascii ord"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/07"
		hash = "3eecc354390d60878afaa67a20b0802ce5805f3a9bb34e74dd8c363e3ca0ea5c"

	strings:
		$sj0 = /{ ?47, 98, 105, 110, 47, 98, 97, 115, 104/ wide ascii
		$sj1 = /{ ?99, 109, 100}/ wide ascii
		$sj2 = /{ ?99, 109, 100, 46, 101, 120, 101/ wide ascii
		$sj3 = /{ ?47, 98, 105, 110, 47, 98, 97/ wide ascii
		$sj4 = /{ ?106, 97, 118, 97, 46, 108, 97, 110/ wide ascii
		$sj5 = /{ ?101, 120, 101, 99 }/ wide ascii
		$sj6 = /{ ?103, 101, 116, 82, 117, 110/ wide ascii

	condition:
		filesize <300KB and any of ($sj*)
}

rule webshell_jsp_netspy
{
	meta:
		description = "JSP netspy webshell"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/24"
		hash = "94d1aaabde8ff9b4b8f394dc68caebf981c86587"
		hash = "3870b31f26975a7cb424eab6521fc9bffc2af580"

	strings:
		$scan1 = "scan" nocase wide ascii
		$scan2 = "port" nocase wide ascii
		$scan3 = "web" fullword nocase wide ascii
		$scan4 = "proxy" fullword nocase wide ascii
		$scan5 = "http" fullword nocase wide ascii
		$scan6 = "https" fullword nocase wide ascii
		$write1 = "os.write" fullword wide ascii
		$write2 = "FileOutputStream" fullword wide ascii
		$write3 = "PrintWriter" fullword wide ascii
		$http = "java.net.HttpURLConnection" fullword wide ascii
	
		//strings from private rule capa_jsp_safe
		$cjsp_short1 = "<%" ascii wide
		$cjsp_short2 = "%>" wide ascii
		$cjsp_long1 = "<jsp:" ascii wide
		$cjsp_long2 = /language=[\"']java[\"\']/ ascii wide
		// JSF
		$cjsp_long3 = "/jstl/core" ascii wide
		$cjsp_long4 = "<%@p" nocase ascii wide
		$cjsp_long5 = "<%@ " nocase ascii wide
		$cjsp_long6 = "<% " ascii wide
		$cjsp_long7 = "< %" ascii wide
	
		//strings from private rule capa_jsp_input
		// request.getParameter
		$input1 = "getParameter" fullword ascii wide
		// request.getHeaders
		$input2 = "getHeaders" fullword ascii wide
		$input3 = "getInputStream" fullword ascii wide
		$input4 = "getReader" fullword ascii wide
		$req1 = "request" fullword ascii wide
		$req2 = "HttpServletRequest" fullword ascii wide
		$req3 = "getRequest" fullword ascii wide
	
	condition:
		filesize < 30KB and ( 
        $cjsp_short1 at 0 or
			any of ( $cjsp_long* ) or
			$cjsp_short2 in ( filesize-100..filesize ) or
        (
            $cjsp_short2 and (
                $cjsp_short1 in ( 0..1000 ) or
                $cjsp_short1 in ( filesize-1000..filesize ) 
            )
        ) 
		)
		and ( 
			any of ( $input* ) and
			any of ( $req* ) 
		)
		and 4 of ( $scan* ) and 1 of ( $write* ) and $http
}

rule webshell_jsp_by_string
{
	meta:
		description = "JSP Webshells which contain unique strings, lousy rule for low hanging fruits. Most are catched by other rules in here but maybe these catch different versions."
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/09"
		hash = "e9060aa2caf96be49e3b6f490d08b8a996c4b084"
		hash = "4c2464503237beba54f66f4a099e7e75028707aa"
		hash = "06b42d4707e7326aff402ecbb585884863c6351a"

	strings:
		$jstring1 = "<title>Boot Shell</title>" wide ascii
		$jstring2 = "String oraPWD=\"" wide ascii
		$jstring3 = "Owned by Chinese Hackers!" wide ascii
		$jstring4 = "AntSword JSP" wide ascii
		$jstring5 = "JSP Webshell</" wide ascii
		$jstring6 = "motoME722remind2012" wide ascii
		$jstring7 = "EC(getFromBase64(toStringHex(request.getParameter(\"password" wide ascii
		$jstring8 = "http://jmmm.com/web/index.jsp" wide ascii
		$jstring9 = "list.jsp = Directory & File View" wide ascii
		$jstring10 = "jdbcRowSet.setDataSourceName(request.getParameter(" wide ascii
		$jstring11 = "Mr.Un1k0d3r RingZer0 Team" wide ascii
		$jstring12 = "MiniWebCmdShell" fullword wide ascii
		$jstring13 = "pwnshell.jsp" fullword wide ascii
		$jstring14 = "session set &lt;key&gt; &lt;value&gt; [class]<br>"  wide ascii
		$jstring15 = "Runtime.getRuntime().exec(request.getParameter(" nocase wide ascii
		$jstring16 = "GIF98a<%@page" wide ascii
	
		//strings from private rule capa_jsp_safe
		$cjsp_short1 = "<%" ascii wide
		$cjsp_short2 = "%>" wide ascii
		$cjsp_long1 = "<jsp:" ascii wide
		$cjsp_long2 = /language=[\"']java[\"\']/ ascii wide
		// JSF
		$cjsp_long3 = "/jstl/core" ascii wide
		$cjsp_long4 = "<%@p" nocase ascii wide
		$cjsp_long5 = "<%@ " nocase ascii wide
		$cjsp_long6 = "<% " ascii wide
		$cjsp_long7 = "< %" ascii wide
	
		//strings from private rule capa_bin_files
        $dex   = { 64 65 ( 78 | 79 ) 0a 30 }
        $pack  = { 50 41 43 4b 00 00 00 02 00 }
	
	condition:
		filesize < 100KB and ( 
        $cjsp_short1 at 0 or
			any of ( $cjsp_long* ) or
			$cjsp_short2 in ( filesize-100..filesize ) or
        (
            $cjsp_short2 and (
                $cjsp_short1 in ( 0..1000 ) or
                $cjsp_short1 in ( filesize-1000..filesize ) 
            )
        ) 
		)
		and not ( 
        uint16(0) == 0x5a4d or 
        $dex at 0 or 
        $pack at 0 or 
        // fp on jar with zero compression
        uint16(0) == 0x4b50 
		)
		and any of ( $jstring* )
}

rule webshell_jsp_input_upload_write
{
	meta:
		description = "JSP uploader which gets input, writes files and contains \"upload\""
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/24"
		hash = "ef98ca135dfb9dcdd2f730b18e883adf50c4ab82"
		hash = "583231786bc1d0ecca7d8d2b083804736a3f0a32"
		hash = "19eca79163259d80375ebebbc440b9545163e6a3"

	strings:
		$upload = "upload" nocase wide ascii
		$write1 = "os.write" fullword wide ascii
		$write2 = "FileOutputStream" fullword wide ascii
	
		//strings from private rule capa_jsp_safe
		$cjsp_short1 = "<%" ascii wide
		$cjsp_short2 = "%>" wide ascii
		$cjsp_long1 = "<jsp:" ascii wide
		$cjsp_long2 = /language=[\"']java[\"\']/ ascii wide
		// JSF
		$cjsp_long3 = "/jstl/core" ascii wide
		$cjsp_long4 = "<%@p" nocase ascii wide
		$cjsp_long5 = "<%@ " nocase ascii wide
		$cjsp_long6 = "<% " ascii wide
		$cjsp_long7 = "< %" ascii wide
	
		//strings from private rule capa_jsp_input
		// request.getParameter
		$input1 = "getParameter" fullword ascii wide
		// request.getHeaders
		$input2 = "getHeaders" fullword ascii wide
		$input3 = "getInputStream" fullword ascii wide
		$input4 = "getReader" fullword ascii wide
		$req1 = "request" fullword ascii wide
		$req2 = "HttpServletRequest" fullword ascii wide
		$req3 = "getRequest" fullword ascii wide
	
	condition:
		filesize < 10KB and ( 
        $cjsp_short1 at 0 or
			any of ( $cjsp_long* ) or
			$cjsp_short2 in ( filesize-100..filesize ) or
        (
            $cjsp_short2 and (
                $cjsp_short1 in ( 0..1000 ) or
                $cjsp_short1 in ( filesize-1000..filesize ) 
            )
        ) 
		)
		and ( 
			any of ( $input* ) and
			any of ( $req* ) 
		)
		and $upload and 1 of ( $write* )
}

rule webshell_generic_os_strings
{
	meta:
		description = "typical webshell strings"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		date = "2021/01/12"
		score = 50

	strings:
		$fp1 = "http://evil.com/" wide ascii
		$fp2 = "denormalize('/etc/shadow" wide ascii
	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
		//strings from private rule capa_jsp_safe
		$cjsp_short1 = "<%" ascii wide
		$cjsp_short2 = "%>" wide ascii
		$cjsp_long1 = "<jsp:" ascii wide
		$cjsp_long2 = /language=[\"']java[\"\']/ ascii wide
		// JSF
		$cjsp_long3 = "/jstl/core" ascii wide
		$cjsp_long4 = "<%@p" nocase ascii wide
		$cjsp_long5 = "<%@ " nocase ascii wide
		$cjsp_long6 = "<% " ascii wide
		$cjsp_long7 = "< %" ascii wide
	
		//strings from private rule capa_os_strings
		// windows = nocase
		$w1 = "net localgroup administrators" nocase wide ascii
		$w2 = "net user" nocase wide ascii
		$w3 = "/add" nocase wide ascii
		// linux stuff, case sensitive:
		$l1 = "/etc/shadow" wide ascii
		$l2 = "/etc/ssh/sshd_config" wide ascii
		$take_two1 = "net user" nocase wide ascii
		$take_two2 = "/add" nocase wide ascii
	
	condition:
		filesize < 70KB and 
		( ( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		or ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		or ( 
        $cjsp_short1 at 0 or
			any of ( $cjsp_long* ) or
			$cjsp_short2 in ( filesize-100..filesize ) or
        (
            $cjsp_short2 and (
                $cjsp_short1 in ( 0..1000 ) or
                $cjsp_short1 in ( filesize-1000..filesize ) 
            )
        ) 
		)
		) and ( 
			filesize < 300KB and 
        not uint16(0) == 0x5a4d and (
            all of ( $w* ) or
            all of ( $l* ) or
            2 of ( $take_two* ) 
        ) 
		)
		and not any of ( $fp* )
}

rule webshell_in_image
{
	meta:
		description = "Webshell in GIF, PNG or JPG"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Arnim Rupp"
		hash = "d4fde4e691db3e70a6320e78657480e563a9f87935af873a99db72d6a9a83c78"
		date = "2021/02/27"
		score = 55

	strings:
        $png = { 89 50 4E 47 }
        $jpg = { FF D8 FF E0 }
        $gif = { 47 49 46 38 }
        $gif2 = "gif89"
        // MS access
        $mdb = { 00 01 00 00 53 74 }
        //$mdb = { 00 01 00 00 53 74 61 6E 64 61 72 64 20 4A 65 74 20 44 42 }
	
		//strings from private rule capa_php_old_safe
		$php_short = "<?" wide ascii
		// prevent xml and asp from hitting with the short tag
		$no_xml1 = "<?xml version" nocase wide ascii
		$no_xml2 = "<?xml-stylesheet" nocase wide ascii
		$no_asp1 = "<%@LANGUAGE" nocase wide ascii
		$no_asp2 = /<script language="(vb|jscript|c#)/ nocase wide ascii
		$no_pdf = "<?xpacket" 

		// of course the new tags should also match
        // already matched by "<?"
		$php_new1 = /<\?=[^?]/ wide ascii
		$php_new2 = "<?php" nocase wide ascii
		$php_new3 = "<script language=\"php" nocase wide ascii
	
		//strings from private rule capa_php_payload
		// \([^)] to avoid matching on e.g. eval() in comments
		$cpayload1 = /\beval[\t ]*\([^)]/ nocase wide ascii
		$cpayload2 = /\bexec[\t ]*\([^)]/ nocase wide ascii
		$cpayload3 = /\bshell_exec[\t ]*\([^)]/ nocase wide ascii
		$cpayload4 = /\bpassthru[\t ]*\([^)]/ nocase wide ascii
		$cpayload5 = /\bsystem[\t ]*\([^)]/ nocase wide ascii
		$cpayload6 = /\bpopen[\t ]*\([^)]/ nocase wide ascii
		$cpayload7 = /\bproc_open[\t ]*\([^)]/ nocase wide ascii
		$cpayload8 = /\bpcntl_exec[\t ]*\([^)]/ nocase wide ascii
		$cpayload9 = /\bassert[\t ]*\([^)0]/ nocase wide ascii
		$cpayload10 = /\bpreg_replace[\t ]*\(.{1,100}\/[ismxADSUXju]{0,11}(e|\\x65)/ nocase wide ascii
		$cpayload12 = /\bmb_ereg_replace[\t ]*\([^\)]{1,100}'e'/ nocase wide ascii
		$cpayload13 = /\bmb_eregi_replace[\t ]*\([^\)]{1,100}'e'/ nocase wide ascii
		$cpayload20 = /\bcreate_function[\t ]*\([^)]/ nocase wide ascii
		$cpayload21 = /\bReflectionFunction[\t ]*\([^)]/ nocase wide ascii

		$m_cpayload_preg_filter1 = /\bpreg_filter[\t ]*\([^\)]/ nocase wide ascii
		$m_cpayload_preg_filter2 = "'|.*|e'" nocase wide ascii
		// TODO backticks
	
		//strings from private rule capa_php_write_file
		$php_multi_write1 = "fopen(" wide ascii
		$php_multi_write2 = "fwrite(" wide ascii
		$php_write1 = "move_uploaded_file" fullword wide ascii
	
		//strings from private rule capa_jsp
		$cjsp1 = "<%" ascii wide
		$cjsp2 = "<jsp:" ascii wide
		$cjsp3 = /language=[\"']java[\"\']/ ascii wide
		// JSF
		$cjsp4 = "/jstl/core" ascii wide
	
		//strings from private rule capa_jsp_payload
		$payload1 = "ProcessBuilder" fullword ascii wide
		$payload2 = "processCmd" fullword ascii wide
		// Runtime.getRuntime().exec(
		$rt_payload1 = "Runtime" fullword ascii wide
		$rt_payload2 = "getRuntime" fullword ascii wide
		$rt_payload3 = "exec" fullword ascii wide
	
		//strings from private rule capa_asp
		$tagasp_short1 = /<%[^"]/ wide ascii
        // also looking for %> to reduce fp (yeah, short atom but seldom since special chars)
		$tagasp_short2 = "%>" wide ascii

        // classids for scripting host etc
		$tagasp_classid1 = "72C24DD5-D70A-438B-8A42-98424B88AFB8" nocase wide ascii
		$tagasp_classid2 = "F935DC22-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid3 = "093FF999-1EA0-4079-9525-9614C3504B74" nocase wide ascii
		$tagasp_classid4 = "F935DC26-1CF0-11D0-ADB9-00C04FD58A0B" nocase wide ascii
		$tagasp_classid5 = "0D43FE01-F093-11CF-8940-00A0C9054228" nocase wide ascii
		$tagasp_long10 = "<%@ " wide ascii
        // <% eval
		$tagasp_long11 = /<% \w/ nocase wide ascii
		$tagasp_long12 = "<%ex" nocase wide ascii
		$tagasp_long13 = "<%ev" nocase wide ascii

        // <%@ LANGUAGE = VBScript.encode%>
        // <%@ Language = "JScript" %>

        // <%@ WebHandler Language="C#" class="Handler" %>
        // <%@ WebService Language="C#" Class="Service" %>

        // <%@Page Language="Jscript"%>
        // <%@ Page Language = Jscript %>           
        // <%@PAGE LANGUAGE=JSCRIPT%>
        // <%@ Page Language="Jscript" validateRequest="false" %>
        // <%@ Page Language = Jscript %>
        // <%@ Page Language="C#" %>
        // <%@ Page Language="VB" ContentType="text/html" validaterequest="false" AspCompat="true" Debug="true" %>
        // <script runat="server" language="JScript">
        // <SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
        // <SCRIPT  RUNAT=SERVER  LANGUAGE=JSCRIPT>
        // <msxsl:script language="JScript" ...
		$tagasp_long20 = /<(%|script|msxsl:script).{0,60}language="?(vb|jscript|c#)/ nocase wide ascii

		$tagasp_long32 = /<script\s{1,30}runat=/ wide ascii
		$tagasp_long33 = /<SCRIPT\s{1,30}RUNAT=/ wide ascii

        // avoid hitting php
        $php1 = "<?php"
        $php2 = "<?="

        // avoid hitting jsp
        $jsp1 = "=\"java." wide ascii
        $jsp2 = "=\"javax." wide ascii
        $jsp3 = "java.lang." wide ascii
        $jsp4 = "public" fullword wide ascii
        $jsp5 = "throws" fullword wide ascii
        $jsp6 = "getValue" fullword wide ascii
        $jsp7 = "getBytes" fullword wide ascii

        $perl1 = "PerlScript" fullword
        
	
		//strings from private rule capa_asp_payload
		$asp_payload0  = "eval_r" fullword nocase wide ascii
		$asp_payload1  = /\beval\s/ nocase wide ascii
		$asp_payload2  = /\beval\(/ nocase wide ascii
		$asp_payload3  = /\beval\"\"/ nocase wide ascii
        // var Fla = {'E':eval};  Fla.E(code)
		$asp_payload4  = /:\s{0,10}eval\b/ nocase wide ascii
		$asp_payload8  = /\bexecute\s?\(/ nocase wide ascii
		$asp_payload9  = /\bexecute\s[\w"]/ nocase wide ascii
		$asp_payload11 = "WSCRIPT.SHELL" fullword nocase wide ascii
		$asp_payload13 = "ExecuteGlobal" fullword nocase wide ascii
		$asp_payload14 = "ExecuteStatement" fullword nocase wide ascii
		$asp_payload15 = "ExecuteStatement" fullword nocase wide ascii
		$asp_multi_payload_one1 = "CreateObject" nocase fullword wide ascii
		$asp_multi_payload_one2 = "addcode" fullword wide ascii
		$asp_multi_payload_one3 = /\.run\b/ wide ascii
		$asp_multi_payload_two1 = "CreateInstanceFromVirtualPath" fullword wide ascii
		$asp_multi_payload_two2 = "ProcessRequest" fullword wide ascii
		$asp_multi_payload_two3 = "BuildManager" fullword wide ascii
		$asp_multi_payload_three1 = "System.Diagnostics" wide ascii
		$asp_multi_payload_three2 = "Process" fullword wide ascii
		$asp_multi_payload_three3 = ".Start" wide ascii
		// this is about "MSXML2.DOMDocument" but since that's easily obfuscated, lets not search for it
		$asp_multi_payload_four1 = "CreateObject" fullword nocase wide ascii
		$asp_multi_payload_four2 = "TransformNode" fullword nocase wide ascii
		$asp_multi_payload_four3 = "loadxml" fullword nocase wide ascii

        // execute cmd.exe /c with arguments using ProcessStartInfo
		$asp_multi_payload_five1 = "ProcessStartInfo" fullword nocase wide ascii
		$asp_multi_payload_five2 = ".Start" nocase wide ascii
		$asp_multi_payload_five3 = ".Filename" nocase wide ascii
		$asp_multi_payload_five4 = ".Arguments" nocase wide ascii

	
		//strings from private rule capa_asp_write_file
		// $asp_write1 = "ADODB.Stream" wide ascii # just a string, can be easily obfuscated
		$asp_always_write1 = /\.write/ nocase wide ascii
		$asp_always_write2 = /\.swrite/ nocase wide ascii
		//$asp_write_way_one1 = /\.open\b/ nocase wide ascii
		$asp_write_way_one2 = "SaveToFile" fullword nocase wide ascii
		$asp_write_way_one3 = "CREAtEtExtFiLE" fullword nocase wide ascii
		$asp_cr_write1 = "CreateObject(" fullword nocase wide ascii
		$asp_cr_write2 = "CreateObject (" fullword nocase wide ascii
		$asp_streamwriter1 = "streamwriter" fullword nocase wide ascii
		$asp_streamwriter2 = "filestream" fullword nocase wide ascii
	
	condition:
		( $png at 0 or $jpg at 0 or $gif at 0 or $gif2 at 0 or $mdb at 0 ) and 
		( ( ( 
			(
				( 
						$php_short in (0..100) or 
						$php_short in (filesize-1000..filesize)
				)
				and not any of ( $no_* )
			) 
			or any of ( $php_new* ) 
		)
		and 
		( ( 
			any of ( $cpayload* ) or
        all of ( $m_cpayload_preg_filter* ) 
		)
		or ( 
        any of ( $php_write* ) or
        all of ( $php_multi_write* ) 
		)
		) ) or 
		( ( 
			any of ( $cjsp* ) 
		)
		and ( 
        1 of ( $payload* ) or
        all of ( $rt_payload* ) 
		)
		) or 
		( ( 
        (
            any of ( $tagasp_long* ) or
            // TODO :  yara_push_private_rules.py doesn't do private rules in private rules yet
            any of ( $tagasp_classid* ) or
            (
                $tagasp_short1 and
                $tagasp_short2 in ( filesize-100..filesize ) 
            ) or (
                $tagasp_short2 and (
                    $tagasp_short1 in ( 0..1000 ) or
                    $tagasp_short1 in ( filesize-1000..filesize ) 
                )
            ) 
        ) and not ( 
            (
                any of ( $perl* ) or
                $php1 at 0 or
                $php2 at 0 
            ) or (
                ( #jsp1 + #jsp2 + #jsp3 ) > 0 and ( #jsp4 + #jsp5 + #jsp6 + #jsp7 ) > 0
                )
        ) 
		)
		and 
		( ( 
			any of ( $asp_payload* ) or
        all of ( $asp_multi_payload_one* ) or
        all of ( $asp_multi_payload_two* ) or
        all of ( $asp_multi_payload_three* ) or
        all of ( $asp_multi_payload_four* ) or
        all of ( $asp_multi_payload_five* ) 
		)
		or ( 
        any of ( $asp_always_write* ) and
        (
            any of ( $asp_write_way_one* ) and
            any of ( $asp_cr_write* )
        ) or (
            any of ( $asp_streamwriter* )
        ) 
		)
		) ) )
}

