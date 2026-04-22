# User Profile
## GET api/user/:username
- No body needed
- Response body:<br>
```json
{
    "profile": {
        "id": "string",
        "email": "string",
        "password": "string",
        "fullname": "string",
        "username": "string",
        "sessionVersion": "int",
        "createdAt": "Datetime",
    },
    "viewerId": "id",
    "profileId": "id",
}
```

## POST api/user/:username
- Update profile
- Request body:<br>
```json
{
    "fullname": "string",
    "username": "string",
}
```
- Response body:<br>
```json
{
    "id": "string",
    "email": "string",
    "password": "string",
    "fullname": "string",
    "username": "string",
    "sessionVersion": "int",
    "createdAt": "Datetime",
}
```

---
# Authentication
## POST api/auth/signup
- Sign up
- Request body:<br>
```json
{
    "email": "string",
    "password": "string",
    "confirmPassword": "string",
    "fullname": "string",
    "username": "string",
}
```

- Response body:<br>
```json
{
    "access_token": "string",
}
```

## POST api/auth/login
- Login to existing account
- Request body:<br>
```json
{
    "email": "string",
    "password": "string",
}
```

- Response body:<br>
```json
{
    "access_token": "string",
}
```

## POST api/auth/reset-password
- Send password reset link to the email in the request body
- Request body:<br>
```json
{
    "email": "string",
}
```

- Response body:<br>
```json
{
    "success_message": "string",
}
```

## GET api/auth/reset-password/token={reset-password-token}
- Send password reset link to the email in the request body. If valid send back the user data
- No request body needed

- Response body:<br>
```json
{
    "id": "string",
    "email": "string",
    "password": "string",
    "fullname": "string",
    "username": "string",
    "sessionVersion": "int",
    "createdAt": "Datetime",
}
```

## PUT api/auth/reset-password
- Send password reset link to the email in the request body
- Request body:<br>
```json
{
    "password": "string",
    "confirmPassword": "string",
    "token": "string",
}
```

- Response body:<br>
```json
{
    "access_token": "string",
}
```

---

# Study Space
## GET api/study-space/:id
- Get a study-space data based on given studySpaceId
- No body needed
- Response body:<br>
```json
{
    "isOwner": "boolean",
    "studySpace": {
        "id": "string",
        "title": "string",
        "userId": "string",
        "createdAt": "Datetime",
    }
}
```

## GET api/study-space/user/:id
- Get all study spaces data of the given user
- No body needed
- Response body:<br>
```json
{
    "isOwner": "boolean",
    "studySpaces": [
        {
            "id": "string",
            "title": "string",
            "userId": "string",
            "createdAt": "Datetime",
        },
        {
            "id": "string",
            "title": "string",
            "userId": "string",
            "createdAt": "Datetime",
        },
        ...
    ]
}
```

## POST api/study-space/add
- Create a study space
- Request body:<br>
```json
{
    "title": "string",
}
```
- Response body:<br>
```json
{
    "id": "string",
    "title": "string",
    "userId": "string",
    "createdAt": "Datetime",
}
```

## POST api/study-space/update
- Update the study space having the id in the request body
- Request body:<br>
```json
{
    "id": "string",
    "title": "string",
}
```
- Response body:<br>
```json
{
    "id": "string",
    "title": "string",
    "userId": "string",
    "createdAt": "Datetime",
}
```

## POST api/study-space/delete
- Delete the study space having the id in the request body
- Request body:<br>
```json
{
    "id": "string",
}
```
- Response body (data of the deleted study space):<br>
```json
{
    "id": "string",
    "title": "string",
    "userId": "string",
    "createdAt": "Datetime",
}
```

---

# File
## GET api/file/:id
- Get a file data and its URL
- No request body needed
- Response body:<br>
```json
{
    "isOwner": "boolean",
    "file": {
        "file": {
            "id": "string",
            "name": "string",
            "mimeType": "string",
            "size": "int",
            "userId": "string",
            "spaceId": "string",
            "createdAt": "Datetime",
        },
        "url": "url",
    }
}
```

## GET api/file/study-space/:id
- Get all uploaded files in a study space given studySpaceId
- No request body needed
- Response body:<br>
```json
{
    "isOwner": "boolean",
    "file": [
        {
            "file": {
                "id": "string",
                "name": "string",
                "mimeType": "string",
                "size": "int",
                "userId": "string",
                "spaceId": "string",
                "createdAt": "Datetime",
            },
            "url": "url",
        },
        {
            "file": {
                "id": "string",
                "name": "string",
                "mimeType": "string",
                "size": "int",
                "userId": "string",
                "spaceId": "string",
                "createdAt": "Datetime",
            },
            "url": "url",
        },
        ...
    ]
}
```

## POST api/file/add-one
- Upload 1 file in multipart/form-data
- curl command for file:<br>
    -F "file=@file.extension"
- Request body:<br>
```json
{
    "studySpaceId": "string",
}
```
- Response body:<br>
```json
{
    "file": {
        "id": "string",
        "name": "string",
        "mimeType": "string",
        "size": "int",
        "userId": "string",
        "spaceId": "string",
        "createdAt": "Datetime",
    },
    "url": "url",
}
```

## POST api/file/add-many
- Upload multiple files in multipart/form-data
- curl command for file:<br>
    -F "file=@file.extension"
    -F "file=@file.extension"
    ...
- Request body:<br>
```json
{
    "studySpaceId": "string",
}
```
- Response body:<br>
```json
[
    {
        "file": {
            "id": "string",
            "name": "string",
            "mimeType": "string",
            "size": "int",
            "userId": "string",
            "spaceId": "string",
            "createdAt": "Datetime",
        },
        "url": "url",
    },
    {
        "file": {
            "id": "string",
            "name": "string",
            "mimeType": "string",
            "size": "int",
            "userId": "string",
            "spaceId": "string",
            "createdAt": "Datetime",
        },
        "url": "string",
    },
    ...
]
```

## POST api/file/update
- Update the file with id given in the body
- Request body:<br>
```json
{
    "id": "string",
    "name": "string",
}
```
- Response body:<br>
```json
{
    "file": {
        "id": "string",
        "name": "string",
        "mimeType": "string",
        "size": "int",
        "userId": "string",
        "spaceId": "string",
        "createdAt": "Datetime",
    },
    "url": "string",
}
```

## POST api/file/delete
- Delete the file with id given in the body
- Request body:<br>
```json
{
    "id": "string",
}
```
- Response body (data of the deleted file):<br>
```json
{
    "id": "string",
    "name": "string",
    "mimeType": "string",
    "size": "int",
    "userId": "string",
    "spaceId": "string",
    "createdAt": "Datetime",
}
```

---

# Image
## GET api/image/:id
- Get a image data and its URL
- No request body needed
- Response body:<br>
```json
{
    "isOwner": "boolean",
    "image": {
        "image": {
            "id": "string",
            "name": "string",
            "mimeType": "string",
            "size": "int",
            "userId": "string",
            "spaceId": "string",
            "createdAt": "Datetime",
        },
        "url": "string",
    }
}
```

## GET api/image/study-space/:id
- Get all uploaded images in a study space given studySpaceId
- No request body needed
- Response body:<br>
```json
{
    "isOwner": "boolean",
    "image": [
        {
            "image": {
                "id": "string",
                "name": "string",
                "mimeType": "string",
                "size": "int",
                "userId": "string",
                "spaceId": "string",
                "createdAt": "Datetime",
            },
            "url": "string",
        },
        {
            "image": {
                "id": "string",
                "name": "string",
                "mimeType": "string",
                "size": "int",
                "userId": "string",
                "spaceId": "string",
                "createdAt": "Datetime",
            },
            "url": "string",
        },
        ...
    ]
}
```

## POST api/image/add-one
- Upload 1 image in multipart/form-data
- curl command for image:<br>
    -F "image=@image.extension"
- Request body:<br>
```json
{
    "studySpaceId": "string",
}
```
- Response body:<br>
```json
{
    "image": {
        "id": "string",
        "name": "string",
        "mimeType": "string",
        "size": "int",
        "userId": "string",
        "spaceId": "string",
        "createdAt": "Datetime",
    },
    "url": "string",
}
```

## POST api/image/add-many
- Upload multiple images in multipart/form-data
- curl command for image:<br>
    -F "image=@image.extension"
    -F "image=@image.extension"
    ...
- Request body:<br>
```json
{
    "studySpaceId": "string",
}
```
- Response body:<br>
```json
[
    {
        "image": {
            "id": "string",
            "name": "string",
            "mimeType": "string",
            "size": "int",
            "userId": "string",
            "spaceId": "string",
            "createdAt": "Datetime",
        },
        "url": "url",
    },
    {
        "image": {
            "id": "string",
            "name": "string",
            "mimeType": "string",
            "size": "int",
            "userId": "string",
            "spaceId": "string",
            "createdAt": "Datetime",
        },
        "url": "string",
    },
    ...
]
```

## POST api/image/update
- Update the image with id given in the body
- Request body:<br>
```json
{
    "id": "string",
    "name": "string",
}
```
- Response body:<br>
```json
{
    "image": {
        "id": "string",
        "name": "string",
        "mimeType": "string",
        "size": "int",
        "userId": "string",
        "spaceId": "string",
        "createdAt": "Datetime",
    },
    "url": "string",
}
```

## POST api/image/delete
- Delete the image with id given in the body
- Request body:<br>
```json
{
    "id": "string",
}
```
- Response body (data of the deleted image):<br>
```json
{
    "id": "string",
    "name": "string",
    "mimeType": "string",
    "size": "string",
    "userId": "string",
    "spaceId": "string",
    "createdAt": "Datetime",
}
```

---

# Note
## GET api/note/:id
- Get the note based on its id
- No request body needed
- Response body:<br>
```json
{
    "note": {
        "id": "string",
        "title": "string",
        "spaceId": "string",
        "userId": "string",
        "content": "json",
        "createdAt": "Datetime",
    },
    "isOwner": "boolean",
}
```

## GET api/note/study-space/:id
- Get the note based on the study space id
- No request body needed
- Response body:<br>
```json
{
    "notes": [
        {
            "id": "string",
            "title": "string",
            "spaceId": "string",
            "userId": "string",
            "content": "json",
            "createdAt": "Datetime",
        },
        {
            "id": "string",
            "title": "string",
            "spaceId": "string",
            "userId": "string",
            "content": "json",
            "createdAt": "Datetime",
        },
        ...
    ],
    "isOwner": "boolean",
}
```

## POST api/note/add
- Create a note
- Request body:<br>
```json
{
    "title": "string",
    "spaceId": "string",
    "content": "json",
}
```

- Response body:<br>
```json
{
    "id": "string",
    "title": "string",
    "spaceId": "string",
    "userId": "string",
    "content": "json",
    "createdAt": "Datetime",
}
```

## POST api/note/update
- Update a note
- Request body:<br>
```json
{
    
    "id": "string",
    "title": "string",
    "content": "json",
}
```

- Response body:<br>
```json
{
    "id": "string",
    "title": "string",
    "spaceId": "string",
    "userId": "string",
    "content": "json",
    "createdAt": "Datetime",
}
```

## POST api/note/delete
- Delete a note based on given id in the request body
- Request body:<br>
```json
{
    "id": "string",
}
```

- Response body (return the data of the deleted note):<br>
```json
{
    "id": "string",
    "title": "string",
    "spaceId": "string",
    "userId": "string",
    "content": "json",
    "createdAt": "Datetime",
}
```