const express = require('express');
const fs = require('fs');
const sql = require('mssql');
const router = express.Router();

const sqlConfig = {
    user: 'dbconnect',
    password: 'Pass@word1',
    database: 'Employees',
    server: 'localhost',
    pool: {
        max: 10,
        min: 0,
        idleTimeoutMillis: 30000
    },
    options: {
        encrypt: false,
        trustServerCertificate: true
    }
};

// Authentication
// Token-based authentication
function tokenAuth(req, res, next) {
    const credentials = getCredentials();
    const token = req.headers['authorization'];

    if (token && token === credentials.validToken) {
        return next();
    }

    return res.status(403).send('Access denied. Invalid token.');
}

// API-Token authentication
function apiTokenAuth(req, res, next) {
    const credentials = getCredentials();
    const token = req.headers['authorization'];

    if (token && token === credentials.apiToken) {
        return next();
    }

    return res.status(403).send('Access denied. Invalid API token.');
}

// Username and Password authentication
function userPassAuth(req, res, next) {
    const credentials = getCredentials();
    const { username, password } = req.body;

    const user = credentials.users.find(u => u.username === username && u.password === password);

    if (user) {
        req.authenticatedUser = user;
        return next();
    }

    return res.status(403).send('Access denied. Invalid username or password.');
}

// Get credentials
function getCredentials() {
    return JSON.parse(fs.readFileSync('credentials.json', 'utf8'));
}

// Retrieve users
function getUsers() {
    return JSON.parse(fs.readFileSync('users.json', 'utf8'));
}

// Write users to file
function saveUsers(users) {
    fs.writeFileSync('users.json', JSON.stringify(users, null, 2));
}

// Retrieve landmarks
function getLandmarks() {
    return JSON.parse(fs.readFileSync('landmarks.json', 'utf8'));
}

// Write landmarks to file
function saveLandmarks(landmarks) {
    fs.writeFileSync('landmarks.json', JSON.stringify(landmarks, null, 2));
}

// Retrieve companies
function getCompanies() {
    return JSON.parse(fs.readFileSync('companies.json', 'utf8'));
}

// Write companies to file
function saveCompanies(companies) {
    fs.writeFileSync('companies.json', JSON.stringify(companies, null, 2));
}

// Retrieve employees
function getEmployees() {
    return JSON.parse(fs.readFileSync('employees.json', 'utf8'));
}

// Generate unique IDs for new users
function generateUserId(users) {
    if (users.length === 0) {
        return "1";
    }
    return (Math.max(...users.map(user => parseInt(user.id))) + 1).toString();
}

// Generate unique IDs for new landmarks
function generateLandmarkId(landmarks) {
    if (landmarks.length === 0) {
        return "1";
    }
    return (Math.max(...landmarks.map(landmark => parseInt(landmark.id))) + 1).toString();
}

// Search companies
function searchCompanies(companies, searchText) {
    return companies.filter(company =>
        Object.values(company).some(value =>
            value.toString().toLowerCase().includes(searchText.toLowerCase())
        ) ||
        Object.values(company.location).some(value =>
            value.toLowerCase().includes(searchText.toLowerCase())
        )
    );
}

// Retrieve employees from database
async function getDatabaseEmployees() {
    try {
        await sql.connect(sqlConfig);
        const result = await sql.query(`SELECT 
        E.EmployeeID AS "@id",
        E.Name AS "name",
        E.Address AS "address",
        E.OfficeLocation AS "officeLocation",
        E.JobTitle AS "jobTitle",
        (
            SELECT CD.Email AS "email", CD.Phone AS "phone"
            FROM ContactDetails CD
            WHERE CD.EmployeeID = E.EmployeeID
            FOR XML PATH('contactDetails'), TYPE
        ),
        (
            SELECT SD.BaseSalary AS "baseSalary", SD.Currency AS "currency", SD.Bonus AS "bonus"
            FROM SalaryDetails SD
            WHERE SD.EmployeeID = E.EmployeeID
            FOR XML PATH('salaryDetails'), TYPE
        )
    FROM Employees E
    FOR XML PATH('employee'), ROOT('employees');    
    `);
        return result.recordset[0]["XML_F52E2B61-18A1-11d1-B105-00805F49916B"];
    } catch (err) {
        console.error(err);
        // Handle errors here
    }
}

// Search employees based on query with partial matching
function searchEmployees(employees, query) {
    return employees.filter(employee =>
        Object.values(employee).some(value =>
            typeof value === 'object' && value !== null ?
                Object.values(value).some(subValue =>
                    subValue.toString().toLowerCase().includes(query.toLowerCase())) :
                value.toString().toLowerCase().includes(query.toLowerCase())
        )
    );
}

// Select specific fields from the employee data, including nested fields
function selectFields(employees, fields) {
    return employees.map(employee => {
        const selected = {};

        fields.forEach(field => {
            const fieldParts = field.split('.');
            let currentObject = employee;

            // Traverse the nested fields
            for (let i = 0; i < fieldParts.length; i++) {
                if (currentObject[fieldParts[i]] !== undefined) {
                    if (i === fieldParts.length - 1) {
                        // Assign the value directly for both top-level and nested fields
                        selected[field] = currentObject[fieldParts[i]];
                    } else {
                        currentObject = currentObject[fieldParts[i]];
                    }
                } else {
                    break; // Break if any part of the path is undefined
                }
            }
        });

        return selected;
    });
}


// Define routes
// User routes
router.get('/users', (req, res) => {
    const users = getUsers();
    res.json(users);
});

router.get('/users/:id', (req, res) => {
    const userId = req.params.id;
    const users = getUsers();
    const user = users.find(u => u.id === userId);

    if (user) {
        res.json(user);
    } else {
        res.status(404).send(`User with ID ${userId} not found`);
    }
});

router.post('/users', (req, res) => {
    if (!req.body) {
        return res.status(400).send('Request body is missing');
    }

    const users = getUsers();
    const newUser = req.body;

    // Validate newUser object structure
    if (!newUser.name || !newUser.email) {
        return res.status(400).send('Name and email are required.');
    }

    // Assign a new unique ID first
    const userId = generateUserId(users);
    const userWithId = { id: userId, ...newUser };

    users.push(userWithId);
    saveUsers(users);
    res.status(201).send(userWithId);
});


router.put('/users/:id', (req, res) => {
    const userId = req.params.id;
    const users = getUsers();
    const index = users.findIndex(u => u.id === userId);

    if (index !== -1) {
        users[index] = { ...users[index], ...req.body };
        saveUsers(users);
        res.send(users[index]);
    } else {
        res.status(404).send(`User with ID ${userId} not found`);
    }
});

router.delete('/users/:id', (req, res) => {
    const userId = req.params.id;
    const users = getUsers();
    const index = users.findIndex(u => u.id === userId);

    if (index !== -1) {
        users.splice(index, 1);
        saveUsers(users);
        res.send(`User with ID ${userId} has been deleted`);
    } else {
        res.status(404).send(`User with ID ${userId} not found`);
    }
});

// Landmark routes
router.get('/landmarks', (req, res) => {
    const landmarks = getLandmarks();
    res.json(landmarks);
});

router.get('/landmarks/:id', (req, res) => {
    const landmarkId = req.params.id;
    const landmarks = getLandmarks();
    const landmark = landmarks.find(l => l.id === landmarkId);

    if (landmark) {
        res.json(landmark);
    } else {
        res.status(404).send(`Landmark with ID ${landmarkId} not found`);
    }
});

router.post('/landmarks', (req, res) => {
    const landmarks = getLandmarks();
    const newLandmark = req.body;

    if (!newLandmark.landmark || !newLandmark.city || !newLandmark.country) {
        return res.status(400).send('Landmark, city, and country are required.');
    }

    newLandmark.id = (landmarks.length + 1).toString(); // Simple ID assignment
    landmarks.push(newLandmark);
    saveLandmarks(landmarks);
    res.status(201).send(newLandmark);
});

router.put('/landmarks/:id', (req, res) => {
    const landmarkId = req.params.id;
    const landmarks = getLandmarks();
    const index = landmarks.findIndex(l => l.id === landmarkId);

    if (index !== -1) {
        landmarks[index] = { ...landmarks[index], ...req.body };
        saveLandmarks(landmarks);
        res.send(landmarks[index]);
    } else {
        res.status(404).send(`Landmark with ID ${landmarkId} not found`);
    }
});

router.delete('/landmarks/:id', (req, res) => {
    const landmarkId = req.params.id;
    const landmarks = getLandmarks();
    const index = landmarks.findIndex(l => l.id === landmarkId);

    if (index !== -1) {
        landmarks.splice(index, 1);
        saveLandmarks(landmarks);
        res.send(`Landmark with ID ${landmarkId} has been deleted`);
    } else {
        res.status(404).send(`Landmark with ID ${landmarkId} not found`);
    }
});

// Company routes
router.get('/companies', (req, res) => {
    const companies = getCompanies();
    const searchText = req.query.search;

    if (searchText) {
        const filteredCompanies = searchCompanies(companies, searchText);
        res.json(filteredCompanies);
    } else {
        res.json(companies);
    }
});

router.get('/companies/:id', (req, res) => {
    const companyId = req.params.id;
    const companies = getCompanies();
    const company = companies.find(c => c.id === companyId);

    if (company) {
        res.json(company);
    } else {
        res.status(404).send(`Company with ID ${companyId} not found`);
    }
});

// Authentication routes
router.get('/tokenAuth', tokenAuth, (req, res) => {
    const employees = getEmployees();
    res.json(employees);
});

router.get('/apiTokenAuth', apiTokenAuth, (req, res) => {
    const employees = getEmployees();
    res.json(employees);
});

router.post('/userPassAuth', userPassAuth, (req, res) => {
    if (req.authenticatedUser) {
        let employees = getEmployees();
        const searchQuery = req.body.search;
        const fields = req.body.fields?.split(',');

        if (searchQuery && searchQuery !== "*") {
            employees = searchEmployees(employees, searchQuery);
        }

        if (fields) {
            employees = selectFields(employees, fields);
        }

        res.json(employees);
    } else {
        res.status(403).send('Unauthorized access.');
    }
});

// Retrieve employees from database
router.get('/employees', async (req, res) => {
    try {
        const employees = await getDatabaseEmployees();
        res.type('application/xml');
        res.setHeader('Content-Type', 'application/xml');
        res.send(employees);
    } catch (err) {
        res.status(500).send('Error retrieving employees');
    }
});

module.exports = router;