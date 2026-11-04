/* 
  This following code is uploaded to an Arduino UNO SMD board connected to a laptop through the COM3 port. 
  The code listens for serial commands from the laptop and turns the bulb on or off based on the received command.
*/

// Pin connected to relay
const int relayPin = 13;

void setup() {
  // Initialize serial comm at 9600
  Serial.begin(9600);
  pinMode(relayPin, OUTPUT);

  // Keep bulb off initially
  digitalWrite(relayPin, LOW);
}

void loop() {
  // Read incoming byte
  if(Serial.available() > 0) {
    char command = Serial.read();

    // 1 = bulb ON
    if(command == '1') {
      digitalWrite(relayPin, HIGH);
    }
    // 0 = bulb OFF
    else if (command == '0') {
      digitalWrite(relayPin, LOW);
    }
  }

}
