# Smart Study Companion API Contract

Base URL for local development:

```text
http://localhost:1234
```

Most protected endpoints require a JWT access token:

```http
Authorization: Bearer <access_token>
```

All JSON requests should use:

```http
Content-Type: application/json
```

Upload endpoints use `multipart/form-data`.

Dates are returned as ISO date strings. IDs are UUID strings. JWT access tokens are currently issued without an expiry claim, but they can still be invalidated by `sessionVersion` changes such as password reset.

**Common Models**

```json
{
  "User": {
    "id": "string",
    "email": "string",
    "password": "string",
    "fullname": "string",
    "username": "string",
    "sessionVersion": 1,
    "createdAt": "2026-05-02T00:00:00.000Z"
  },
  "StudySpace": {
    "id": "string",
    "title": "string",
    "userId": "string",
    "color": "#3B82F6",
    "tag": "biology",
    "summaries": ["StudySpaceSummary"],
    "createdAt": "2026-05-02T00:00:00.000Z"
  },
  "StudySpaceSummary": {
    "id": "string",
    "studySpaceId": "string",
    "userId": "string",
    "title": "Lecture set summary",
    "content": {
      "overview": "string",
      "keyConcepts": ["string"],
      "importantDetails": ["string"]
    },
    "files": [
      {
        "id": "string",
        "summaryId": "string",
        "fileId": "string",
        "createdAt": "2026-05-02T00:00:00.000Z",
        "file": "File"
      }
    ],
    "createdAt": "2026-05-02T00:00:00.000Z",
    "updatedAt": "2026-05-02T00:00:00.000Z"
  },
  "File": {
    "id": "string",
    "name": "lecture.pdf",
    "mimeType": "application/pdf",
    "size": 12345,
    "userId": "string",
    "spaceId": "string",
    "createdAt": "2026-05-02T00:00:00.000Z"
  },
  "Image": {
    "id": "string",
    "name": "diagram.png",
    "mimeType": "image/png",
    "size": 12345,
    "userId": "string",
    "spaceId": "string",
    "createdAt": "2026-05-02T00:00:00.000Z"
  },
  "Note": {
    "id": "string",
    "title": "Week 1",
    "spaceId": "string",
    "userId": "string",
    "content": {},
    "createdAt": "2026-05-02T00:00:00.000Z"
  },
  "Message": {
    "id": "string",
    "chatHistoryId": "string",
    "role": "user",
    "content": "string",
    "metadata": null,
    "createdAt": "2026-05-02T00:00:00.000Z"
  }
}
```

---

## Health

### `GET /`

Returns the app service hello string.

Auth: none

Response:

```text
Hello World!
```

---

## Authentication

### `POST /api/auth/signup`

Create a new user account.

Auth: none

Request:

```json
{
  "email": "user@example.com",
  "password": "password123",
  "confirmPassword": "password123",
  "fullname": "Jane Doe",
  "username": "jane"
}
```

Response:

```json
{
  "access_token": "jwt_token"
}
```

### `POST /api/auth/login`

Login with an existing account.

Auth: none

Request:

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

Response:

```json
{
  "access_token": "jwt_token"
}
```

### `POST /api/auth/reset-password`

Send a password reset token/link to the user's email.

Auth: none

Request:

```json
{
  "email": "user@example.com"
}
```

Response:

```json
{
  "success_message": "The password reset link has been sent to your email"
}
```

### `GET /api/auth/reset-password?token=<reset-token>`

Validate a password reset token. If valid, returns the user associated with the token.

Auth: none

Response:

```json
{
  "id": "string",
  "email": "user@example.com",
  "password": "hashed_password",
  "fullname": "Jane Doe",
  "username": "jane",
  "sessionVersion": 1,
  "createdAt": "2026-05-02T00:00:00.000Z"
}
```

### `PUT /api/auth/reset-password`

Reset the password with a valid reset token. Returns a new access token.

Auth: none

Request:

```json
{
  "password": "newPassword123",
  "confirmPassword": "newPassword123",
  "token": "reset_token"
}
```

Response:

```json
{
  "access_token": "jwt_token"
}
```

---

## User

### `GET /api/user/:username`

Get a public user profile. If a bearer token is included, `viewerId` is populated.

Auth: optional

Response:

```json
{
  "profile": {
    "id": "string",
    "email": "user@example.com",
    "password": "hashed_password",
    "fullname": "Jane Doe",
    "username": "jane",
    "sessionVersion": 1,
    "createdAt": "2026-05-02T00:00:00.000Z"
  },
  "viewerId": "string",
  "profileId": "string"
}
```

### `POST /api/user/:username`

Update the authenticated user's own profile.

Auth: required

Request:

```json
{
  "fullname": "Jane Smith",
  "username": "jane_smith"
}
```

Response:

```json
{
  "id": "string",
  "email": "user@example.com",
  "password": "hashed_password",
  "fullname": "Jane Smith",
  "username": "jane_smith",
  "sessionVersion": 1,
  "createdAt": "2026-05-02T00:00:00.000Z"
}
```

---

## Study Space

### `GET /api/study-space/:id`

Get one study space by ID.

Auth: required

Response:

```json
{
  "isOwner": true,
  "studySpace": {
    "id": "string",
    "title": "Biology",
    "userId": "string",
    "color": "#22C55E",
    "tag": "science",
    "summaries": [],
    "createdAt": "2026-05-02T00:00:00.000Z"
  }
}
```

### `GET /api/study-space/user/:id`

Get all study spaces for a user ID.

Auth: required

Response:

```json
{
  "isOwner": true,
  "studySpaces": [
    {
      "id": "string",
      "title": "Biology",
      "userId": "string",
      "color": "#22C55E",
      "tag": "science",
      "summaries": [],
      "createdAt": "2026-05-02T00:00:00.000Z"
    }
  ]
}
```

### `POST /api/study-space/add`

Create a study space.

Auth: required

Request:

```json
{
  "title": "Biology",
  "color": "#22C55E",
  "tag": "science"
}
```

Response:

```json
{
  "id": "string",
  "title": "Biology",
  "userId": "string",
  "color": "#22C55E",
  "tag": "science",
  "createdAt": "2026-05-02T00:00:00.000Z"
}
```

### `POST /api/study-space/update`

Update a study space. `title`, `color`, and `tag` are optional.

Auth: required

Request:

```json
{
  "id": "study_space_id",
  "title": "Advanced Biology",
  "color": "#16A34A",
  "tag": "exam"
}
```

Response:

```json
{
  "id": "string",
  "title": "Advanced Biology",
  "userId": "string",
  "color": "#16A34A",
  "tag": "exam",
  "createdAt": "2026-05-02T00:00:00.000Z"
}
```

### `POST /api/study-space/delete`

Delete a study space.

Auth: required

Request:

```json
{
  "id": "study_space_id"
}
```

Response:

```json
{
  "id": "string",
  "title": "Advanced Biology",
  "userId": "string",
  "color": "#16A34A",
  "tag": "exam",
  "createdAt": "2026-05-02T00:00:00.000Z"
}
```

---

## Notes

### `GET /api/note/:id`

Get one note by note ID.

Auth: required

Response:

```json
{
  "note": {
    "id": "string",
    "title": "Week 1",
    "spaceId": "string",
    "userId": "string",
    "content": {},
    "createdAt": "2026-05-02T00:00:00.000Z"
  },
  "isOwner": true
}
```

### `GET /api/note/study-space/:id`

Get notes in a study space.

Auth: required

Response:

```json
{
  "notes": [
    {
      "id": "string",
      "title": "Week 1",
      "spaceId": "string",
      "userId": "string",
      "content": {},
      "createdAt": "2026-05-02T00:00:00.000Z"
    }
  ],
  "isOwner": true
}
```

### `POST /api/note/add`

Create a note.

Auth: required

Request:

```json
{
  "title": "Week 1",
  "spaceId": "study_space_id",
  "content": {
    "blocks": []
  }
}
```

Response:

```json
{
  "id": "string",
  "title": "Week 1",
  "spaceId": "string",
  "userId": "string",
  "content": {
    "blocks": []
  },
  "createdAt": "2026-05-02T00:00:00.000Z"
}
```

### `POST /api/note/update`

Update a note. `title` and `content` are optional.

Auth: required

Request:

```json
{
  "id": "note_id",
  "title": "Week 1 Updated",
  "content": {
    "blocks": []
  }
}
```

Response:

```json
{
  "id": "string",
  "title": "Week 1 Updated",
  "spaceId": "string",
  "userId": "string",
  "content": {
    "blocks": []
  },
  "createdAt": "2026-05-02T00:00:00.000Z"
}
```

### `POST /api/note/delete`

Delete a note.

Auth: required

Request:

```json
{
  "id": "note_id"
}
```

Response:

```json
{
  "id": "string",
  "title": "Week 1 Updated",
  "spaceId": "string",
  "userId": "string",
  "content": {},
  "createdAt": "2026-05-02T00:00:00.000Z"
}
```

---

## Files

When a text-readable file or PDF is uploaded, the backend also chunks the text and creates embeddings for retrieval chat. The upload response includes `embeddingResult`.

### `GET /api/file/:id`

Get one file and its storage URL/path.

Auth: required

Response:

```json
{
  "isOwner": true,
  "file": {
    "file": {
      "id": "string",
      "name": "lecture.pdf",
      "mimeType": "application/pdf",
      "size": 12345,
      "userId": "string",
      "spaceId": "string",
      "createdAt": "2026-05-02T00:00:00.000Z"
    },
    "url": "storage/path/lecture.pdf"
  }
}
```

### `GET /api/file/study-space/:id`

Get all files in a study space.

Auth: required

Response:

```json
{
  "isOwner": true,
  "files": [
    {
      "file": {
        "id": "string",
        "name": "lecture.pdf",
        "mimeType": "application/pdf",
        "size": 12345,
        "userId": "string",
        "spaceId": "string",
        "createdAt": "2026-05-02T00:00:00.000Z"
      },
      "url": "storage/path/lecture.pdf"
    }
  ]
}
```

### `POST /api/file/add-one`

Upload one file.

Auth: required

Content type: `multipart/form-data`

Form fields:

```text
file=<binary file>
studySpaceId=study_space_id
```

cURL:

```bash
curl -X POST http://localhost:1234/api/file/add-one \
  -H "Authorization: Bearer <access_token>" \
  -F "file=@lecture.pdf" \
  -F "studySpaceId=study_space_id"
```

Response:

```json
{
  "file": {
    "id": "string",
    "name": "lecture.pdf",
    "mimeType": "application/pdf",
    "size": 12345,
    "userId": "string",
    "spaceId": "string",
    "createdAt": "2026-05-02T00:00:00.000Z"
  },
  "url": "storage/path/lecture.pdf",
  "embeddingResult": {
    "chunksCreated": 12,
    "embeddingsCreated": 12,
    "skipped": false
  }
}
```

If the file is unsupported for text extraction:

```json
{
  "embeddingResult": {
    "chunksCreated": 0,
    "embeddingsCreated": 0,
    "skipped": true,
    "reason": "File type is not text-convertible or no text content was found"
  }
}
```

### `POST /api/file/add-many`

Upload multiple files.

Auth: required

Content type: `multipart/form-data`

Form fields:

```text
files=<binary file>
files=<binary file>
studySpaceId=study_space_id
```

cURL:

```bash
curl -X POST http://localhost:1234/api/file/add-many \
  -H "Authorization: Bearer <access_token>" \
  -F "files=@lecture1.pdf" \
  -F "files=@lecture2.txt" \
  -F "studySpaceId=study_space_id"
```

Response:

```json
[
  {
    "file": {
      "id": "string",
      "name": "lecture1.pdf",
      "mimeType": "application/pdf",
      "size": 12345,
      "userId": "string",
      "spaceId": "string",
      "createdAt": "2026-05-02T00:00:00.000Z"
    },
    "url": "storage/path/lecture1.pdf",
    "embeddingResult": {
      "chunksCreated": 12,
      "embeddingsCreated": 12,
      "skipped": false
    }
  }
]
```

### `POST /api/file/update`

Rename a file. The original extension is preserved if the new name does not include it.

Auth: required

Request:

```json
{
  "id": "file_id",
  "name": "renamed-lecture"
}
```

Response:

```json
{
  "file": {
    "id": "string",
    "name": "renamed-lecture.pdf",
    "mimeType": "application/pdf",
    "size": 12345,
    "userId": "string",
    "spaceId": "string",
    "createdAt": "2026-05-02T00:00:00.000Z"
  },
  "url": "storage/path/renamed-lecture.pdf"
}
```

### `POST /api/file/delete`

Delete a file.

Auth: required

Request:

```json
{
  "id": "file_id"
}
```

Response:

```json
{
  "id": "string",
  "name": "lecture.pdf",
  "mimeType": "application/pdf",
  "size": 12345,
  "userId": "string",
  "spaceId": "string",
  "createdAt": "2026-05-02T00:00:00.000Z"
}
```

---

## Images

### `GET /api/image/:id`

Get one image and its storage URL/path.

Auth: required

Response:

```json
{
  "isOwner": true,
  "image": {
    "image": {
      "id": "string",
      "name": "diagram.png",
      "mimeType": "image/png",
      "size": 12345,
      "userId": "string",
      "spaceId": "string",
      "createdAt": "2026-05-02T00:00:00.000Z"
    },
    "url": "storage/path/diagram.png"
  }
}
```

### `GET /api/image/study-space/:id`

Get all images in a study space.

Auth: required

Response:

```json
{
  "isOwner": true,
  "images": [
    {
      "image": {
        "id": "string",
        "name": "diagram.png",
        "mimeType": "image/png",
        "size": 12345,
        "userId": "string",
        "spaceId": "string",
        "createdAt": "2026-05-02T00:00:00.000Z"
      },
      "url": "storage/path/diagram.png"
    }
  ]
}
```

### `POST /api/image/add-one`

Upload one image.

Auth: required

Content type: `multipart/form-data`

Form fields:

```text
image=<binary image>
studySpaceId=study_space_id
```

cURL:

```bash
curl -X POST http://localhost:1234/api/image/add-one \
  -H "Authorization: Bearer <access_token>" \
  -F "image=@diagram.png" \
  -F "studySpaceId=study_space_id"
```

Response:

```json
{
  "image": {
    "id": "string",
    "name": "diagram.png",
    "mimeType": "image/png",
    "size": 12345,
    "userId": "string",
    "spaceId": "string",
    "createdAt": "2026-05-02T00:00:00.000Z"
  },
  "url": "storage/path/diagram.png"
}
```

### `POST /api/image/add-many`

Upload multiple images.

Auth: required

Content type: `multipart/form-data`

Form fields:

```text
images=<binary image>
images=<binary image>
studySpaceId=study_space_id
```

cURL:

```bash
curl -X POST http://localhost:1234/api/image/add-many \
  -H "Authorization: Bearer <access_token>" \
  -F "images=@diagram1.png" \
  -F "images=@diagram2.jpg" \
  -F "studySpaceId=study_space_id"
```

Response:

```json
[
  {
    "image": {
      "id": "string",
      "name": "diagram1.png",
      "mimeType": "image/png",
      "size": 12345,
      "userId": "string",
      "spaceId": "string",
      "createdAt": "2026-05-02T00:00:00.000Z"
    },
    "url": "storage/path/diagram1.png"
  }
]
```

### `POST /api/image/update`

Rename an image. The original extension is preserved if the new name does not include it.

Auth: required

Request:

```json
{
  "id": "image_id",
  "name": "renamed-diagram"
}
```

Response:

```json
{
  "image": {
    "id": "string",
    "name": "renamed-diagram.png",
    "mimeType": "image/png",
    "size": 12345,
    "userId": "string",
    "spaceId": "string",
    "createdAt": "2026-05-02T00:00:00.000Z"
  },
  "url": "storage/path/renamed-diagram.png"
}
```

### `POST /api/image/delete`

Delete an image.

Auth: required

Request:

```json
{
  "id": "image_id"
}
```

Response:

```json
{
  "id": "string",
  "name": "diagram.png",
  "mimeType": "image/png",
  "size": 12345,
  "userId": "string",
  "spaceId": "string",
  "createdAt": "2026-05-02T00:00:00.000Z"
}
```

---

## AI

### `POST /api/ai/study-space/:id/summary`

Create a new summary for selected files in a study space. Each call creates a separate `StudySpaceSummary`, so one study space can have multiple summaries.

Auth: required

Request:

```json
{
  "fileIds": ["file_id_1", "file_id_2"],
  "title": "Optional summary title"
}
```

Notes:

- `fileIds` is required and must contain at least one file ID.
- Every selected file must belong to the study space in the URL.
- The summary uses selected files only. Images are not included by this endpoint.
- If `title` is omitted, the backend creates one from the selected file names.

Response:

```json
{
  "summary": {
    "id": "string",
    "studySpaceId": "string",
    "userId": "string",
    "title": "Optional summary title",
    "content": {
      "overview": "One paragraph overview.",
      "keyConcepts": ["concept 1", "concept 2"],
      "importantDetails": ["detail 1", "detail 2"]
    },
    "createdAt": "2026-05-02T00:00:00.000Z",
    "updatedAt": "2026-05-02T00:00:00.000Z",
    "files": [
      {
        "id": "string",
        "summaryId": "string",
        "fileId": "file_id_1",
        "createdAt": "2026-05-02T00:00:00.000Z",
        "file": {
          "id": "file_id_1",
          "name": "lecture.pdf",
          "mimeType": "application/pdf",
          "size": 12345,
          "userId": "string",
          "spaceId": "string",
          "createdAt": "2026-05-02T00:00:00.000Z"
        }
      }
    ]
  }
}
```

### `GET /api/ai/study-space/:id/summaries`

List all summaries for a study space, newest first.

Auth: required

Response:

```json
[
  {
    "id": "string",
    "studySpaceId": "string",
    "userId": "string",
    "title": "Lecture set summary",
    "content": {
      "overview": "One paragraph overview.",
      "keyConcepts": ["concept 1", "concept 2"],
      "importantDetails": ["detail 1", "detail 2"]
    },
    "createdAt": "2026-05-02T00:00:00.000Z",
    "updatedAt": "2026-05-02T00:00:00.000Z",
    "files": [
      {
        "id": "string",
        "summaryId": "string",
        "fileId": "file_id_1",
        "createdAt": "2026-05-02T00:00:00.000Z",
        "file": {
          "id": "file_id_1",
          "name": "lecture.pdf",
          "mimeType": "application/pdf",
          "size": 12345,
          "userId": "string",
          "spaceId": "string",
          "createdAt": "2026-05-02T00:00:00.000Z"
        }
      }
    ]
  }
]
```

### `GET /api/ai/summary/:id`

Get one saved study-space summary by summary ID.

Auth: required

Response:

```json
{
  "id": "string",
  "studySpaceId": "string",
  "userId": "string",
  "title": "Lecture set summary",
  "content": {
    "overview": "One paragraph overview.",
    "keyConcepts": ["concept 1", "concept 2"],
    "importantDetails": ["detail 1", "detail 2"]
  },
  "createdAt": "2026-05-02T00:00:00.000Z",
  "updatedAt": "2026-05-02T00:00:00.000Z",
  "files": [
    {
      "id": "string",
      "summaryId": "string",
      "fileId": "file_id_1",
      "createdAt": "2026-05-02T00:00:00.000Z",
      "file": {
        "id": "file_id_1",
        "name": "lecture.pdf",
        "mimeType": "application/pdf",
        "size": 12345,
        "userId": "string",
        "spaceId": "string",
        "createdAt": "2026-05-02T00:00:00.000Z"
      }
    }
  ]
}
```

### `POST /api/ai/study-space/:id/chat`

Ask a question about uploaded study-space files. The backend embeds the prompt, retrieves relevant chunks, boosts matching filenames, generates an answer, and stores both the user message and assistant response.

Auth: required

Request:

```json
{
  "prompt": "Explain photosynthesis from lecture1.pdf",
  "chatHistoryId": "optional_existing_chat_history_id",
  "title": "optional title for a new chat"
}
```

Notes:

- If `chatHistoryId` is omitted, a new chat history is created.
- If file names are included in `prompt`, chunks from files with matching names/tokens receive a relevance boost.
- Chat summaries are updated every 10 stored messages and are used as context with unsummarized recent messages.

Response:

```json
{
  "chatHistoryId": "string",
  "messages": [
    {
      "id": "string",
      "chatHistoryId": "string",
      "role": "user",
      "content": "Explain photosynthesis from lecture1.pdf",
      "metadata": null,
      "createdAt": "2026-05-02T00:00:00.000Z"
    },
    {
      "id": "string",
      "chatHistoryId": "string",
      "role": "assistant",
      "content": "Photosynthesis is...",
      "metadata": {
        "sources": [
          {
            "chunkId": "string",
            "fileId": "string",
            "fileName": "lecture1.pdf",
            "chunkIndex": 3,
            "score": 0.91
          }
        ]
      },
      "createdAt": "2026-05-02T00:00:00.000Z"
    }
  ],
  "sources": [
    {
      "chunkId": "string",
      "fileId": "string",
      "fileName": "lecture1.pdf",
      "chunkIndex": 3,
      "score": 0.91
    }
  ]
}
```

### `GET /api/ai/chat-history/:id`

Get a full chat history with all messages in chronological order.

Auth: required

Response:

```json
{
  "id": "string",
  "studySpaceId": "string",
  "userId": "string",
  "title": "Biology questions",
  "createdAt": "2026-05-02T00:00:00.000Z",
  "updatedAt": "2026-05-02T00:00:00.000Z",
  "messages": [
    {
      "id": "string",
      "chatHistoryId": "string",
      "role": "user",
      "content": "string",
      "metadata": null,
      "createdAt": "2026-05-02T00:00:00.000Z"
    }
  ]
}
```

### `GET /api/ai/chat-history/:id/messages`

Get chat messages page-by-page. By default, returns the 10 most recent messages.

Auth: required

Query params:

- `limit`: optional. Defaults to `10`. Max `50`.
- `beforeMessageId`: optional. Use `nextBeforeMessageId` from the previous response to load older messages.

Examples:

```http
GET /api/ai/chat-history/chat_id/messages
GET /api/ai/chat-history/chat_id/messages?limit=10&beforeMessageId=message_id
```

Response:

```json
{
  "chatHistoryId": "string",
  "messages": [
    {
      "id": "string",
      "chatHistoryId": "string",
      "role": "user",
      "content": "string",
      "metadata": null,
      "createdAt": "2026-05-02T00:00:00.000Z"
    }
  ],
  "hasMore": true,
  "nextBeforeMessageId": "oldest_message_id_in_this_page"
}
```

The `messages` array is returned in chronological order so the frontend can append it directly to a chat box. When `hasMore` is `false`, there are no older messages to load.

