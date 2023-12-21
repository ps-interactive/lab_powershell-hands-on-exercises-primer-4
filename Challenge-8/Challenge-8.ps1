##############################
## Step 1: Define Variables ##
##############################

$apiUrl = "http://localhost:3000/api"

$token = "2XDluXfHvkGwdVkWlxn4FA"
$apiToken = "opbqdPZiNDU2jFVXnybvsvlrtgGiqWSwMkdfqqzyMzCf8YjFC5VTtnncVk9EoesEOCTWOUb0TtHbHwmQIq9jJXfgYS5Zh9B4kzruHPTPUPkMprEwU9MhcNQSdefzx4Nnn1ofeKiGbiG7k9RpCY6K4t6DavS06sbQTBje1Ndevx4x8ZkGGDZZGf4nM5vFBTR79yk1d1NhUQrYn18N8mP0k85cE9nmCuT5yjWr000iXSLnOqyRGbgDwjpoc7mgwTPzdx0bGK2BiJmwK7ntplFykYwO6w8lelmPU7q0Y8U7odCQaTeEBmvB4i5CGPlarmZx"
$username = "user1"
$password = "password1"


###################
## Step 2: Users ##
###################
# Retrieve Users from API
Invoke-RestMethod -Uri "$apiUrl/users" -Method Get

# Retrieve User from API
Invoke-RestMethod -Uri "$apiUrl/users/$username" -Method Get

# Create User
$body = @{
    name = "New User"
    email = "newuser@example.com"
} | ConvertTo-Json
Invoke-RestMethod -Uri "$apiUrl/users" -Method Post -Body $body -ContentType "application/json"

# Update User
$userId = "1"
$body = @{
    name = "Updated Name"
    email = "updatedemail@example.com"
} | ConvertTo-Json
Invoke-RestMethod -Uri "$apiUrl/users/$userId" -Method Put -Body $body -ContentType "application/json"

# Delete User
$userId = "1"
Invoke-RestMethod -Uri "$apiUrl/users/$userId" -Method Delete


#######################
## Step 3: Landmarks ##
#######################
# Retrieve Landmarks from API
Invoke-RestMethod -Uri "$apiUrl/landmarks" -Method Get

# Retrieve Landmark from API
Invoke-RestMethod -Uri "$apiUrl/landmarks/1" -Method Get

# Create Landmark
$body = @{
    name = "New Landmark"
    description = "New Landmark Description"
    latitude = "1.2345"
    longitude = "1.2345"
} | ConvertTo-Json
Invoke-RestMethod -Uri "$apiUrl/landmarks" -Method Post -Body $body -ContentType "application/json"

# Update Landmark
$landmarkId = "1"
$body = @{
    name = "Updated Landmark"
    description = "Updated Landmark Description"
    latitude = "1.2345"
    longitude = "1.2345"
} | ConvertTo-Json
Invoke-RestMethod -Uri "$apiUrl/landmarks/$landmarkId" -Method Put -Body $body -ContentType "application/json"

# Delete Landmark
$landmarkId = "1"
Invoke-RestMethod -Uri "$apiUrl/landmarks/$landmarkId" -Method Delete



#######################
## Step 4: Companies ##
#######################
# Retrieve Companies from API
Invoke-RestMethod -Uri "$apiUrl/companies" -Method Get

# Retrieve Company from API
Invoke-RestMethod -Uri "$apiUrl/companies/1" -Method Get

# Create Company
$body = @{
    name = "New Company"
    description = "New Company Description"
    latitude = "1.2345"
    longitude = "1.2345"
} | ConvertTo-Json
Invoke-RestMethod -Uri "$apiUrl/companies" -Method Post -Body $body -ContentType "application/json"

# Update Company
$companyId = "1"
$body = @{
    name = "Updated Company"
    description = "Updated Company Description"
    latitude = "1.2345"
    longitude = "1.2345"
} | ConvertTo-Json
Invoke-RestMethod -Uri "$apiUrl/companies/$companyId" -Method Put -Body $body -ContentType "application/json"

# Delete Company
$companyId = "1"
Invoke-RestMethod -Uri "$apiUrl/companies/$companyId" -Method Delete


############################
## Step 5: Authentication ##
############################

# Login and Return Employees using Token
$headers = @{ Authorization = $token }
Invoke-RestMethod -Uri "$apiUrl/tokenAuth" -Method Get -Headers $headers

# Login and Return Employees using API Token
$headers = @{ Authorization = $apiToken }
Invoke-RestMethod -Uri "$apiUrl/apiTokenAuth" -Method Get -Headers $headers

# Login and Return Employees using Credentials
$body = @{
    username = $username
    password = $password
    search = "Wil"
    fields = "name,contactDetails.email,salaryDetails.baseSalary,address,jobTitle"
} | ConvertTo-Json
Invoke-RestMethod -Uri "$apiUrl/userPassAuth" -Method Post -Body $body -ContentType "application/json"















