#include <ArduinoBLE.h>
#include <Arduino_LSM9DS1.h>  // Include the IMU library

#define BUFFER_SIZE 20

BLEService repService("00000000-5EC4-4083-81CD-A10B8D5CF6EC");  // Service for rep counting
BLECharacteristic repCharacteristic("00000001-5EC4-4083-81CD-A10B8D5CF6EC", BLERead | BLENotify, BUFFER_SIZE, false);

float x, y, z;
int bicepRepCount = 0;
bool inBicepRep = false;
const float bicepRepThreshold = 0.4;
int shoulderRepCount = 0;
bool inShoulderRep = false;
const float shoulderUpThreshold = -0.5;  // Threshold when moving up
const float shoulderDownThreshold = -1.1;  // Threshold when moving down
int leftLateralRepCount = 0;
bool inLeftLateralRep = false;
const float lateralUpThreshold = 0.5;  // Threshold when moving arms up to the side
const float lateralDownThreshold = 0.1;

enum ExerciseType { NONE, BICEP, SHOULDER, LATERAL };
ExerciseType currentExercise = NONE;
unsigned long lastActivityTime = 0;
const unsigned long inactivityThreshold = 2000; // 2 seconds

void setup() {
  // Serial.begin(9600);
  // while (!Serial);

  if (!IMU.begin()) {
    // Serial.println("Failed to initialize IMU!");
    while (1);
  }

  pinMode(LED_BUILTIN, OUTPUT);

  if (!BLE.begin()) {
    // Serial.println("starting BLE failed!");
    while (1);
  }

  BLE.setLocalName("BLE-TEMP");
  BLE.setDeviceName("BLE-TEMP");

  repService.addCharacteristic(repCharacteristic);
  BLE.addService(repService);

  BLE.advertise();

  // Serial.println("Bluetooth device active, waiting for connections...");
}

void loop() {
  BLEDevice central = BLE.central();

  if (central) {  // Check if a central device is connected
    // Serial.print("Connected to central: ");
    // Serial.println(central.address());
    digitalWrite(LED_BUILTIN, HIGH);

    while (central.connected()) {
      countReps();
      delay(200);  // Update every 200 milliseconds

      // Check for inactivity
      if (millis() - lastActivityTime > inactivityThreshold) {
        currentExercise = NONE;
      }
    }

    digitalWrite(LED_BUILTIN, LOW);
    // Serial.print("Disconnected from central: ");
    bicepRepCount = 0;
    shoulderRepCount = 0;
    leftLateralRepCount = 0;
    currentExercise = NONE;
    // Serial.println(central.address());
  }
}

void countReps() {
  if (IMU.accelerationAvailable()) {
    IMU.readAcceleration(x, y, z);
    float magnitude = sqrt(x * x + y * y);  // Use magnitude for rep detection

    if (currentExercise == NONE || currentExercise == BICEP) {
      // Bicep curl detection
      if (magnitude > bicepRepThreshold && !inBicepRep) {
        inBicepRep = true;
        currentExercise = BICEP;
        lastActivityTime = millis();
      }
      if (magnitude < bicepRepThreshold && inBicepRep) {
        inBicepRep = false;
        bicepRepCount++;
        char buffer[BUFFER_SIZE];
        snprintf(buffer, sizeof(buffer), "Bicep %d", bicepRepCount);
        repCharacteristic.writeValue(buffer);  // Send rep count over Bluetooth
        // Serial.print("Bicep Rep Count: ");
        // Serial.println(bicepRepCount);
        lastActivityTime = millis();
      }
    }

    if (currentExercise == NONE || currentExercise == SHOULDER) {
      // Shoulder press detection
      if (y < shoulderDownThreshold && !inShoulderRep) {
        inShoulderRep = true;
        currentExercise = SHOULDER;
        lastActivityTime = millis();
        // Serial.println("Shoulder press started");
      }
      if (y > shoulderUpThreshold && inShoulderRep) {
        inShoulderRep = false;
        shoulderRepCount++;
        char buffer[BUFFER_SIZE];
        snprintf(buffer, sizeof(buffer), "Shoulder %d", shoulderRepCount);
        repCharacteristic.writeValue(buffer);  // Send rep count over Bluetooth
        // Serial.print("Shoulder Rep Count: ");
        // Serial.println(shoulderRepCount);
        lastActivityTime = millis();
      }
    }
  }
}
