# 3rd Year Repository – Attendance Logic Module

## Overview

This repository contains the **logic development work assigned to the 3rd Year team** for the Smart Attendance System.

The repository focuses only on attendance workflows and validation rules. UI/UX design, Firebase integration, authentication, database storage, real-time updates, and deployment are outside this repository.

## Responsibilities Covered

The 3rd Year team is responsible for:

- Building application logic and workflows
- Implementing dynamic OTP generation
- Implementing time-bound OTP validation
- Implementing QR code generation and scanning validation logic
- Handling Bluetooth communication validation rules
- Preventing duplicate attendance
- Managing active, expired, and cancelled attendance sessions
- Returning clear attendance acceptance and rejection results

## Core Features

### 1. Dynamic OTP Generation

- Generates a random numeric OTP
- Supports configurable OTP length
- Allows faculty to define OTP validity duration
- Prevents OTP use after expiry

### 2. Time-Bound OTP Validation

The validation workflow checks:

- Whether the attendance session exists
- Whether the session is active
- Whether the OTP is correct
- Whether the OTP is still valid
- Whether the student has already marked attendance
- Whether the maximum number of failed attempts has been exceeded

### 3. QR Code Logic

- Generates a secure QR payload for every attendance session
- Includes a unique session ID
- Includes a random QR token
- Includes the session expiry time
- Rejects invalid, modified, or expired QR data

> In this project, “QR Code Irradiation” refers to QR code generation and display.

### 4. Bluetooth Validation

Bluetooth validation can be enabled for an attendance session.

The logic checks:

- Whether Bluetooth verification is required
- Whether the expected faculty device or beacon is detected
- Whether the Bluetooth observation is recent
- Whether the signal strength meets the configured RSSI threshold
- Whether the student is within the expected proximity range

### 5. Attendance Session Management

Faculty can:

- Generate a new attendance session
- Configure the session validity duration
- Enable or disable Bluetooth validation
- View active sessions
- View expired sessions
- Cancel an active session

### 6. Attendance Validation

A student can submit attendance using:

- OTP
- QR code

Attendance is accepted only after all enabled validation rules pass successfully.

## Repository Structure

```text
lib/
├── logic/
│   └── faculty_attendance_logic.dart
└── demo.dart

test/
└── faculty_attendance_logic_test.dart
```

### File Description

#### `lib/logic/faculty_attendance_logic.dart`

Contains:

- Data models
- OTP generation logic
- QR payload generation and verification
- Bluetooth validation rules
- Attendance session states
- Duplicate attendance checks
- Failed-attempt limits
- Attendance acceptance and rejection results
- Repository interface
- In-memory repository implementation

#### `lib/demo.dart`

Contains a simple demonstration of:

- Creating a faculty attendance session
- Generating an OTP and QR payload
- Submitting a student attendance request
- Validating OTP and Bluetooth proximity
- Displaying the final validation result

#### `test/faculty_attendance_logic_test.dart`

Contains tests for:

- Valid OTP acceptance
- Incorrect OTP rejection
- Expired OTP rejection
- Weak Bluetooth signal rejection
- Duplicate attendance rejection

## Attendance Workflow

```text
Faculty selects course and lecture
              ↓
Faculty selects validity duration
              ↓
Faculty enables Bluetooth validation if required
              ↓
System generates OTP and QR payload
              ↓
Attendance session becomes active
              ↓
Student submits OTP or scans QR code
              ↓
System checks session status and expiry
              ↓
System checks duplicate attendance
              ↓
System verifies OTP or QR payload
              ↓
System verifies Bluetooth proximity if enabled
              ↓
Attendance accepted or rejected
```

## Validation Rules

Attendance is rejected when:

- The session does not exist
- The session has expired
- The faculty has cancelled the session
- The OTP is incorrect
- The QR payload is invalid
- Bluetooth validation is required but unavailable
- The detected Bluetooth device does not match
- The Bluetooth observation is stale
- The Bluetooth signal is too weak
- The student has already marked attendance
- The student has exceeded the maximum number of attempts

## How to Use

Create the repository and logic objects:

```dart
final repository = InMemoryAttendanceSessionRepository();
final logic = FacultyAttendanceLogic(repository);
```

Generate an attendance session:

```dart
final session = await logic.generateAttendanceSession(
  facultyId: 'FAC-101',
  courseId: 'IT-DBMS',
  lectureId: 'LECTURE-01',
  expectedBluetoothDeviceId: 'FACULTY-BEACON-101',
  config: const AttendanceSessionConfig(
    validity: Duration(minutes: 2),
    requireBluetooth: true,
    minimumRssi: -75,
  ),
);
```

Validate student attendance using OTP:

```dart
final result = await logic.validateStudentAttendance(
  sessionId: session.session.id,
  studentId: 'STUDENT-201',
  proof: AttendanceProof.otp(
    otp: session.otp,
    bluetoothObservation: BluetoothObservation(
      advertisedDeviceId: 'FACULTY-BEACON-101',
      rssi: -60,
      observedAt: DateTime.now().toUtc(),
    ),
  ),
);
```

Check the result:

```dart
if (result.accepted) {
  print('Attendance accepted');
} else {
  print(result.message);
}
```

## Running Tests

Inside the Flutter project, run:

```bash
flutter test
```

To run only the attendance logic tests:

```bash
flutter test test/faculty_attendance_logic_test.dart
```

## Current Storage

The repository currently uses:

```dart
InMemoryAttendanceSessionRepository
```

This is suitable for:

- Logic testing
- Demonstrations
- UI integration
- Workflow validation

The data is not permanently stored after the application stops.

## Integration Boundary

This repository does **not** implement:

- Firebase Authentication
- Firestore database
- Cloud Functions
- Real-time updates
- Backend deployment
- Firebase security rules
- Production OTP hashing
- Permanent attendance storage
- UI/UX screens

These components will be integrated separately by the relevant teams.

## Handoff Points

The logic layer exposes:

```dart
abstract class AttendanceSessionRepository
```

A backend repository can implement this interface without changing the main attendance validation workflow.

The UI team can directly connect buttons and forms to:

```dart
generateAttendanceSession()
validateStudentAttendance()
activeSessionsForFaculty()
expiredSessionsForFaculty()
cancelSession()
```

## Security Notes

For production deployment:

- Validate expiry using server time
- Store OTP digests instead of plain OTP values
- Record attendance through a secure transaction
- Protect faculty actions using role-based authentication
- Prevent duplicate attendance on the backend
- Treat client Bluetooth RSSI values as an additional proximity signal, not absolute proof

## 3rd Year Deliverable Summary

This repository delivers the complete application-side logic for:

- OTP generation
- OTP expiry
- QR payload generation
- QR validation
- Bluetooth proximity rules
- Attendance session management
- Duplicate prevention
- Attempt limiting
- Attendance acceptance and rejection workflows
- Unit testing of core validation cases
