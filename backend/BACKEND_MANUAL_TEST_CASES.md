# Backend Manual Test Cases

## Scope
This document covers manual backend testing for the Smart Study Companion backend. It is intended to complement automated backend controller tests and provide a broader testing record for key backend flows.

This scope includes:
- Authentication
- User
- Study Space
- File
- Progress and study-related backend behavior
- Negative and edge cases

---

## Status Key
- **Ready to test now**: endpoint or feature is available and can be tested immediately
- **Partially testable**: endpoint exists but depends on connected modules or environment setup
- **Pending / environment-dependent**: test depends on backend integrations not fully stable in the current environment

---

# 1. Authentication Manual Test Cases
**Status:** Ready to test now

## BE-MAN-AUTH-001 Register with valid data
**Precondition:** Backend is running  
**Steps:**
1. Send a registration request with valid name, email, and password  
**Expected Result:**
- User account is created successfully
- Response returns success payload
- No server error occurs

## BE-MAN-AUTH-002 Register with duplicate email
**Precondition:** A user already exists with the same email  
**Steps:**
1. Send a registration request using the existing email  
**Expected Result:**
- Backend rejects the request
- A clear duplicate-email or conflict response is returned

## BE-MAN-AUTH-003 Login with valid credentials
**Precondition:** Valid user account exists  
**Steps:**
1. Send login request with correct credentials  
**Expected Result:**
- Authentication succeeds
- Token/session payload is returned if applicable

## BE-MAN-AUTH-004 Login with invalid password
**Precondition:** Valid user exists  
**Steps:**
1. Send login request with wrong password  
**Expected Result:**
- Backend rejects login
- Unauthorized or equivalent auth error is returned

## BE-MAN-AUTH-005 Verify token with valid token
**Precondition:** Valid auth token exists  
**Steps:**
1. Send request to token verification / protected auth route  
**Expected Result:**
- Token is accepted
- Protected response or user identity data is returned

## BE-MAN-AUTH-006 Verify token with invalid or expired token
**Steps:**
1. Send protected request with invalid token  
**Expected Result:**
- Backend rejects the request
- Unauthorized response is returned

---

# 2. User Manual Test Cases
**Status:** Ready to test now

## BE-MAN-USER-001 Get current user/profile successfully
**Precondition:** Valid token exists  
**Steps:**
1. Send request to get current user/profile  
**Expected Result:**
- Correct user profile data is returned
- Response format is valid

## BE-MAN-USER-002 Unauthorized user profile access
**Steps:**
1. Send profile request without token  
**Expected Result:**
- Backend rejects the request
- Unauthorized response is returned

## BE-MAN-USER-003 Invalid user context handling
**Precondition:** Invalid or deleted user context  
**Steps:**
1. Trigger profile/user-related request with invalid context  
**Expected Result:**
- Backend handles request safely
- Error response is returned without server crash

---

# 3. Study Space Manual Test Cases
**Status:** Ready to test now

## BE-MAN-STUDY-001 Create study space successfully
**Precondition:** Valid authenticated user  
**Steps:**
1. Send create study space request with valid payload  
**Expected Result:**
- Study space is created successfully
- Response contains created study space data

## BE-MAN-STUDY-002 Get study space list successfully
**Precondition:** One or more study spaces exist  
**Steps:**
1. Send request to list study spaces  
**Expected Result:**
- Backend returns a list of study spaces
- Returned data belongs to the correct user

## BE-MAN-STUDY-003 Get study space by valid id
**Precondition:** Valid study space id exists  
**Steps:**
1. Send request with valid study space id  
**Expected Result:**
- Backend returns correct study space

## BE-MAN-STUDY-004 Get study space with invalid id
**Steps:**
1. Send request using invalid or non-existent study space id  
**Expected Result:**
- Backend returns not found or equivalent error
- No server crash occurs

## BE-MAN-STUDY-005 Unauthorized study space access
**Steps:**
1. Send study space request without auth if route is protected  
**Expected Result:**
- Backend rejects the request
- Unauthorized response is returned

---

# 4. File Manual Test Cases
**Status:** Ready to test now

## BE-MAN-FILE-001 Upload file successfully
**Precondition:** Valid auth context and valid file available  
**Steps:**
1. Upload a supported file  
**Expected Result:**
- Backend stores the file or file metadata successfully
- Success response is returned

## BE-MAN-FILE-002 Upload unsupported or invalid file
**Steps:**
1. Upload invalid file type or malformed request  
**Expected Result:**
- Backend rejects the request
- Clear validation/error response is returned

## BE-MAN-FILE-003 Get uploaded file list
**Precondition:** Uploaded files exist  
**Steps:**
1. Request user file list  
**Expected Result:**
- Backend returns file list successfully
- Files belong to correct user

## BE-MAN-FILE-004 Get file by valid id
**Precondition:** Valid file id exists  
**Steps:**
1. Request specific file by id  
**Expected Result:**
- Correct file metadata/content reference is returned

## BE-MAN-FILE-005 Get file by invalid id
**Steps:**
1. Request file using invalid or missing id  
**Expected Result:**
- Backend returns not found or equivalent error

## BE-MAN-FILE-006 Unauthorized file access
**Steps:**
1. Request file route without valid auth if protected  
**Expected Result:**
- Backend rejects request
- Unauthorized response is returned

---

# 5. Progress and Study Backend Manual Test Cases
**Status:** Partially testable

## BE-MAN-PROG-001 Fetch progress successfully
**Precondition:** Valid user and progress data exist  
**Steps:**
1. Request progress endpoint  
**Expected Result:**
- Correct progress data is returned
- Response schema is valid

## BE-MAN-PROG-002 Fetch progress with invalid PDF or study id
**Steps:**
1. Request progress using invalid id  
**Expected Result:**
- Backend returns not found or equivalent error
- No crash occurs

## BE-MAN-PROG-003 Update progress successfully
**Precondition:** Valid user, valid document/workspace context  
**Steps:**
1. Send update progress request with valid values  
**Expected Result:**
- Progress updates successfully
- Updated values are returned or persisted

## BE-MAN-PROG-004 Invalid progress update payload
**Steps:**
1. Send update request with invalid or missing fields  
**Expected Result:**
- Backend rejects request appropriately
- Clear validation/error response is returned

## BE-MAN-PROG-005 Fetch statistics successfully
**Precondition:** Statistics endpoint exists and data exists  
**Steps:**
1. Request statistics endpoint  
**Expected Result:**
- Daily or summary statistics are returned
- Response structure is usable by frontend

---

# 6. Negative and Edge Cases
**Status:** Partially testable

## BE-MAN-NEG-001 Missing auth token
**Steps:**
1. Send protected request without token  
**Expected Result:**
- Unauthorized response returned

## BE-MAN-NEG-002 Malformed request body
**Steps:**
1. Send invalid JSON or incomplete body  
**Expected Result:**
- Backend handles failure safely
- No crash occurs

## BE-MAN-NEG-003 Very large upload
**Steps:**
1. Upload unusually large file  
**Expected Result:**
- Backend handles file safely or rejects with clear message

## BE-MAN-NEG-004 Invalid route parameter
**Steps:**
1. Send invalid route id or malformed identifier  
**Expected Result:**
- Backend returns safe error response

## BE-MAN-NEG-005 Backend dependency issue
**Precondition:** Database or generated Prisma client issue  
**Steps:**
1. Trigger route requiring backend dependency  
**Expected Result:**
- Failure is handled as safely as possible
- Error is diagnosable
- Server should not fail silently

---

# 7. Manual Backend Smoke Checklist
**Status:** Ready to test now

## BE-SMK-001 Backend starts successfully
## BE-SMK-002 Auth register works
## BE-SMK-003 Auth login works
## BE-SMK-004 User profile route works
## BE-SMK-005 Study space route works
## BE-SMK-006 File route works
## BE-SMK-007 Layer 1 controller tests pass
## BE-SMK-008 Prisma client is generated correctly
## BE-SMK-009 Protected routes reject unauthorized access
## BE-SMK-010 Backend stays stable during common flows

---

# Notes
- These manual cases complement automated backend Layer 1 controller tests.
- Authentication, user, study-space, and file controller tests have already been run successfully in the local backend environment.
- Some progress or study-related backend routes may still depend on broader app integration or partially complete modules.
- Prisma and environment setup should be verified before running backend tests in new environments.