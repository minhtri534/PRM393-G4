$ErrorActionPreference = 'Stop'

$base = 'http://localhost:3000'
$swaggerPath = 'D:\Data-Labelling-Support-System\backend\scripts\swagger_v1.json'
$ts = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

$results = New-Object System.Collections.Generic.List[object]
$testedOps = New-Object 'System.Collections.Generic.HashSet[string]'

function Add-Result([string]$op,[string]$phase,[bool]$ok,[int]$status,[string]$note){
  $results.Add([pscustomobject]@{ Operation=$op; Phase=$phase; Ok=$ok; Status=$status; Note=$note }) | Out-Null
}

function Mark-Tested([string]$op){ [void]$testedOps.Add($op) }

function Invoke-Api {
  param(
    [string]$Method,
    [string]$Url,
    [hashtable]$Headers = @{},
    [object]$Body = $null
  )

  try {
    $params = @{ Method = $Method; Uri = $Url; Headers = $Headers }
    if ($null -ne $Body) {
      $params['Body'] = ($Body | ConvertTo-Json -Depth 12)
      $params['ContentType'] = 'application/json'
    }
    $resp = Invoke-RestMethod @params
    return @{ ok = $true; status = 200; body = $resp; raw = '' }
  }
  catch {
    $status = 0
    $raw = ''
    if ($_.Exception.Response) {
      $status = [int]$_.Exception.Response.StatusCode
      try {
        $reader = [IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $raw = $reader.ReadToEnd()
        $reader.Dispose()
      } catch {}
    }
    return @{ ok = $false; status = $status; body = $null; raw = $raw }
  }
}

function Run-Test {
  param(
    [string]$Method,
    [string]$TemplatePath,
    [string]$Url,
    [string]$Phase,
    [hashtable]$Headers = @{},
    [object]$Body = $null,
    [int[]]$ExpectedStatus = @(200)
  )

  $op = "{0} {1}" -f $Method.ToUpper(), $TemplatePath
  Mark-Tested $op

  $r = Invoke-Api -Method $Method -Url $Url -Headers $Headers -Body $Body
  $ok = $ExpectedStatus -contains $r.status
  $note = if ($ok) { 'ok' } else { if ([string]::IsNullOrWhiteSpace($r.raw)) { 'unexpected status' } else { $r.raw.Substring(0, [Math]::Min($r.raw.Length, 220)) } }
  Add-Result -op $op -phase $Phase -ok $ok -status $r.status -note $note
  return $r
}

function Get-RoleId([string]$roleName){
  $value = & sqlcmd -S localhost -d DLSS_Db -E -Q "SET NOCOUNT ON; SELECT TOP 1 [_id] FROM [Roles] WHERE [name]='$roleName';" -h -1 -W
  if ($null -eq $value) { return '' }
  return $value.ToString().Trim()
}

function Get-UserIdByEmail([string]$email){
  $value = & sqlcmd -S localhost -d DLSS_Db -E -Q "SET NOCOUNT ON; SELECT TOP 1 [_id] FROM [Users] WHERE [email]='$email';" -h -1 -W
  if ($null -eq $value) { return '' }
  return $value.ToString().Trim()
}

function Set-UserRole([string]$email,[string]$roleId){
  & sqlcmd -S localhost -d DLSS_Db -E -Q "UPDATE [Users] SET [role]='$roleId' WHERE [email]='$email';" -h -1 -W | Out-Null
}

function Safe-Trim([object]$value){
  if ($null -eq $value) { return '' }
  return $value.ToString().Trim()
}

function New-ObjectIdLike {
  return ([Guid]::NewGuid().ToString('N').Substring(0,24))
}

$managerRoleId = Get-RoleId 'Manager'
$annotatorRoleId = Get-RoleId 'Annotator'
$reviewerRoleId = Get-RoleId 'Reviewer'
$adminRoleId = Get-RoleId 'Admin'

if ([string]::IsNullOrWhiteSpace($managerRoleId) -or
    [string]::IsNullOrWhiteSpace($annotatorRoleId) -or
    [string]::IsNullOrWhiteSpace($reviewerRoleId) -or
    [string]::IsNullOrWhiteSpace($adminRoleId)) {
  throw 'Missing default roles in DB (Manager/Annotator/Reviewer/Admin). Seed roles before running smoke.'
}

$managerEmail = "manager.full.$ts@demo.local"
$annotatorEmail = "annotator.full.$ts@demo.local"
$reviewerEmail = "reviewer.full.$ts@demo.local"
$adminEmail = "admin.full.$ts@demo.local"
$authEmail = "auth.full.$ts@demo.local"
$password = 'Password123!'

$usersToCreate = @(
  @{ email=$managerEmail; roleId=$managerRoleId },
  @{ email=$annotatorEmail; roleId=$annotatorRoleId },
  @{ email=$reviewerEmail; roleId=$reviewerRoleId },
  @{ email=$adminEmail; roleId=$adminRoleId },
  @{ email=$authEmail; roleId=$managerRoleId }
)

foreach($u in $usersToCreate){
  Run-Test -Method 'POST' -TemplatePath '/api/auth/register' -Url "$base/api/auth/register" -Phase 'auth-setup' -Body @{ fullName='Smoke User'; email=$u.email; password=$password; phoneNumber=$null; identifyNumber=$null; gender=$null; address=$null; dateOfBirth=$null } -ExpectedStatus @(200) | Out-Null
  Set-UserRole -email $u.email -roleId $u.roleId
}

$managerId = Get-UserIdByEmail $managerEmail
$annotatorId = Get-UserIdByEmail $annotatorEmail
$reviewerId = Get-UserIdByEmail $reviewerEmail
$adminId = Get-UserIdByEmail $adminEmail
$authId = Get-UserIdByEmail $authEmail

$managerLogin = Run-Test -Method 'POST' -TemplatePath '/api/auth/login' -Url "$base/api/auth/login" -Phase 'auth' -Body @{ email=$managerEmail; password=$password } -ExpectedStatus @(200)
$annotatorLogin = Run-Test -Method 'POST' -TemplatePath '/api/auth/login' -Url "$base/api/auth/login" -Phase 'auth' -Body @{ email=$annotatorEmail; password=$password } -ExpectedStatus @(200)
$reviewerLogin = Run-Test -Method 'POST' -TemplatePath '/api/auth/login' -Url "$base/api/auth/login" -Phase 'auth' -Body @{ email=$reviewerEmail; password=$password } -ExpectedStatus @(200)
$adminLogin = Run-Test -Method 'POST' -TemplatePath '/api/auth/login' -Url "$base/api/auth/login" -Phase 'auth' -Body @{ email=$adminEmail; password=$password } -ExpectedStatus @(200)
$authLogin = Run-Test -Method 'POST' -TemplatePath '/api/auth/login' -Url "$base/api/auth/login" -Phase 'auth' -Body @{ email=$authEmail; password=$password } -ExpectedStatus @(200)

$managerToken = $managerLogin.body.data.accessToken
$annotatorToken = $annotatorLogin.body.data.accessToken
$reviewerToken = $reviewerLogin.body.data.accessToken
$adminToken = $adminLogin.body.data.accessToken
$authToken = $authLogin.body.data.accessToken

$authHeaders = @{ Authorization = "Bearer $authToken" }
$managerHeaders = @{ Authorization = "Bearer $managerToken" }
$annotatorHeaders = @{ Authorization = "Bearer $annotatorToken" }
$reviewerHeaders = @{ Authorization = "Bearer $reviewerToken" }
$adminHeaders = @{ Authorization = "Bearer $adminToken" }

# Auth extended endpoints
Run-Test -Method 'POST' -TemplatePath '/api/auth/refresh-token' -Url "$base/api/auth/refresh-token" -Phase 'auth' -Body @{ refreshToken=$authLogin.body.data.refreshToken } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'POST' -TemplatePath '/api/auth/forgot-password' -Url "$base/api/auth/forgot-password" -Phase 'auth' -Body @{ email=$authEmail } -ExpectedStatus @(200) | Out-Null
$forgot = Invoke-Api -Method 'POST' -Url "$base/api/auth/forgot-password" -Body @{ email=$authEmail }
$resetToken = $forgot.body.data.resetToken
if (-not [string]::IsNullOrWhiteSpace($resetToken)) {
  Run-Test -Method 'POST' -TemplatePath '/api/auth/reset-password' -Url "$base/api/auth/reset-password" -Phase 'auth' -Body @{ email=$authEmail; resetToken=$resetToken; newPassword='Password123!A' } -ExpectedStatus @(200) | Out-Null
  Run-Test -Method 'POST' -TemplatePath '/api/auth/login' -Url "$base/api/auth/login" -Phase 'auth' -Body @{ email=$authEmail; password='Password123!A' } -ExpectedStatus @(200) | Out-Null
}
Run-Test -Method 'POST' -TemplatePath '/api/auth/change-password' -Url "$base/api/auth/change-password" -Phase 'auth' -Headers $authHeaders -Body @{ currentPassword=$password; newPassword='Password123!Z' } -ExpectedStatus @(200,401) | Out-Null
Run-Test -Method 'POST' -TemplatePath '/api/auth/login-google' -Url "$base/api/auth/login-google" -Phase 'auth' -Body @{ idToken='invalid' } -ExpectedStatus @(400,401) | Out-Null
Run-Test -Method 'POST' -TemplatePath '/api/auth/logout' -Url "$base/api/auth/logout" -Phase 'auth' -Body @{ refreshToken=$authLogin.body.data.refreshToken } -ExpectedStatus @(200) | Out-Null

# Admin: roles/users
$roleName = "SmokeRole$ts"
$createdRole = Run-Test -Method 'POST' -TemplatePath '/api/roles' -Url "$base/api/roles" -Phase 'admin' -Headers $adminHeaders -Body @{ name=$roleName } -ExpectedStatus @(200)
$roleId = $createdRole.body.data.id
Run-Test -Method 'GET' -TemplatePath '/api/roles' -Url "$base/api/roles" -Phase 'admin' -Headers $adminHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'PUT' -TemplatePath '/api/roles/{roleId}' -Url "$base/api/roles/$roleId" -Phase 'admin' -Headers $adminHeaders -Body @{ name="$roleName-upd" } -ExpectedStatus @(200) | Out-Null

$adminCreatedUserEmail = "admin.created.$ts@demo.local"
$adminCreatedUser = Run-Test -Method 'POST' -TemplatePath '/api/users' -Url "$base/api/users" -Phase 'admin' -Headers $adminHeaders -Body @{ fullName='Admin Created'; email=$adminCreatedUserEmail; password='Password123!'; roleId=$annotatorRoleId; status=0; phoneNumber=$null; identifyNumber=$null; gender=$null; address=$null; dateOfBirth=$null } -ExpectedStatus @(200)
$adminCreatedUserId = $adminCreatedUser.body.data.id
Run-Test -Method 'GET' -TemplatePath '/api/users' -Url "$base/api/users" -Phase 'admin' -Headers $adminHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/users/{userId}' -Url "$base/api/users/$adminCreatedUserId" -Phase 'admin' -Headers $adminHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'PUT' -TemplatePath '/api/users/{userId}' -Url "$base/api/users/$adminCreatedUserId" -Phase 'admin' -Headers $adminHeaders -Body @{ fullName='Admin Updated'; email=$adminCreatedUserEmail; password=$null; roleId=$annotatorRoleId; status=1; phoneNumber=$null; identifyNumber=$null; gender=$null; address=$null; dateOfBirth=$null } -ExpectedStatus @(200) | Out-Null

# Manager main flow
$project = Run-Test -Method 'POST' -TemplatePath '/api/manager/projects' -Url "$base/api/manager/projects" -Phase 'manager' -Headers $managerHeaders -Body @{ name="FullSmoke-$ts"; guideline='guideline'; status=0 } -ExpectedStatus @(200)
$projectId = $project.body.data.id
Run-Test -Method 'GET' -TemplatePath '/api/manager/projects' -Url "$base/api/manager/projects" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/manager/projects/{projectId}' -Url "$base/api/manager/projects/$projectId" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'PUT' -TemplatePath '/api/manager/projects/{projectId}' -Url "$base/api/manager/projects/$projectId" -Phase 'manager' -Headers $managerHeaders -Body @{ name="FullSmoke-$ts-upd"; guideline='new'; status=1 } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'PATCH' -TemplatePath '/api/manager/projects/{projectId}/status' -Url "$base/api/manager/projects/$projectId/status" -Phase 'manager' -Headers $managerHeaders -Body @{ name="FullSmoke-$ts-upd"; guideline='new'; status=1 } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'PATCH' -TemplatePath '/api/manager/projects/{projectId}/guideline' -Url "$base/api/manager/projects/$projectId/guideline" -Phase 'manager' -Headers $managerHeaders -Body @{ guideline='updated guideline' } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'POST' -TemplatePath '/api/manager/project-roles' -Url "$base/api/manager/project-roles" -Phase 'manager' -Headers $managerHeaders -Body @{ userId=$reviewerId; projectId=$projectId; roleId=$reviewerRoleId } -ExpectedStatus @(200,400) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/manager/projects/{projectId}/project-roles' -Url "$base/api/manager/projects/$projectId/project-roles" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null

$dataset = Run-Test -Method 'POST' -TemplatePath '/api/manager/datasets' -Url "$base/api/manager/datasets" -Phase 'manager' -Headers $managerHeaders -Body @{ projectId=$projectId; name="Dataset-$ts" } -ExpectedStatus @(200)
$datasetId = $dataset.body.data.id
# Prepare local storage files so ai-suggest can actually read image bytes.
$storageDir = "D:\Data-Labelling-Support-System\backend\storage\full\$ts"
New-Item -ItemType Directory -Path $storageDir -Force | Out-Null
[System.IO.File]::WriteAllBytes((Join-Path $storageDir '1.jpg'), [System.Text.Encoding]::UTF8.GetBytes('mock-image-1'))
[System.IO.File]::WriteAllBytes((Join-Path $storageDir '2.jpg'), [System.Text.Encoding]::UTF8.GetBytes('mock-image-2'))
Run-Test -Method 'GET' -TemplatePath '/api/manager/projects/{projectId}/datasets' -Url "$base/api/manager/projects/$projectId/datasets" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/manager/datasets/{datasetId}' -Url "$base/api/manager/datasets/$datasetId" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'PUT' -TemplatePath '/api/manager/datasets/{datasetId}' -Url "$base/api/manager/datasets/$datasetId" -Phase 'manager' -Headers $managerHeaders -Body @{ name="Dataset-$ts-upd" } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'POST' -TemplatePath '/api/manager/datasets/upload' -Url "$base/api/manager/datasets/upload" -Phase 'manager' -Headers $managerHeaders -Body @{ datasetId=$datasetId; items=@(@{ objectKey="full/$ts/1.jpg"; originalWidth=640; originalHeight=480; dataType='Image'; checksum=$null; storageProvider='Local' }) } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'POST' -TemplatePath '/api/manager/datasets/import-external' -Url "$base/api/manager/datasets/import-external" -Phase 'manager' -Headers $managerHeaders -Body @{ datasetId=$datasetId; sourceName='s3'; items=@(@{ objectKey="full/$ts/2.jpg"; originalWidth=1280; originalHeight=720; dataType='Image'; checksum=$null; storageProvider='Local' }) } -ExpectedStatus @(200) | Out-Null
$version = Run-Test -Method 'POST' -TemplatePath '/api/manager/dataset-versions' -Url "$base/api/manager/dataset-versions" -Phase 'manager' -Headers $managerHeaders -Body @{ datasetId=$datasetId; versionName="v1-$ts" } -ExpectedStatus @(200)
$versionId = $version.body.data.id
Run-Test -Method 'GET' -TemplatePath '/api/manager/datasets/{datasetId}/versions' -Url "$base/api/manager/datasets/$datasetId/versions" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'POST' -TemplatePath '/api/manager/dataset-versions/{versionId}/restore' -Url "$base/api/manager/dataset-versions/$versionId/restore" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200,400) | Out-Null

$cat = Run-Test -Method 'POST' -TemplatePath '/api/manager/label-categories' -Url "$base/api/manager/label-categories" -Phase 'manager' -Headers $managerHeaders -Body @{ projectId=$projectId; name="Category-$ts"; description='d' } -ExpectedStatus @(200)
$categoryId = $cat.body.data.id
$atype = Run-Test -Method 'POST' -TemplatePath '/api/manager/annotation-types' -Url "$base/api/manager/annotation-types" -Phase 'manager' -Headers $managerHeaders -Body @{ projectId=$projectId; name="bbox-$ts"; description='bbox' } -ExpectedStatus @(200)
$annotationTypeId = $atype.body.data.id
$label = Run-Test -Method 'POST' -TemplatePath '/api/manager/labels' -Url "$base/api/manager/labels" -Phase 'manager' -Headers $managerHeaders -Body @{ projectId=$projectId; name="Label-$ts"; yoloClassId=0; categoryId=$categoryId; annotationTypeId=$annotationTypeId } -ExpectedStatus @(200)
$labelId = $label.body.data.id
Run-Test -Method 'GET' -TemplatePath '/api/manager/projects/{projectId}/label-categories' -Url "$base/api/manager/projects/$projectId/label-categories" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/manager/projects/{projectId}/annotation-types' -Url "$base/api/manager/projects/$projectId/annotation-types" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/manager/projects/{projectId}/labels' -Url "$base/api/manager/projects/$projectId/labels" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'PUT' -TemplatePath '/api/manager/label-categories/{categoryId}' -Url "$base/api/manager/label-categories/$categoryId" -Phase 'manager' -Headers $managerHeaders -Body @{ name="Category-$ts-upd"; description='upd' } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'PUT' -TemplatePath '/api/manager/annotation-types/{annotationTypeId}' -Url "$base/api/manager/annotation-types/$annotationTypeId" -Phase 'manager' -Headers $managerHeaders -Body @{ name="bbox-$ts-upd"; description='upd' } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'PUT' -TemplatePath '/api/manager/labels/{labelId}' -Url "$base/api/manager/labels/$labelId" -Phase 'manager' -Headers $managerHeaders -Body @{ name="Label-$ts-upd"; yoloClassId=1; categoryId=$categoryId; annotationTypeId=$annotationTypeId } -ExpectedStatus @(200) | Out-Null

$dataItemId = Safe-Trim (& sqlcmd -S localhost -d DLSS_Db -E -Q "SET NOCOUNT ON; SELECT TOP 1 [_id] FROM [DataItems] WHERE [datasetId]='$datasetId' ORDER BY [createdAt] DESC;" -h -1 -W)
$task = Run-Test -Method 'POST' -TemplatePath '/api/manager/tasks' -Url "$base/api/manager/tasks" -Phase 'manager' -Headers $managerHeaders -Body @{ projectId=$projectId; dataItemId=$dataItemId; annotatorId=$annotatorId } -ExpectedStatus @(200)
$taskId = $task.body.data.id
$task2 = Run-Test -Method 'POST' -TemplatePath '/api/manager/tasks' -Url "$base/api/manager/tasks" -Phase 'manager' -Headers $managerHeaders -Body @{ projectId=$projectId; dataItemId=$dataItemId; annotatorId=$annotatorId } -ExpectedStatus @(200,400)
$task2Id = if($task2.body -and $task2.body.data){$task2.body.data.id}else{$taskId}
Run-Test -Method 'POST' -TemplatePath '/api/manager/tasks/{taskId}/assign' -Url "$base/api/manager/tasks/$taskId/assign" -Phase 'manager' -Headers $managerHeaders -Body @{ annotatorId=$annotatorId } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'POST' -TemplatePath '/api/manager/tasks/bulk-assign' -Url "$base/api/manager/tasks/bulk-assign" -Phase 'manager' -Headers $managerHeaders -Body @{ taskIds=@($taskId); annotatorId=$annotatorId } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'POST' -TemplatePath '/api/manager/tasks/{taskId}/reassign' -Url "$base/api/manager/tasks/$taskId/reassign" -Phase 'manager' -Headers $managerHeaders -Body @{ annotatorId=$annotatorId } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'POST' -TemplatePath '/api/manager/tasks/{taskId}/pause' -Url "$base/api/manager/tasks/$taskId/pause" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'POST' -TemplatePath '/api/manager/tasks/{taskId}/resume' -Url "$base/api/manager/tasks/$taskId/resume" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'POST' -TemplatePath '/api/manager/tasks/{taskId}/relabel' -Url "$base/api/manager/tasks/$taskId/relabel" -Phase 'manager' -Headers $managerHeaders -Body @{ reason='smoke relabel' } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'POST' -TemplatePath '/api/manager/tasks/{taskId}/cancel' -Url "$base/api/manager/tasks/$task2Id/cancel" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200,400) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/manager/tasks/{taskId}/history' -Url "$base/api/manager/tasks/$taskId/history" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/manager/projects/{projectId}/tasks/progress' -Url "$base/api/manager/projects/$projectId/tasks/progress" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null

# Annotator flow on task
Run-Test -Method 'GET' -TemplatePath '/api/annotator/tasks' -Url "$base/api/annotator/tasks" -Phase 'annotator' -Headers $annotatorHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'POST' -TemplatePath '/api/annotator/tasks/{taskId}/start' -Url "$base/api/annotator/tasks/$taskId/start" -Phase 'annotator' -Headers $annotatorHeaders -ExpectedStatus @(200,400) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/annotator/tasks/{taskId}/items' -Url "$base/api/annotator/tasks/$taskId/items" -Phase 'annotator' -Headers $annotatorHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/annotator/tasks/{taskId}/labels' -Url "$base/api/annotator/tasks/$taskId/labels" -Phase 'annotator' -Headers $annotatorHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/annotator/tasks/{taskId}/guideline' -Url "$base/api/annotator/tasks/$taskId/guideline" -Phase 'annotator' -Headers $annotatorHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/annotator/tasks/{taskId}/data-item/content' -Url "$base/api/annotator/tasks/$taskId/data-item/content" -Phase 'annotator' -Headers $annotatorHeaders -ExpectedStatus @(200,404) | Out-Null

$annBody = @{ objects=@(@{ labelId=$labelId; geometryData=@{ x=10; y=20; width=100; height=80 } }); predictionId=$null }
Run-Test -Method 'PUT' -TemplatePath '/api/annotator/tasks/{taskId}/annotations/draft' -Url "$base/api/annotator/tasks/$taskId/annotations/draft" -Phase 'annotator' -Headers $annotatorHeaders -Body $annBody -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/annotator/tasks/{taskId}/annotations' -Url "$base/api/annotator/tasks/$taskId/annotations" -Phase 'annotator' -Headers $annotatorHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'POST' -TemplatePath '/api/annotator/tasks/{taskId}/annotations/submit' -Url "$base/api/annotator/tasks/$taskId/annotations/submit" -Phase 'annotator' -Headers $annotatorHeaders -Body $annBody -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'POST' -TemplatePath '/api/annotator/tasks/{taskId}/ai-suggest' -Url "$base/api/annotator/tasks/$taskId/ai-suggest?apply=false" -Phase 'annotator' -Headers $annotatorHeaders -ExpectedStatus @(200,400,502) | Out-Null

# Reviews + review errors + error type
$annotationSetId = Safe-Trim (& sqlcmd -S localhost -d DLSS_Db -E -Q "SET NOCOUNT ON; SELECT TOP 1 [Id] FROM [AnnotationSets] WHERE [TaskId]='$taskId' ORDER BY [CreatedAt] DESC;" -h -1 -W)
$errorName = "etype-$ts"
Run-Test -Method 'POST' -TemplatePath '/api/error_type' -Url "$base/api/error_type" -Phase 'review' -Headers $reviewerHeaders -Body @{ errorName=$errorName; description='desc' } -ExpectedStatus @(200) | Out-Null
$errorTypeId = Safe-Trim (& sqlcmd -S localhost -d DLSS_Db -E -Q "SET NOCOUNT ON; SELECT TOP 1 [Id] FROM [ErrorTypes] WHERE [ErrorName]='$errorName' ORDER BY [Id] DESC;" -h -1 -W)
Run-Test -Method 'GET' -TemplatePath '/api/error_type' -Url "$base/api/error_type" -Phase 'review' -Headers $reviewerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/error_type/{id}' -Url "$base/api/error_type/$errorTypeId" -Phase 'review' -Headers $reviewerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'PUT' -TemplatePath '/api/error_type' -Url "$base/api/error_type" -Phase 'review' -Headers $reviewerHeaders -Body @{ errorName="$errorName-upd"; description='desc2' } -ExpectedStatus @(200) | Out-Null

Run-Test -Method 'POST' -TemplatePath '/api/reviews' -Url "$base/api/reviews" -Phase 'review' -Headers $reviewerHeaders -Body @{ annotationSetId=$annotationSetId; reviewerId=$reviewerId; result='Approved'; score=95; comment='ok'; reviewedAt=(Get-Date).ToString('o') } -ExpectedStatus @(200) | Out-Null
$reviewId = Safe-Trim (& sqlcmd -S localhost -d DLSS_Db -E -Q "SET NOCOUNT ON; SELECT TOP 1 [Id] FROM [Reviews] WHERE [AnnotationSetId]='$annotationSetId' ORDER BY [ReviewedAt] DESC;" -h -1 -W)
Run-Test -Method 'GET' -TemplatePath '/api/reviews/{id}' -Url "$base/api/reviews/$reviewId" -Phase 'review' -Headers $reviewerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/reviews/reviewer/{id}' -Url "$base/api/reviews/reviewer/$reviewerId" -Phase 'review' -Headers $reviewerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'PUT' -TemplatePath '/api/reviews' -Url "$base/api/reviews" -Phase 'review' -Headers $reviewerHeaders -Body @{ id=$reviewId; result='Approved'; score=96; comment='upd'; reviewedAt=(Get-Date).ToString('o') } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/reviews' -Url "$base/api/reviews" -Phase 'review' -Headers $adminHeaders -ExpectedStatus @(200) | Out-Null

Run-Test -Method 'POST' -TemplatePath '/api/review_errors' -Url "$base/api/review_errors" -Phase 'review' -Headers $reviewerHeaders -Body @{ reviewId=$reviewId; errorTypeId=$errorTypeId } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/review_errors/review/{id}' -Url "$base/api/review_errors/review/$reviewId" -Phase 'review' -Headers $reviewerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/review_errors/type/{id}' -Url "$base/api/review_errors/type/$errorTypeId" -Phase 'review' -Headers $reviewerHeaders -ExpectedStatus @(200,404) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/review_errors' -Url "$base/api/review_errors" -Phase 'review' -Headers $adminHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'DELETE' -TemplatePath '/api/review_errors' -Url "$base/api/review_errors" -Phase 'review' -Headers $reviewerHeaders -Body @{ reviewId=$reviewId; errorTypeId=$errorTypeId } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'DELETE' -TemplatePath '/api/error_type' -Url "$base/api/error_type" -Phase 'review' -Headers $reviewerHeaders -Body $errorTypeId -ExpectedStatus @(200) | Out-Null

# Generic task endpoints
Run-Test -Method 'GET' -TemplatePath '/api/tasks' -Url "$base/api/tasks" -Phase 'task-crud' -Headers $adminHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/tasks/{id}' -Url "$base/api/tasks/$taskId" -Phase 'task-crud' -Headers $adminHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/tasks/submitted' -Url "$base/api/tasks/submitted?id=$taskId" -Phase 'task-crud' -Headers $adminHeaders -ExpectedStatus @(200) | Out-Null
$taskCrudId = New-ObjectIdLike
Run-Test -Method 'POST' -TemplatePath '/api/tasks' -Url "$base/api/tasks" -Phase 'task-crud' -Headers $adminHeaders -Body @{ id=$taskCrudId; projectId=$projectId; dataItemId=$dataItemId; annotatorId=$annotatorId; assignedByUserId=$managerId; status='Assigned'; assignedAt=(Get-Date).ToString('o'); completedAt=$null } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'PUT' -TemplatePath '/api/tasks' -Url "$base/api/tasks" -Phase 'task-crud' -Headers $adminHeaders -Body @{ id=$taskCrudId; projectId=$projectId; dataItemId=$dataItemId; annotatorId=$annotatorId; assignedByUserId=$managerId; status='Submitted'; assignedAt=(Get-Date).ToString('o'); completedAt=(Get-Date).ToString('o') } -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'DELETE' -TemplatePath '/api/tasks' -Url "$base/api/tasks" -Phase 'task-crud' -Headers $adminHeaders -Body $taskCrudId -ExpectedStatus @(200) | Out-Null

# Manager monitoring + export + activity + external export
Run-Test -Method 'GET' -TemplatePath '/api/manager/projects/{projectId}/monitoring/overview' -Url "$base/api/manager/projects/$projectId/monitoring/overview" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/manager/projects/{projectId}/monitoring/annotator-performance' -Url "$base/api/manager/projects/$projectId/monitoring/annotator-performance" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/manager/projects/{projectId}/monitoring/review-stats' -Url "$base/api/manager/projects/$projectId/monitoring/review-stats" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/manager/projects/{projectId}/monitoring/inconsistent-labels' -Url "$base/api/manager/projects/$projectId/monitoring/inconsistent-labels" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/manager/projects/{projectId}/monitoring/quality-report' -Url "$base/api/manager/projects/$projectId/monitoring/quality-report" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/manager/projects/{projectId}/exports/validate' -Url "$base/api/manager/projects/$projectId/exports/validate" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
$export = Run-Test -Method 'POST' -TemplatePath '/api/manager/exports' -Url "$base/api/manager/exports" -Phase 'manager' -Headers $managerHeaders -Body @{ projectId=$projectId; format='json'; exportPath="exports/$projectId/full-$ts.json"; labelFormat='yolo'; includeFields=@('tasks','annotations','reviews','labels'); filters=@{} } -ExpectedStatus @(200)
$exportId = $export.body.data.id
Run-Test -Method 'GET' -TemplatePath '/api/manager/projects/{projectId}/exports' -Url "$base/api/manager/projects/$projectId/exports" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/manager/exports/{exportId}/download' -Url "$base/api/manager/exports/$exportId/download" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/manager/activity-logs' -Url "$base/api/manager/activity-logs?projectId=$projectId" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'GET' -TemplatePath '/api/exports/yolo/tasks/{taskId}' -Url "$base/api/exports/yolo/tasks/$taskId" -Phase 'manager' -Headers $managerHeaders -ExpectedStatus @(200,400) | Out-Null

# Delete endpoints
Run-Test -Method 'DELETE' -TemplatePath '/api/users/{userId}' -Url "$base/api/users/$adminCreatedUserId" -Phase 'cleanup' -Headers $adminHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'DELETE' -TemplatePath '/api/roles/{roleId}' -Url "$base/api/roles/$roleId" -Phase 'cleanup' -Headers $adminHeaders -ExpectedStatus @(200) | Out-Null

# Remove dependent annotation/review rows created in this project so protected deletes can pass.
& sqlcmd -S localhost -d DLSS_Db -E -Q "SET NOCOUNT ON;
DELETE FROM [ReviewErrors]
WHERE [ReviewId] IN (
  SELECT r.[Id]
  FROM [Reviews] r
  INNER JOIN [AnnotationSets] s ON s.[Id] = r.[AnnotationSetId]
  INNER JOIN [tasks] t ON t.[_id] = s.[TaskId]
  WHERE t.[projectId] = '$projectId'
);

DELETE FROM [Reviews]
WHERE [AnnotationSetId] IN (
  SELECT s.[Id]
  FROM [AnnotationSets] s
  INNER JOIN [tasks] t ON t.[_id] = s.[TaskId]
  WHERE t.[projectId] = '$projectId'
);

DELETE FROM [Annotations]
WHERE [annotationSetId] IN (
  SELECT s.[Id]
  FROM [AnnotationSets] s
  INNER JOIN [tasks] t ON t.[_id] = s.[TaskId]
  WHERE t.[projectId] = '$projectId'
);

DELETE FROM [AnnotationSets]
WHERE [TaskId] IN (
  SELECT t.[_id]
  FROM [tasks] t
  WHERE t.[projectId] = '$projectId'
);" -h -1 -W | Out-Null

Run-Test -Method 'DELETE' -TemplatePath '/api/manager/labels/{labelId}' -Url "$base/api/manager/labels/$labelId" -Phase 'cleanup' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'DELETE' -TemplatePath '/api/manager/annotation-types/{annotationTypeId}' -Url "$base/api/manager/annotation-types/$annotationTypeId" -Phase 'cleanup' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'DELETE' -TemplatePath '/api/manager/label-categories/{categoryId}' -Url "$base/api/manager/label-categories/$categoryId" -Phase 'cleanup' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null

$tempProject = Run-Test -Method 'POST' -TemplatePath '/api/manager/projects' -Url "$base/api/manager/projects" -Phase 'cleanup' -Headers $managerHeaders -Body @{ name="TempDelete-$ts"; guideline='tmp'; status=0 } -ExpectedStatus @(200)
$tempProjectId = $tempProject.body.data.id
$tempDataset = Run-Test -Method 'POST' -TemplatePath '/api/manager/datasets' -Url "$base/api/manager/datasets" -Phase 'cleanup' -Headers $managerHeaders -Body @{ projectId=$tempProjectId; name='TempDs' } -ExpectedStatus @(200)
$tempDatasetId = $tempDataset.body.data.id
Run-Test -Method 'POST' -TemplatePath '/api/manager/projects/{projectId}/archive' -Url "$base/api/manager/projects/$tempProjectId/archive" -Phase 'cleanup' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'DELETE' -TemplatePath '/api/manager/datasets/{datasetId}' -Url "$base/api/manager/datasets/$tempDatasetId" -Phase 'cleanup' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null
Run-Test -Method 'DELETE' -TemplatePath '/api/manager/projects/{projectId}' -Url "$base/api/manager/projects/$tempProjectId" -Phase 'cleanup' -Headers $managerHeaders -ExpectedStatus @(200) | Out-Null

# Coverage summary against swagger
$swagger = Get-Content $swaggerPath -Raw | ConvertFrom-Json
$allOps = foreach($p in $swagger.paths.PSObject.Properties){
  foreach($m in $p.Value.PSObject.Properties){
    "{0} {1}" -f $m.Name.ToUpper(), $p.Name
  }
}

$allOpsSet = New-Object 'System.Collections.Generic.HashSet[string]'
foreach($o in $allOps){ [void]$allOpsSet.Add($o) }

$untested = @()
foreach($o in $allOpsSet){ if(-not $testedOps.Contains($o)){ $untested += $o } }

$pass = ($results | Where-Object { $_.Ok }).Count
$total = $results.Count

"RESULT PASS=$pass TOTAL=$total" | Write-Output
"SWAGGER_TOTAL=$($allOpsSet.Count) TESTED=$($testedOps.Count) UNTESTED=$($untested.Count)" | Write-Output
if($untested.Count -gt 0){
  'UNTESTED_ENDPOINTS:' | Write-Output
  $untested | Sort-Object | ForEach-Object { $_ | Write-Output }
}

$results | ConvertTo-Json -Depth 8 | Out-File -FilePath 'D:\Data-Labelling-Support-System\backend\scripts\swagger_full_smoke_result.json' -Encoding utf8
'WROTE backend/scripts/swagger_full_smoke_result.json' | Write-Output
