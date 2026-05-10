# Layer 2 Test Cases

## Scope
Layer 2 covers the advanced learning features and deeper feature integration of Smart Study Companion. It extends the current testing coverage beyond the initial automated tests and Layer 1 MVP testing.

This scope includes:
- AI Summary
- Flashcards
- Quiz
- Action Plan
- Cross-feature integration
- Negative and edge cases
- Final smoke testing before submission/demo

---

# 1. AI Summary Test Cases

## TC-L2-SUM-001 Generate summary successfully
**Precondition:** User is authenticated and a valid document exists  
**Steps:**
1. Open the uploaded document or study workspace
2. Trigger summary generation
3. Wait for the response  
**Expected Result:**
- Summary is generated successfully
- Summary content is displayed
- Loading state disappears after completion
- App does not crash

## TC-L2-SUM-002 Loading state during summary generation
**Precondition:** Summary request is processing  
**Steps:**
1. Trigger summary generation
2. Observe the UI  
**Expected Result:**
- A loading indicator or loading message is shown
- User can tell the summary is still being generated
- UI remains stable

## TC-L2-SUM-003 Empty summary response
**Precondition:** Backend or AI returns an empty summary  
**Steps:**
1. Trigger summary generation
2. Observe the resulting state  
**Expected Result:**
- App does not crash
- An empty or error state is shown appropriately
- No broken text or placeholder garbage is displayed

## TC-L2-SUM-004 Malformed summary response
**Precondition:** Backend returns invalid or incomplete summary schema  
**Steps:**
1. Trigger summary generation
2. Observe how the app handles malformed data  
**Expected Result:**
- App handles the failure safely
- Error state or fallback state appears
- Layout remains stable

## TC-L2-SUM-005 Summary generation fails
**Precondition:** API/backend/AI request fails  
**Steps:**
1. Trigger summary generation
2. Simulate or observe a failed backend response  
**Expected Result:**
- Error message is displayed
- App does not crash
- UI remains usable

## TC-L2-SUM-006 Retry summary generation after failure
**Precondition:** Summary screen is in an error state  
**Steps:**
1. Tap Retry
2. Wait for the new request to finish  
**Expected Result:**
- App attempts to generate the summary again
- Success transitions to summary content
- Repeated failure keeps a stable error state

## TC-L2-SUM-007 Summary content mapping
**Precondition:** Valid summary data has been returned  
**Steps:**
1. Open the generated summary  
**Expected Result:**
- Summary title is correct
- Summary body text is correct
- Key points are correct
- Reading time or word count, if shown, is reasonable

## TC-L2-SUM-008 Placeholder summary behavior
**Precondition:** App uses a placeholder summary instead of real AI output  
**Steps:**
1. Generate summary
2. Review the placeholder response  
**Expected Result:**
- Placeholder content displays properly
- App remains demo-ready
- UI does not depend too strictly on real AI output

---

# 2. Flashcards Test Cases

## TC-L2-FC-001 Generate flashcards successfully
**Precondition:** Valid uploaded document exists  
**Steps:**
1. Trigger flashcard generation
2. Wait for the result  
**Expected Result:**
- Flashcards are generated successfully
- Flashcard list or card UI appears
- App does not crash

## TC-L2-FC-002 Loading state during flashcard generation
**Steps:**
1. Trigger flashcard generation
2. Observe the UI  
**Expected Result:**
- Loading indicator/message is displayed
- UI stays stable during generation

## TC-L2-FC-003 Empty flashcard set
**Precondition:** Backend returns zero flashcards  
**Steps:**
1. Generate flashcards
2. Observe the result  
**Expected Result:**
- App shows empty state or error state appropriately
- No crash occurs

## TC-L2-FC-004 Malformed flashcard data
**Precondition:** One or more flashcards have missing front/back data  
**Steps:**
1. Load generated flashcards
2. Observe the screen  
**Expected Result:**
- App handles malformed cards safely
- UI remains stable
- Incorrect card data does not break the whole screen

## TC-L2-FC-005 Flashcard front/back display
**Precondition:** Valid flashcards exist  
**Steps:**
1. Open a flashcard
2. View front and back sides  
**Expected Result:**
- Front content is correct
- Back content is correct
- Card interaction behaves properly

## TC-L2-FC-006 Navigate between flashcards
**Precondition:** Multiple flashcards exist  
**Steps:**
1. Move to next card
2. Move back to previous card  
**Expected Result:**
- Navigation is correct
- Card index does not break
- No out-of-range behavior occurs

## TC-L2-FC-007 Mark flashcard correct/incorrect
**Precondition:** Flashcard review tracking exists  
**Steps:**
1. Mark a card as correct
2. Mark a card as incorrect  
**Expected Result:**
- Review or correctness count updates properly
- UI reflects the action correctly

## TC-L2-FC-008 Progress updates after flashcard study
**Precondition:** Flashcard study is connected to progress tracking  
**Steps:**
1. Study multiple flashcards
2. Open the Progress screen  
**Expected Result:**
- Related progress values are updated correctly
- App data remains consistent across screens

## TC-L2-FC-009 Reopen app after flashcard generation
**Precondition:** Flashcards were generated previously  
**Steps:**
1. Close the app
2. Reopen the app
3. Return to the study content  
**Expected Result:**
- Flashcards remain accessible if persistence is supported
- No unexpected data loss occurs

---

# 3. Quiz Test Cases

## TC-L2-QZ-001 Load quiz successfully
**Precondition:** Valid quiz data exists  
**Steps:**
1. Open the quiz feature
2. Wait for data to load  
**Expected Result:**
- Quiz questions appear correctly
- Answer options appear correctly
- UI remains stable

## TC-L2-QZ-002 Loading state while fetching quiz
**Steps:**
1. Open the quiz
2. Observe the loading phase  
**Expected Result:**
- Loading indicator/message appears
- Layout remains stable during loading

## TC-L2-QZ-003 Empty quiz response
**Precondition:** Backend returns an empty quiz  
**Steps:**
1. Open the quiz
2. Observe the result  
**Expected Result:**
- App shows empty state or error state appropriately
- No crash occurs

## TC-L2-QZ-004 Malformed quiz data
**Precondition:** A question has invalid or missing fields  
**Steps:**
1. Load quiz data
2. Observe how the app handles malformed questions  
**Expected Result:**
- App handles the issue safely
- UI remains stable
- One bad question does not destroy the entire screen

## TC-L2-QZ-005 Select answer and submit quiz
**Precondition:** Valid quiz is loaded  
**Steps:**
1. Select one or more answers
2. Submit the quiz  
**Expected Result:**
- Submission succeeds
- Result or score is shown
- App does not crash

## TC-L2-QZ-006 Submit without selecting answer
**Steps:**
1. Open a quiz
2. Submit without choosing an answer  
**Expected Result:**
- App blocks invalid submission or shows validation
- User receives a clear message

## TC-L2-QZ-007 Quiz scoring correctness
**Precondition:** Correct answers are known  
**Steps:**
1. Answer some questions correctly and some incorrectly
2. Submit the quiz  
**Expected Result:**
- Score is calculated correctly
- Result reflects actual answers

## TC-L2-QZ-008 Quiz submission failure
**Precondition:** Backend submit request fails  
**Steps:**
1. Complete the quiz
2. Submit
3. Observe failed response behavior  
**Expected Result:**
- Error state is shown
- UI stays stable
- Retry behavior is possible if supported

## TC-L2-QZ-009 Progress updates after quiz completion
**Precondition:** Quiz completion is wired to progress tracking  
**Steps:**
1. Complete a quiz
2. Open Progress  
**Expected Result:**
- quizzesCompleted updates correctly
- averageScore updates correctly if supported

---

# 4. Action Plan Test Cases

## TC-L2-AP-001 Generate or load action plan successfully
**Precondition:** Valid study context or document exists  
**Steps:**
1. Open or generate the action plan
2. Wait for the result  
**Expected Result:**
- Action plan content appears
- App does not crash
- UI remains stable

## TC-L2-AP-002 Loading state during action plan generation
**Steps:**
1. Trigger action plan generation
2. Observe the UI  
**Expected Result:**
- Loading state appears
- UI remains responsive and stable

## TC-L2-AP-003 Empty action plan response
**Precondition:** Backend returns no action plan content  
**Steps:**
1. Open or generate action plan
2. Observe the resulting state  
**Expected Result:**
- Empty or error state is shown appropriately
- App does not crash

## TC-L2-AP-004 Malformed action plan response
**Precondition:** Returned action plan has invalid or missing data  
**Steps:**
1. Load action plan
2. Observe how the app handles invalid data  
**Expected Result:**
- App handles the response safely
- UI remains stable

## TC-L2-AP-005 Retry action plan after failure
**Precondition:** Action plan screen is in an error state  
**Steps:**
1. Tap Retry
2. Observe the next request  
**Expected Result:**
- App retries successfully if backend responds
- Error state remains stable if request still fails

## TC-L2-AP-006 Placeholder action plan behavior
**Precondition:** App uses placeholder content instead of real AI plan  
**Steps:**
1. Trigger action plan generation
2. Review the displayed content  
**Expected Result:**
- Placeholder renders cleanly
- Flow remains demo-ready
- App still solves the intended user problem at MVP level

---

# 5. Cross-Feature Integration Test Cases

## TC-L2-INT-001 Upload to Summary flow
**Steps:**
1. Upload a document
2. Open that document
3. Generate summary  
**Expected Result:**
- Summary is tied to the correct uploaded document
- No data mix-up occurs

## TC-L2-INT-002 Upload to Flashcards flow
**Steps:**
1. Upload a document
2. Generate flashcards  
**Expected Result:**
- Flashcards belong to the same uploaded document

## TC-L2-INT-003 Upload to Quiz flow
**Steps:**
1. Upload a document
2. Generate or open quiz  
**Expected Result:**
- Quiz belongs to the correct uploaded document

## TC-L2-INT-004 Shared study materials consistency
**Precondition:** One document has summary, flashcards, and quiz generated  
**Steps:**
1. Open summary
2. Open flashcards
3. Open quiz  
**Expected Result:**
- All study materials belong to the same document
- No cross-document mismatch occurs

## TC-L2-INT-005 Study activity updates Progress
**Steps:**
1. Study flashcards or complete a quiz
2. Open the Progress screen  
**Expected Result:**
- Progress updates appropriately if wired
- Data remains consistent across modules

## TC-L2-INT-006 Navigation consistency across Home, Library, and workspace flow
**Steps:**
1. Open content from Home
2. Navigate to Library
3. Return to workspace/study content  
**Expected Result:**
- Navigation remains stable
- Context is preserved correctly

## TC-L2-INT-007 Logout and login again
**Steps:**
1. Login
2. Upload/generate study materials
3. Logout
4. Login again  
**Expected Result:**
- User still accesses their own content
- No data loss or incorrect account mixing occurs

## TC-L2-INT-008 Cached progress when latest progress fails
**Precondition:** Cached progress data exists  
**Steps:**
1. Force a latest progress request failure
2. Open Progress  
**Expected Result:**
- Cached fallback appears
- UI remains usable
- A fallback notice is shown if implemented

---

# 6. Negative and Edge Cases

## TC-L2-NEG-001 Very large PDF upload
**Steps:**
1. Upload a large PDF  
**Expected Result:**
- App handles the file safely
- Clear error or successful handling occurs
- No crash occurs

## TC-L2-NEG-002 Corrupted PDF upload
**Steps:**
1. Upload a corrupted or unreadable PDF  
**Expected Result:**
- App handles the error safely
- User receives a clear message
- No crash occurs

## TC-L2-NEG-003 Network timeout during AI generation
**Steps:**
1. Trigger summary/flashcards/quiz generation
2. Simulate timeout  
**Expected Result:**
- Error state appears
- App remains stable
- Retry is possible if supported

## TC-L2-NEG-004 Duplicate taps on generate action
**Steps:**
1. Tap generate multiple times quickly  
**Expected Result:**
- App prevents duplicated request spam or handles it safely
- UI remains stable

## TC-L2-NEG-005 Empty study content state
**Precondition:** No generated materials exist for a document  
**Steps:**
1. Open the study area  
**Expected Result:**
- App shows an empty state or prompt
- No broken layout occurs

## TC-L2-NEG-006 Token expiration during learning action
**Steps:**
1. Trigger a learning action with an expired session/token  
**Expected Result:**
- App handles auth failure safely
- User receives appropriate auth error handling
- No crash occurs

---

# 7. Final Smoke Test Before Submission

## SMK-L2-001 App launches successfully
## SMK-L2-002 Login works
## SMK-L2-003 Home loads successfully
## SMK-L2-004 Upload document works
## SMK-L2-005 Uploaded document appears in list/library
## SMK-L2-006 Progress tab opens successfully
## SMK-L2-007 Progress screen does not crash
## SMK-L2-008 Summary works or placeholder summary works
## SMK-L2-009 Flashcards load successfully
## SMK-L2-010 Quiz loads and can be submitted
## SMK-L2-011 Profile loads successfully
## SMK-L2-012 Logout works successfully

---

# Notes
- This Layer 2 scope is intended to complete testing coverage for the app’s advanced learning features.
- Some cases may currently be marked as pending if the related feature is still incomplete or unstable.
- Where live AI is not stable, placeholder content/fallback behavior should still be tested as part of MVP validation.
- Final verification of runtime behavior should be done on Mac/Xcode where possible.